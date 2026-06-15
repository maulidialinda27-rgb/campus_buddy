import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // ─── INISIALISASI ─────────────────────────────────────────────────────────

  Future<void> initNotification() async {
    if (_isInitialized) return;

    // 1) Timezone
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {}

    // 2) Inisialisasi plugin
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTapped,
    );

    // 3) Buat channels Android
    await _createChannels();

    // 4) Minta izin notifikasi (Android 13+ / iOS)
    await _requestPermissions();

    _isInitialized = true;
    debugPrint('[NotifService] Initialized ✓');
  }

  // ─── CHANNELS ─────────────────────────────────────────────────────────────

  Future<void> _createChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;

    // Hapus channel lama jika ada (agar importance tidak ter-cache)
    await android.deleteNotificationChannel('jadwal_channel_v1');
    await android.deleteNotificationChannel('tugas_channel_v1');

    // Channel jadwal — Importance.max agar muncul sebagai heads-up banner
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'jadwal_ch',
        'Pengingat Jadwal',
        description: 'Notifikasi pengingat jadwal kuliah',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
        enableLights: true,
      ),
    );

    // Channel tugas
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'tugas_ch',
        'Pengingat Tugas',
        description: 'Notifikasi deadline tugas',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
        enableLights: true,
      ),
    );

    debugPrint('[NotifService] Channels created ✓');
  }

  // ─── IZIN ─────────────────────────────────────────────────────────────────

  /// Minta izin notifikasi. Mengembalikan true jika diizinkan.
  Future<bool> requestPermissions() async {
    return _requestPermissions();
  }

  Future<bool> _requestPermissions() async {
    // Android 13+ (API 33) butuh izin runtime
    final status = await Permission.notification.status;

    if (status.isGranted) {
      debugPrint('[NotifService] Notif permission: GRANTED');
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.notification.request();
      final granted = result.isGranted;
      debugPrint('[NotifService] Notif permission request: ${result.name}');

      // Juga minta izin exact alarm (Android 12+)
      if (granted) {
        await Permission.scheduleExactAlarm.request();
      }
      return granted;
    }

    if (status.isPermanentlyDenied) {
      debugPrint('[NotifService] Notif permission PERMANENTLY DENIED');
      // User harus buka Settings manual
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Cek apakah izin notifikasi sudah diberikan
  Future<bool> isPermissionGranted() async {
    return await Permission.notification.isGranted;
  }

  // ─── TAMPILKAN NOTIFIKASI LANGSUNG (HEADS-UP BANNER) ─────────────────────

  /// Tampilkan notifikasi SEKARANG — muncul sebagai banner di atas layar HP
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String channelId = 'jadwal_ch',
    String? payload,
  }) async {
    if (!_isInitialized) await initNotification();

    final hasPermission = await isPermissionGranted();
    if (!hasPermission) {
      debugPrint('[NotifService] Tidak bisa tampilkan notif — izin belum diberikan');
      final granted = await _requestPermissions();
      if (!granted) return;
    }

    try {
      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelId == 'tugas_ch' ? 'Pengingat Tugas' : 'Pengingat Jadwal',
            channelDescription: 'Notifikasi CampusBuddy',
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            playSound: true,
            showWhen: true,
            ticker: title,
            // Heads-up notification (muncul di atas layar)
            fullScreenIntent: false,
            styleInformation: BigTextStyleInformation(
              body,
              contentTitle: title,
              htmlFormatContentTitle: false,
              htmlFormatBigText: false,
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
      debugPrint('[NotifService] Notif ditampilkan: "$title"');
    } catch (e) {
      debugPrint('[NotifService] Error show: $e');
    }
  }

  // ─── JADWALKAN NOTIFIKASI ──────────────────────────────────────────────────

  Future<void> scheduleNotification({
    required int id,
    required String judul,
    required String jadwalJam,
    required DateTime tanggal,
    int menitSebelum = 10,
  }) async {
    if (!_isInitialized) await initNotification();

    final hasPermission = await isPermissionGranted();
    if (!hasPermission) {
      final granted = await _requestPermissions();
      if (!granted) return;
    }

    try {
      final parts = jadwalJam.split(':');
      if (parts.length != 2) return;

      final scheduledDT = DateTime(
        tanggal.year, tanggal.month, tanggal.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );
      final notifTime = scheduledDT.subtract(Duration(minutes: menitSebelum));

      if (notifTime.isBefore(DateTime.now())) {
        debugPrint('[NotifService] Waktu sudah lewat, skip');
        return;
      }

      final tzTime = tz.TZDateTime.from(notifTime, tz.local);

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'jadwal_ch',
          'Pengingat Jadwal',
          channelDescription: 'Notifikasi pengingat jadwal kuliah',
          importance: Importance.max,
          priority: Priority.max,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      try {
        await _plugin.zonedSchedule(
          id,
          '⏰ Pengingat Jadwal',
          'Kegiatan "$judul" mulai dalam $menitSebelum menit!',
          tzTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'jadwal_$id',
        );
        debugPrint('[NotifService] Dijadwalkan exact: $tzTime');
      } catch (_) {
        // Fallback inexact jika exact alarm diblokir sistem
        await _plugin.zonedSchedule(
          id,
          '⏰ Pengingat Jadwal',
          'Kegiatan "$judul" mulai dalam $menitSebelum menit!',
          tzTime,
          details,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'jadwal_$id',
        );
        debugPrint('[NotifService] Dijadwalkan inexact: $tzTime');
      }
    } catch (e) {
      debugPrint('[NotifService] Error schedule: $e');
    }
  }

  // ─── TEST NOTIFIKASI ───────────────────────────────────────────────────────

  Future<void> showTestNotification(String judul) async {
    await showImmediateNotification(
      id: 9999,
      title: '🔔 CampusBuddy',
      body: 'Notifikasi untuk "$judul" aktif! Sistem pengingat berjalan normal.',
      channelId: 'jadwal_ch',
    );
  }

  // ─── BATALKAN NOTIFIKASI ───────────────────────────────────────────────────

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // ─── CALLBACK ─────────────────────────────────────────────────────────────

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[NotifService] Tapped: ${response.payload}');
  }
}
