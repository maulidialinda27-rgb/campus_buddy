import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_buddy/features/jadwal/data/models/jadwal_model.dart';
import 'package:campus_buddy/services/notification_service.dart';

class JadwalService {
  static final JadwalService _instance = JadwalService._internal();

  factory JadwalService() {
    return _instance;
  }

  JadwalService._internal();

  static const String _jadwalKey = 'jadwal_list';
  late SharedPreferences _prefs;
  final NotificationService _notificationService = NotificationService();

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Ambil semua jadwal
  List<Jadwal> getAllJadwal() {
    final jsonString = _prefs.getString(_jadwalKey);
    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((item) => Jadwal.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading jadwal: $e');
      return [];
    }
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
      final allJadwal = getAllJadwal();
      allJadwal.add(jadwal);

      // Simpan ke SharedPreferences
      final jsonString = jsonEncode(allJadwal.map((j) => j.toMap()).toList());
      await _prefs.setString(_jadwalKey, jsonString);

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

      print('Jadwal ditambahkan: ${jadwal.judul}');
    } catch (e) {
      print('Error adding jadwal: $e');
      rethrow;
    }
  }

  /// Update jadwal
  Future<void> updateJadwal(Jadwal jadwal) async {
    try {
      final allJadwal = getAllJadwal();
      final index = allJadwal.indexWhere((j) => j.id == jadwal.id);

      if (index != -1) {
        // Batalkan notifikasi lama
        await _notificationService.cancelNotification(
          allJadwal[index].id.hashCode,
        );

        // Update jadwal
        allJadwal[index] = jadwal;

        final jsonString = jsonEncode(allJadwal.map((j) => j.toMap()).toList());
        await _prefs.setString(_jadwalKey, jsonString);

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

        print('Jadwal diupdate: ${jadwal.judul}');
      }
    } catch (e) {
      print('Error updating jadwal: $e');
      rethrow;
    }
  }

  /// Hapus jadwal
  Future<void> deleteJadwal(String jadwalId) async {
    try {
      final allJadwal = getAllJadwal();
      allJadwal.removeWhere((j) => j.id == jadwalId);

      final jsonString = jsonEncode(allJadwal.map((j) => j.toMap()).toList());
      await _prefs.setString(_jadwalKey, jsonString);

      // Batalkan notifikasi
      await _notificationService.cancelNotification(jadwalId.hashCode);

      print('Jadwal dihapus: $jadwalId');
    } catch (e) {
      print('Error deleting jadwal: $e');
      rethrow;
    }
  }

  /// Toggle notifikasi untuk jadwal tertentu
  Future<void> toggleNotifikasi(String jadwalId) async {
    try {
      final allJadwal = getAllJadwal();
      final index = allJadwal.indexWhere((j) => j.id == jadwalId);

      if (index != -1) {
        final jadwal = allJadwal[index];
        final newNotifikasi = jadwal.notifikasi == 1 ? 0 : 1;

        final updatedJadwal = jadwal.copyWith(notifikasi: newNotifikasi);
        allJadwal[index] = updatedJadwal;

        final jsonString = jsonEncode(allJadwal.map((j) => j.toMap()).toList());
        await _prefs.setString(_jadwalKey, jsonString);

        // Batalkan notifikasi lama
        await _notificationService.cancelNotification(jadwalId.hashCode);

        // Jadwalkan notifikasi baru jika diaktifkan
        if (newNotifikasi == 1) {
          final tanggal = _parseTanggalDariHari(updatedJadwal.hari);
          await _notificationService.scheduleNotification(
            id: jadwalId.hashCode,
            judul: updatedJadwal.judul,
            jadwalJam: updatedJadwal.jamMulai,
            tanggal: tanggal,
            menitSebelum: 10,
          );
        }

        print(
          'Notifikasi untuk jadwal $jadwalId: ${newNotifikasi == 1 ? "aktif" : "nonaktif"}',
        );
      }
    } catch (e) {
      print('Error toggling notifikasi: $e');
      rethrow;
    }
  }

  /// Clear semua jadwal
  Future<void> clearAllJadwal() async {
    try {
      await _prefs.remove(_jadwalKey);
      await _notificationService.cancelAllNotifications();
      print('Semua jadwal dihapus');
    } catch (e) {
      print('Error clearing jadwal: $e');
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
