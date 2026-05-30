
import 'package:campus_buddy/services/local_storage_service.dart';
import 'package:campus_buddy/features/jadwal/data/models/jadwal_model.dart';
import 'package:campus_buddy/services/notification_service.dart';
import 'dart:developer';

class JadwalService {
  static final JadwalService _instance = JadwalService._internal();

  factory JadwalService() {
    return _instance;
  }

  JadwalService._internal();

  static const String _key = 'jadwal_list';
  final NotificationService _notificationService = NotificationService();

  // Initialization not required for LocalStorageService

  /// Ambil semua jadwal
  List<Jadwal> getAllJadwal() {
    final list = LocalStorageService.instance.loadJsonListSync(_key);
    return list.map((m) => Jadwal.fromMap(m)).toList();
  }

  /// Ambil jadwal untuk hari tertentu
  List<Jadwal> getJadwalByHari(String hari) {
    final semua = getAllJadwal();
    return semua
        .where((j) => j.hari.toLowerCase() == hari.toLowerCase())
        .toList();
  }

  /// Tambah jadwal baru
  Future<void> addJadwal(Jadwal jadwal) async {
    try {
      final list = await LocalStorageService.instance.loadJsonList(_key);
      list.add(jadwal.toMap());
      await LocalStorageService.instance.saveJsonList(_key, list);

      // Jadwalkan notifikasi
      if (jadwal.notifikasi == 1) {
        final tanggal = _parseTanggalDariHari(jadwal.hari);
        await _notificationService.scheduleNotification(
          id: jadwal.id.hashCode,
          judul: jadwal.judul,
          jadwalJam: jadwal.jamMulai,
          tanggal: tanggal,
          menitSebelum: 10,
        );
      }

      log('Jadwal ditambahkan: ${jadwal.judul}');
    } catch (e) {
      log('Error adding jadwal: $e');
      rethrow;
    }
  }

  /// Update jadwal
  Future<void> updateJadwal(Jadwal jadwal) async {
    try {
      final list = await LocalStorageService.instance.loadJsonList(_key);
      final index = list.indexWhere((j) => j['id'] == jadwal.id);

      if (index != -1) {
        // Batalkan notifikasi lama
        await _notificationService.cancelNotification(jadwal.id.hashCode);

        // Update data
        list[index] = jadwal.toMap();
        await LocalStorageService.instance.saveJsonList(_key, list);

        // Jadwalkan notifikasi baru
        if (jadwal.notifikasi == 1) {
          final tanggal = _parseTanggalDariHari(jadwal.hari);
          await _notificationService.scheduleNotification(
            id: jadwal.id.hashCode,
            judul: jadwal.judul,
            jadwalJam: jadwal.jamMulai,
            tanggal: tanggal,
            menitSebelum: 10,
          );
        }

        log('Jadwal diupdate: ${jadwal.judul}');
      }
    } catch (e) {
      log('Error updating jadwal: $e');
      rethrow;
    }
  }

  /// Hapus jadwal
  Future<void> deleteJadwal(String jadwalId) async {
    try {
      final list = await LocalStorageService.instance.loadJsonList(_key);
      list.removeWhere((j) => j['id'] == jadwalId);
      await LocalStorageService.instance.saveJsonList(_key, list);

      // Batalkan notifikasi
      await _notificationService.cancelNotification(jadwalId.hashCode);

      log('Jadwal dihapus: $jadwalId');
    } catch (e) {
      log('Error deleting jadwal: $e');
      rethrow;
    }
  }

  /// Toggle notifikasi untuk jadwal tertentu
  Future<void> toggleNotifikasi(String jadwalId) async {
    try {
      final list = await LocalStorageService.instance.loadJsonList(_key);
      final index = list.indexWhere((j) => j['id'] == jadwalId);

      if (index != -1) {
        final jadwalMap = list[index];
        final currentNotifikasi = jadwalMap['notifikasi'] ?? 0;
        final newNotifikasi = currentNotifikasi == 1 ? 0 : 1;
        jadwalMap['notifikasi'] = newNotifikasi;
        await LocalStorageService.instance.saveJsonList(_key, list);

        // Batalkan notifikasi lama
        await _notificationService.cancelNotification(jadwalId.hashCode);

        // Jadwalkan notifikasi baru jika diaktifkan
        if (newNotifikasi == 1) {
          final tanggal = _parseTanggalDariHari(jadwalMap['hari']);
          await _notificationService.scheduleNotification(
            id: jadwalId.hashCode,
            judul: jadwalMap['judul'],
            jadwalJam: jadwalMap['jamMulai'],
            tanggal: tanggal,
            menitSebelum: 10,
          );
        }

        log('Notifikasi untuk jadwal $jadwalId: ${newNotifikasi == 1 ? "aktif" : "nonaktif"}');
      }
    } catch (e) {
      log('Error toggling notifikasi: $e');
      rethrow;
    }
  }

  /// Clear semua jadwal
  Future<void> clearAllJadwal() async {
    try {
      await LocalStorageService.instance.deleteJsonKey(_key);
      await _notificationService.cancelAllNotifications();
      log('Semua jadwal dihapus');
    } catch (e) {
      log('Error clearing jadwal: $e');
      rethrow;
    }
  }

  /// Parse tanggal dari hari (untuk test)
  DateTime _parseTanggalDariHari(String hari) {
    final daftarHari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    final hariIndex = daftarHari.indexWhere(
      (h) => h.toLowerCase() == hari.toLowerCase(),
    );

    if (hariIndex == -1) {
      return DateTime.now().add(const Duration(days: 1));
    }

    final sekarang = DateTime.now();
    var targetHari = DateTime(
      sekarang.year,
      sekarang.month,
      sekarang.day,
    ).add(Duration(days: hariIndex - sekarang.weekday + 1));

    if (targetHari.isBefore(sekarang)) {
      targetHari = targetHari.add(const Duration(days: 7));
    }

    return targetHari;
  }

  /// Test: Dapatkan statistik jadwal
  Map<String, dynamic> getStatistik() {
    final allJadwal = getAllJadwal();
    final denganNotifikasi = allJadwal.where((j) => j.notifikasi == 1).length;

    return {
      'total': allJadwal.length,
      'dengan_notifikasi': denganNotifikasi,
      'tanpa_notifikasi': allJadwal.length - denganNotifikasi,
    };
  }
}