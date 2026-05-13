import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inisialisasi notifikasi
  Future<void> initNotification() async {
    // Initialize timezone
    tzdata.initializeTimeZones();

    // Android setup
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    // iOS setup
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification: onDidReceiveLocalNotification,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );

    // Request iOS permissions
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Request Android permissions for API 31+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Callback ketika notifikasi diterima di foreground (iOS)
  static void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    debugPrint('Local Notification: id=$id, title=$title, body=$body');
  }

  /// Callback ketika user tap notifikasi
  static void onSelectNotification(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    debugPrint('Notification tapped: payload=$payload');
  }

  /// Jadwalkan notifikasi sebelum jadwal dimulai
  /// [id] - unique identifier untuk notifikasi
  /// [judul] - judul kegiatan
  /// [jadwalJam] - jam jadwal (format: "HH:MM")
  /// [menit] - berapa menit sebelum jadwal (default: 10)
  Future<void> scheduleNotification({
    required int id,
    required String judul,
    required String jadwalJam,
    required DateTime tanggal,
    int menitSebelum = 10,
  }) async {
    try {
      // Parse jam jadwal
      final parts = jadwalJam.split(':');
      if (parts.length != 2) {
        debugPrint('Format jam tidak valid: $jadwalJam');
        return;
      }

      int jam = int.parse(parts[0]);
      int menit = int.parse(parts[1]);

      // Buat DateTime untuk jadwal
      final scheduledDateTime = DateTime(
        tanggal.year,
        tanggal.month,
        tanggal.day,
        jam,
        menit,
      );

      // Hitung waktu notifikasi (10 menit sebelumnya)
      final notificationTime = scheduledDateTime.subtract(
        Duration(minutes: menitSebelum),
      );

      // Jangan jadwalkan jika waktu sudah lewat
      if (notificationTime.isBefore(DateTime.now())) {
        debugPrint('Waktu notifikasi sudah lewat: $notificationTime');
        return;
      }

      // Convert ke timezone lokal
      final tz.TZDateTime tzNotificationTime = tz.TZDateTime.from(
        notificationTime,
        tz.local,
      );

      // Jadwalkan notifikasi
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Pengingat Jadwal',
        'Kegiatan "$judul" akan dimulai dalam $menitSebelum menit',
        tzNotificationTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'jadwal_channel',
            'Notifikasi Jadwal',
            channelDescription: 'Notifikasi untuk pengingat jadwal',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('notification'),
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'notification.aiff',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Notifikasi dijadwalkan untuk: $tzNotificationTime, id: $id');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Batalkan notifikasi berdasarkan ID
  Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
      debugPrint('Notifikasi dibatalkan: id=$id');
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  /// Batalkan semua notifikasi
  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('Semua notifikasi dibatalkan');
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }

  /// Test notifikasi (akan muncul 5 detik)
  Future<void> showTestNotification(String judul) async {
    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Test Notifikasi',
        'Ini adalah notifikasi test untuk: $judul',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'jadwal_channel',
            'Notifikasi Jadwal',
            channelDescription: 'Notifikasi untuk pengingat jadwal',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error showing test notification: $e');
    }
  }
}
