/// ============================================================================
/// CONTOH LENGKAP: SISTEM NOTIFIKASI JADWAL CAMPUSBUDDY
/// ============================================================================
/// File ini menunjukkan contoh penggunaan NotificationService dan JadwalService
/// Untuk integrasi ke dalam aplikasi CampusBuddy
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:campus_buddy/services/notification_service.dart';
import 'package:campus_buddy/services/jadwal_service.dart';
import 'package:campus_buddy/features/jadwal/data/models/jadwal_model.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

/// ============================================================================
/// 1. CONTOH: INISIALISASI DI main.dart
/// ============================================================================

void mainExample() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inisialisasi Notification Service
  final notificationService = NotificationService();
  await notificationService.initNotification();
  print('✅ NotificationService sudah diinisialisasi');

  // ✅ Inisialisasi Jadwal Service
  final jadwalService = JadwalService();
  await jadwalService.init();
  print('✅ JadwalService sudah diinisialisasi');

  // runApp(const CampusBuddyApp()); // Ganti dengan app utama Anda
}

/// ============================================================================
/// 2. CONTOH: MENAMBAH JADWAL DENGAN NOTIFIKASI
/// ============================================================================

Future<void> contohTambahJadwal() async {
  final jadwalService = JadwalService();

  print('\n📝 CONTOH 1: Menambah Jadwal dengan Notifikasi');
  print('=====================================');

  // Buat jadwal baru
  final jadwalKuliah = Jadwal(
    id: uuid.v4(),
    judul: 'Kuliah Algoritma',
    deskripsi: 'Kuliah',
    hari: 'Senin',
    jam: '10:00',
    notifikasi: 1, // Notifikasi aktif: akan muncul 09:50
    dibuatPada: DateTime.now(),
    diperbarui: DateTime.now(),
  );

  try {
    await jadwalService.addJadwal(jadwalKuliah);
    print('✅ Jadwal ditambahkan!');
    print('   Judul: ${jadwalKuliah.judul}');
    print('   Hari: ${jadwalKuliah.hari}');
    print('   Jam: ${jadwalKuliah.jam}');
    print('   Notifikasi akan muncul: 09:50 (10 menit sebelum)');
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// ============================================================================
/// 3. CONTOH: MEMBACA SEMUA JADWAL
/// ============================================================================

void contohBacaSemuaJadwal() {
  final jadwalService = JadwalService();

  print('\n📖 CONTOH 2: Membaca Semua Jadwal');
  print('=====================================');

  final semuaJadwal = jadwalService.getAllJadwal();

  if (semuaJadwal.isEmpty) {
    print('❌ Belum ada jadwal');
    return;
  }

  print('Total jadwal: ${semuaJadwal.length}');
  for (int i = 0; i < semuaJadwal.length; i++) {
    final j = semuaJadwal[i];
    print('\n${i + 1}. ${j.judul}');
    print('   Hari: ${j.hari}');
    print('   Jam: ${j.jam}');
    print('   Notifikasi: ${j.notifikasi == 1 ? "✅ Aktif" : "❌ Nonaktif"}');
    print('   ID: ${j.id}');
  }
}

/// ============================================================================
/// 4. CONTOH: MEMBACA JADWAL PER HARI
/// ============================================================================

void contohBacaJadwalPerHari() {
  final jadwalService = JadwalService();

  print('\n📅 CONTOH 3: Membaca Jadwal Per Hari');
  print('=====================================');

  final jadwalSenin = jadwalService.getJadwalByHari('Senin');

  print('\nJadwal Senin: (${jadwalSenin.length} kegiatan)');
  for (var j in jadwalSenin) {
    print('  • ${j.jam} - ${j.judul}');
  }
}

/// ============================================================================
/// 5. CONTOH: MENGUPDATE JADWAL DAN NOTIFIKASINYA
/// ============================================================================

Future<void> contohUpdateJadwal() async {
  final jadwalService = JadwalService();

  print('\n✏️ CONTOH 4: Mengupdate Jadwal');
  print('=====================================');

  final semuaJadwal = jadwalService.getAllJadwal();

  if (semuaJadwal.isEmpty) {
    print('❌ Belum ada jadwal untuk diupdate');
    return;
  }

  final jadwalLama = semuaJadwal[0];

  print('Jadwal sebelum update:');
  print('  Judul: ${jadwalLama.judul}');
  print('  Jam: ${jadwalLama.jam}');

  // Update dengan data baru
  final jadwalBaru = jadwalLama.copyWith(
    judul: 'Kuliah Algoritma Lanjutan',
    jam: '13:00', // Ubah jam
    diperbarui: DateTime.now(),
  );

  try {
    await jadwalService.updateJadwal(jadwalBaru);
    print('\n✅ Jadwal diupdate!');
    print('Jadwal setelah update:');
    print('  Judul: ${jadwalBaru.judul}');
    print('  Jam: ${jadwalBaru.jam}');
    print('  Notifikasi dijadwalkan ulang: 12:50');
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// ============================================================================
/// 6. CONTOH: TOGGLE NOTIFIKASI
/// ============================================================================

Future<void> contohToggleNotifikasi() async {
  final jadwalService = JadwalService();

  print('\n🔔 CONTOH 5: Toggle Notifikasi');
  print('=====================================');

  final semuaJadwal = jadwalService.getAllJadwal();

  if (semuaJadwal.isEmpty) {
    print('❌ Belum ada jadwal');
    return;
  }

  final jadwal = semuaJadwal[0];
  final statusBefore = jadwal.notifikasi == 1 ? 'ON' : 'OFF';

  try {
    await jadwalService.toggleNotifikasi(jadwal.id);

    // Baca ulang untuk melihat perubahan
    final jadwalUpdated = jadwalService.getAllJadwal().firstWhere(
      (j) => j.id == jadwal.id,
    );

    final statusAfter = jadwalUpdated.notifikasi == 1 ? 'ON' : 'OFF';

    print('✅ Notifikasi untuk "${jadwal.judul}"');
    print('   Sebelum: $statusBefore');
    print('   Sesudah: $statusAfter');
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// ============================================================================
/// 7. CONTOH: MENGHAPUS JADWAL
/// ============================================================================

Future<void> contohHapusJadwal() async {
  final jadwalService = JadwalService();

  print('\n🗑️ CONTOH 6: Menghapus Jadwal');
  print('=====================================');

  final semuaJadwal = jadwalService.getAllJadwal();

  if (semuaJadwal.isEmpty) {
    print('❌ Belum ada jadwal untuk dihapus');
    return;
  }

  final jadwalHapus = semuaJadwal[0];

  try {
    await jadwalService.deleteJadwal(jadwalHapus.id);
    print('✅ Jadwal dihapus!');
    print('   Jadwal: ${jadwalHapus.judul}');
    print('   Notifikasi juga dibatalkan');
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// ============================================================================
/// 8. CONTOH: STATISTIK JADWAL
/// ============================================================================

void contohStatistik() {
  final jadwalService = JadwalService();

  print('\n📊 CONTOH 7: Statistik Jadwal');
  print('=====================================');

  final stats = jadwalService.getStatistik();

  print('Total jadwal: ${stats['total']}');
  print('Dengan notifikasi: ${stats['dengan_notifikasi']}');
  print('Tanpa notifikasi: ${stats['tanpa_notifikasi']}');

  final persentase = stats['total'] > 0
      ? ((stats['dengan_notifikasi'] / stats['total']) * 100).toStringAsFixed(1)
      : '0';
  print('Persentase notifikasi aktif: $persentase%');
}

/// ============================================================================
/// 9. CONTOH: TEST NOTIFIKASI
/// ============================================================================

Future<void> contohTestNotifikasi() async {
  final notificationService = NotificationService();

  print('\n🧪 CONTOH 8: Test Notifikasi');
  print('=====================================');
  print('Notifikasi test akan muncul dalam 2 detik...');

  try {
    await notificationService.showTestNotification('Kuliah Algoritma');
    print('✅ Notifikasi test ditampilkan!');
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// ============================================================================
/// 10. CONTOH: SKENARIO LENGKAP (E2E)
/// ============================================================================

Future<void> contohE2E() async {
  final jadwalService = JadwalService();

  print('\n🚀 CONTOH 9: Skenario Lengkap (End-to-End)');
  print('=====================================');

  try {
    // Step 1: Tambah jadwal
    print('\n1️⃣ Menambahkan jadwal...');
    final jadwal1 = Jadwal(
      id: uuid.v4(),
      judul: 'Kuliah Algoritma',
      deskripsi: 'Kuliah',
      hari: 'Senin',
      jam: '10:00',
      notifikasi: 1,
      dibuatPada: DateTime.now(),
      diperbarui: DateTime.now(),
    );
    await jadwalService.addJadwal(jadwal1);
    print('   ✅ Jadwal 1 ditambahkan');

    final jadwal2 = Jadwal(
      id: uuid.v4(),
      judul: 'Tugas Pemrograman',
      deskripsi: 'Tugas',
      hari: 'Senin',
      jam: '14:00',
      notifikasi: 1,
      dibuatPada: DateTime.now(),
      diperbarui: DateTime.now(),
    );
    await jadwalService.addJadwal(jadwal2);
    print('   ✅ Jadwal 2 ditambahkan');

    // Step 2: Tampilkan statistik
    print('\n2️⃣ Statistik:');
    final stats = jadwalService.getStatistik();
    print('   Total: ${stats['total']} jadwal');
    print('   Dengan notifikasi: ${stats['dengan_notifikasi']}');

    // Step 3: Baca jadwal per hari
    print('\n3️⃣ Jadwal Senin:');
    final jadwalSenin = jadwalService.getJadwalByHari('Senin');
    for (var j in jadwalSenin) {
      print('   • ${j.jam} - ${j.judul}');
    }

    // Step 4: Update jadwal
    print('\n4️⃣ Mengupdate jadwal pertama...');
    final jadwalUpdated = jadwal1.copyWith(
      jam: '09:00',
      diperbarui: DateTime.now(),
    );
    await jadwalService.updateJadwal(jadwalUpdated);
    print('   ✅ Jadwal diupdate ke jam 09:00');

    // Step 5: Toggle notifikasi
    print('\n5️⃣ Mematikan notifikasi jadwal kedua...');
    await jadwalService.toggleNotifikasi(jadwal2.id);
    print('   ✅ Notifikasi dimatikan');

    // Step 6: Tampilkan hasil akhir
    print('\n6️⃣ Hasil Akhir:');
    final semuaJadwal = jadwalService.getAllJadwal();
    for (var j in semuaJadwal) {
      final notifStatus = j.notifikasi == 1 ? '✅' : '❌';
      print('   $notifStatus ${j.jam} - ${j.judul}');
    }

    print('\n✅ Skenario E2E selesai!');
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// ============================================================================
/// 11. CONTOH PENGGUNAAN DI FLUTTER WIDGET (UI)
/// ============================================================================

class ContohUIWidget extends StatefulWidget {
  @override
  State<ContohUIWidget> createState() => _ContohUIWidgetState();
}

class _ContohUIWidgetState extends State<ContohUIWidget> {
  late JadwalService _jadwalService;
  late NotificationService _notificationService;
  List<Jadwal> _daftarJadwal = [];

  @override
  void initState() {
    super.initState();
    _jadwalService = JadwalService();
    _notificationService = NotificationService();
    _loadJadwal();
  }

  void _loadJadwal() {
    setState(() {
      _daftarJadwal = _jadwalService.getAllJadwal();
    });
  }

  Future<void> _tambahJadwalContoh() async {
    final jadwalBaru = Jadwal(
      id: uuid.v4(),
      judul: 'Jadwal Baru',
      hari: 'Selasa',
      jam: '11:00',
      notifikasi: 1,
      dibuatPada: DateTime.now(),
      diperbarui: DateTime.now(),
    );

    try {
      await _jadwalService.addJadwal(jadwalBaru);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Jadwal ditambahkan')));
      _loadJadwal();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    }
  }

  Future<void> _testNotifikasi() async {
    try {
      await _notificationService.showTestNotification('Test Notifikasi');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Test notifikasi ditampilkan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contoh Jadwal UI')),
      body: Column(
        children: [
          // Tombol untuk test
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _tambahJadwalContoh,
                    child: const Text('Tambah Jadwal'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _testNotifikasi,
                    child: const Text('Test Notifikasi'),
                  ),
                ),
              ],
            ),
          ),
          // List jadwal
          Expanded(
            child: _daftarJadwal.isEmpty
                ? const Center(child: Text('Belum ada jadwal'))
                : ListView.builder(
                    itemCount: _daftarJadwal.length,
                    itemBuilder: (context, index) {
                      final jadwal = _daftarJadwal[index];
                      return ListTile(
                        title: Text(jadwal.judul),
                        subtitle: Text('${jadwal.hari} - ${jadwal.jam}'),
                        trailing: Icon(
                          jadwal.notifikasi == 1
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahJadwalContoh,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// ============================================================================
/// RINGKASAN CONTOH
/// ============================================================================
///
/// Contoh di atas menunjukkan:
/// 1. ✅ Inisialisasi NotificationService & JadwalService
/// 2. ✅ Menambah jadwal dengan notifikasi otomatis
/// 3. ✅ Membaca semua jadwal
/// 4. ✅ Membaca jadwal per hari
/// 5. ✅ Update jadwal dan notifikasinya
/// 6. ✅ Toggle notifikasi
/// 7. ✅ Menghapus jadwal
/// 8. ✅ Statistik jadwal
/// 9. ✅ Test notifikasi
/// 10. ✅ Skenario end-to-end lengkap
/// 11. ✅ Penggunaan dalam widget Flutter
///
/// Untuk menjalankan contoh:
/// - Copy kode ini ke file terpisah atau console
/// - Panggil fungsi contoh sesuai kebutuhan
/// - Cek output di console untuk verifikasi
///
/// ============================================================================
