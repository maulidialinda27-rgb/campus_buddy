/// ============================================================================
/// CONTOH LENGKAP: TIME RANGE & STATUS WAKTU (UPGRADE V2)
/// ============================================================================

import 'package:campus_buddy/services/jadwal_service.dart';
import 'package:campus_buddy/features/jadwal/data/models/jadwal_model.dart';
import 'package:campus_buddy/core/utils/time_helper.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

/// ============================================================================
/// 1. CONTOH: MEMBUAT JADWAL DENGAN TIME RANGE
/// ============================================================================

Future<void> contohTambahJadwalTimeRange() async {
  final jadwalService = JadwalService();

  print('\n📝 CONTOH 1: Menambah Jadwal dengan Time Range');
  print('================================================');

  // Buat jadwal baru dengan jamMulai & jamSelesai
  final jadwalKuliah = Jadwal(
    id: uuid.v4(),
    judul: 'Kuliah Algoritma',
    deskripsi: 'Kuliah',
    hari: 'Senin',
    jamMulai: '08:00', // Start time
    jamSelesai: '09:30', // End time
    notifikasi: 1,
    dibuatPada: DateTime.now(),
    diperbarui: DateTime.now(),
  );

  try {
    await jadwalService.addJadwal(jadwalKuliah);
    print('✅ Jadwal ditambahkan!');
    print('   Judul: ${jadwalKuliah.judul}');
    print('   Hari: ${jadwalKuliah.hari}');
    print('   Waktu: ${jadwalKuliah.jamMulai} – ${jadwalKuliah.jamSelesai}');
    print(
      '   Durasi: ${formatDuration(jadwalKuliah.jamMulai, jadwalKuliah.jamSelesai)}',
    );
    print('   Notifikasi akan muncul: 07:50');
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// ============================================================================
/// 2. CONTOH: MENAMPILKAN STATUS WAKTU
/// ============================================================================

void contohStatusWaktu() {
  print('\n⏰ CONTOH 2: Status Waktu Real-time');
  print('====================================');

  // Contoh berbagai jadwal
  final jadwal1 = ('08:00', '09:30'); // Kuliah
  final jadwal2 = ('13:00', '14:00'); // Meeting
  final jadwal3 = ('16:00', '17:30'); // Praktik

  print('Waktu sekarang: ${DateTime.now()}');
  print('\nStatus untuk berbagai jadwal:');
  print('1. Jadwal ${jadwal1.$1} – ${jadwal1.$2}');
  print('   Status: ${getScheduleStatus(jadwal1.$1, jadwal1.$2)}');

  print('\n2. Jadwal ${jadwal2.$1} – ${jadwal2.$2}');
  print('   Status: ${getScheduleStatus(jadwal2.$1, jadwal2.$2)}');

  print('\n3. Jadwal ${jadwal3.$1} – ${jadwal3.$2}');
  print('   Status: ${getScheduleStatus(jadwal3.$1, jadwal3.$2)}');
}

/// ============================================================================
/// 3. CONTOH: CEK JADWAL SEDANG BERLANGSUNG
/// ============================================================================

void contohCekBerlangsung() {
  print('\n🟢 CONTOH 3: Check Jadwal Sedang Berlangsung');
  print('=============================================');

  final jadwal = ('08:00', '09:30');
  final isOngoing = isTimeInRange(jadwal.$1, jadwal.$2);

  print('Jadwal: ${jadwal.$1} – ${jadwal.$2}');
  if (isOngoing) {
    print('✅ SEDANG BERLANGSUNG SEKARANG!');
  } else {
    print('❌ Jadwal belum atau sudah selesai');
  }
}

/// ============================================================================
/// 4. CONTOH: HITUNG MENIT SAMPAI JADWAL BERIKUTNYA
/// ============================================================================

void contohHitungMenit() {
  print('\n⏱️ CONTOH 4: Hitung Menit sampai Jadwal');
  print('========================================');

  final jadwalMulai = '14:00';
  final menit = minutesUntilSchedule(jadwalMulai);

  print('Jadwal mulai: $jadwalMulai');
  if (menit > 0) {
    print('Jadwal dimulai dalam: $menit menit');
    print('Atau: ${menit ~/ 60} jam ${menit % 60} menit');
  } else if (menit == 0) {
    print('🎯 Jadwal dimulai SEKARANG!');
  } else {
    print('✅ Jadwal sudah selesai');
  }
}

/// ============================================================================
/// 5. CONTOH: FORMAT DURASI JADWAL
/// ============================================================================

void contohFormatDurasi() {
  print('\n📊 CONTOH 5: Format Durasi Jadwal');
  print('==================================');

  final contohDurasi = [
    ('08:00', '09:00'), // 1 jam
    ('08:00', '09:30'), // 1j 30m
    ('13:00', '13:45'), // 45 menit
    ('07:30', '12:00'), // 4j 30m
  ];

  for (var (mulai, selesai) in contohDurasi) {
    final duration = formatDuration(mulai, selesai);
    print('$mulai – $selesai = $duration');
  }
}

/// ============================================================================
/// 6. CONTOH: VALIDASI FORMAT JAM
/// ============================================================================

void contohValidasiJam() {
  print('\n✔️ CONTOH 6: Validasi Format Jam');
  print('=================================');

  final contohJam = [
    '08:00', // Valid
    '23:59', // Valid
    '00:00', // Valid
    '25:00', // Invalid (jam > 24)
    '08:60', // Invalid (menit > 60)
    '8:30', // Invalid (harus 08:30)
    'invalid', // Invalid
  ];

  for (var jam in contohJam) {
    final valid = isValidTimeFormat(jam);
    print('$jam : ${valid ? '✅ Valid' : '❌ Invalid'}');
  }
}

/// ============================================================================
/// 7. CONTOH: VALIDASI TIME RANGE
/// ============================================================================

void contohValidasiTimeRange() {
  print('\n🔍 CONTOH 7: Validasi Time Range');
  print('=================================');

  final contohRange = [
    ('08:00', '09:30'), // Valid
    ('13:00', '14:00'), // Valid
    ('09:00', '08:00'), // Valid (next day)
    ('08:00', '08:00'), // Invalid (sama)
  ];

  for (var (mulai, selesai) in contohRange) {
    final valid = isValidTimeRange(mulai, selesai);
    print('$mulai – $selesai : ${valid ? '✅ Valid' : '❌ Invalid'}');
  }
}

/// ============================================================================
/// 8. CONTOH: MEMBACA JADWAL & TAMPILKAN DURASI
/// ============================================================================

void contohBacaJadwalDenganDurasi() {
  final jadwalService = JadwalService();

  print('\n📖 CONTOH 8: Baca Jadwal & Tampilkan Durasi');
  print('============================================');

  final semuaJadwal = jadwalService.getAllJadwal();

  if (semuaJadwal.isEmpty) {
    print('❌ Belum ada jadwal');
    return;
  }

  print('Total jadwal: ${semuaJadwal.length}\n');

  for (int i = 0; i < semuaJadwal.length; i++) {
    final j = semuaJadwal[i];
    final status = getScheduleStatus(j.jamMulai, j.jamSelesai);
    final durasi = formatDuration(j.jamMulai, j.jamSelesai);

    print('${i + 1}. ${j.judul}');
    print('   Hari: ${j.hari}');
    print('   Waktu: ${j.jamMulai} – ${j.jamSelesai}');
    print('   Durasi: $durasi');
    print('   Status: $status');
    print('   Kategori: ${j.deskripsi ?? 'Lainnya'}');
    print('   Notifikasi: ${j.notifikasi == 1 ? '✅ Aktif' : '❌ Nonaktif'}');
    print('');
  }
}

/// ============================================================================
/// 9. CONTOH: SCENARIO E2E DENGAN TIME RANGE
/// ============================================================================

Future<void> contohE2ETimeRange() async {
  final jadwalService = JadwalService();

  print('\n🚀 CONTOH 9: Scenario E2E dengan Time Range');
  print('=============================================');

  try {
    // Step 1: Tambah beberapa jadwal
    print('\n1️⃣ Menambahkan jadwal dengan time range...');

    final jadwal1 = Jadwal(
      id: uuid.v4(),
      judul: 'Kuliah Algoritma',
      deskripsi: 'Kuliah',
      hari: 'Senin',
      jamMulai: '08:00',
      jamSelesai: '09:30',
      notifikasi: 1,
      dibuatPada: DateTime.now(),
      diperbarui: DateTime.now(),
    );
    await jadwalService.addJadwal(jadwal1);
    print(
      '   ✅ Jadwal 1: ${jadwal1.judul} (${jadwal1.jamMulai} – ${jadwal1.jamSelesai})',
    );

    final jadwal2 = Jadwal(
      id: uuid.v4(),
      judul: 'Meeting dengan Dosen',
      deskripsi: 'Meeting',
      hari: 'Senin',
      jamMulai: '10:00',
      jamSelesai: '11:00',
      notifikasi: 1,
      dibuatPada: DateTime.now(),
      diperbarui: DateTime.now(),
    );
    await jadwalService.addJadwal(jadwal2);
    print(
      '   ✅ Jadwal 2: ${jadwal2.judul} (${jadwal2.jamMulai} – ${jadwal2.jamSelesai})',
    );

    // Step 2: Display semua jadwal
    print('\n2️⃣ Tampilkan semua jadwal:');
    final semuaJadwal = jadwalService.getAllJadwal();
    for (var j in semuaJadwal) {
      final durasi = formatDuration(j.jamMulai, j.jamSelesai);
      print('   • ${j.jamMulai} – ${j.jamSelesai} ($durasi) - ${j.judul}');
    }

    // Step 3: Check status
    print('\n3️⃣ Check status setiap jadwal:');
    for (var j in semuaJadwal) {
      final status = getScheduleStatus(j.jamMulai, j.jamSelesai);
      print('   • ${j.judul}: $status');
    }

    // Step 4: Edit jadwal (ubah durasi)
    print('\n4️⃣ Edit jadwal (ubah jam selesai):');
    final jadwalEdit = jadwal1.copyWith(
      jamSelesai: '10:00', // Ubah dari 09:30 ke 10:00
      diperbarui: DateTime.now(),
    );
    await jadwalService.updateJadwal(jadwalEdit);
    final durasiSebelum = formatDuration(jadwal1.jamMulai, jadwal1.jamSelesai);
    final durasiSesudah = formatDuration(
      jadwalEdit.jamMulai,
      jadwalEdit.jamSelesai,
    );
    print('   ✅ ${jadwal1.judul}');
    print('      Durasi sebelum: $durasiSebelum');
    print('      Durasi sesudah: $durasiSesudah');

    // Step 5: Statistik
    print('\n5️⃣ Statistik:');
    final stats = jadwalService.getStatistik();
    print('   Total jadwal: ${stats['total']}');
    print('   Dengan notifikasi: ${stats['dengan_notifikasi']}');

    print('\n✅ Scenario E2E selesai!');
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// ============================================================================
/// MAIN - Jalankan Semua Contoh
/// ============================================================================

void main() {
  print('═══════════════════════════════════════════════════════');
  print('📚 CONTOH LENGKAP: TIME RANGE & STATUS WAKTU (V2)');
  print('═══════════════════════════════════════════════════════');

  // Jalankan contoh yang tidak async
  contohStatusWaktu();
  contohCekBerlangsung();
  contohHitungMenit();
  contohFormatDurasi();
  contohValidasiJam();
  contohValidasiTimeRange();
  contohBacaJadwalDenganDurasi();

  print('\n═══════════════════════════════════════════════════════');
  print('💡 Untuk menjalankan contoh async (dengan database):');
  print('   - contohTambahJadwalTimeRange()');
  print('   - contohE2ETimeRange()');
  print('═══════════════════════════════════════════════════════\n');
}

/// ============================================================================
/// HELPER: Print separator
/// ============================================================================

void printSeparator() {
  print('\n───────────────────────────────────────────────────────');
}
