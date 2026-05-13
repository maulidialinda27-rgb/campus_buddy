# 📱 Sistem Notifikasi Jadwal - CampusBuddy

## 📋 Daftar Isi

1. [Setup Dependencies](#setup-dependencies)
2. [Inisialisasi Sistem](#inisialisasi-sistem)
3. [Cara Kerja Notifikasi](#cara-kerja-notifikasi)
4. [API Reference](#api-reference)
5. [Contoh Penggunaan](#contoh-penggunaan)
6. [Troubleshooting](#troubleshooting)

---

## 🚀 Setup Dependencies

### 1. Dependencies yang Diperlukan (Sudah di pubspec.yaml)

```yaml
dependencies:
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.2
  uuid: ^4.0.0
  shared_preferences: ^2.2.2
```

### 2. Android Setup

**File: `android/app/build.gradle.kts`**

Pastikan `compileSdkVersion` minimal **33**:

```gradle
android {
    compileSdk = 34  // Atau minimal 33

    defaultConfig {
        targetSdk = 34
    }
}
```

**File: `android/app/src/main/AndroidManifest.xml`**

Pastikan permissions sudah ada:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

**File: `android/app/src/main/kotlin/com/example/campus_buddy/MainActivity.kt`**

```kotlin
package com.example.campus_buddy

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}
```

### 3. iOS Setup

**File: `ios/Runner/Info.plist`**

Tambahkan keys untuk notifikasi:

```xml
<dict>
    <key>NSUserNotificationAlertStyle</key>
    <string>alert</string>
</dict>
```

---

## 🔧 Inisialisasi Sistem

### Langkah 1: Update main.dart

```dart
import 'package:flutter/material.dart';
import 'package:campus_buddy/services/notification_service.dart';
import 'package:campus_buddy/services/jadwal_service.dart';
import 'app.dart';

void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inisialisasi Notification Service
  final notificationService = NotificationService();
  await notificationService.initNotification();

  // ✅ Inisialisasi Jadwal Service
  final jadwalService = JadwalService();
  await jadwalService.init();

  runApp(const CampusBuddyApp());
}
```

---

## 💡 Cara Kerja Notifikasi

### 1. Alur Pembuatan Jadwal dengan Notifikasi

```
┌─────────────────────────────────────┐
│ User tambah jadwal baru             │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ JadwalService.addJadwal()           │
│ - Simpan ke SharedPreferences       │
│ - Parse jam dan tanggal             │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ NotificationService.scheduleNotif() │
│ - Hitung waktu: jam - 10 menit      │
│ - Jadwalkan dengan timezone         │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ Notifikasi muncul 10 menit sebelum   │
│ jadwal dimulai                       │
└─────────────────────────────────────┘
```

### 2. Timing Notifikasi

**Contoh:**

- Jadwal: Senin, 10:00 (Jam 10 pagi)
- Notifikasi akan muncul: Senin, 09:50 (Jam 9:50 pagi)
- Durasi: 10 menit sebelumnya

---

## 📚 API Reference

### NotificationService

#### `initNotification()`

Inisialisasi sistem notifikasi. **Harus dipanggil di main()!**

```dart
final notificationService = NotificationService();
await notificationService.initNotification();
```

#### `scheduleNotification()`

Jadwalkan notifikasi untuk kegiatan tertentu.

```dart
await notificationService.scheduleNotification(
  id: 1,                              // Unique ID
  judul: 'Kuliah Algoritma',         // Nama kegiatan
  jadwalJam: '10:00',                // Format HH:MM
  tanggal: DateTime.now(),           // Tanggal
  menitSebelum: 10,                  // Default: 10 menit
);
```

#### `cancelNotification(int id)`

Batalkan notifikasi tertentu.

```dart
await notificationService.cancelNotification(1);
```

#### `cancelAllNotifications()`

Batalkan semua notifikasi.

```dart
await notificationService.cancelAllNotifications();
```

#### `showTestNotification(String judul)`

Tampilkan notifikasi test (untuk debugging).

```dart
await notificationService.showTestNotification('Test Jadwal');
```

### JadwalService

#### `init()`

Inisialisasi SharedPreferences untuk penyimpanan data.

```dart
final jadwalService = JadwalService();
await jadwalService.init();
```

#### `addJadwal(Jadwal jadwal)`

Tambahkan jadwal baru dan otomatis buat notifikasi.

```dart
final jadwal = Jadwal(
  id: 'uuid-1',
  judul: 'Kuliah Algoritma',
  hari: 'Senin',
  jam: '10:00',
  notifikasi: 1,  // 1 = aktif, 0 = nonaktif
  dibuatPada: DateTime.now(),
  diperbarui: DateTime.now(),
);

await jadwalService.addJadwal(jadwal);
```

#### `getAllJadwal()`

Ambil semua jadwal yang disimpan.

```dart
List<Jadwal> semuaJadwal = jadwalService.getAllJadwal();
```

#### `getJadwalByHari(String hari)`

Ambil jadwal untuk hari tertentu.

```dart
List<Jadwal> jadwalSenin = jadwalService.getJadwalByHari('Senin');
```

#### `updateJadwal(Jadwal jadwal)`

Update jadwal dan notifikasinya.

```dart
await jadwalService.updateJadwal(jadwal);
```

#### `deleteJadwal(String jadwalId)`

Hapus jadwal dan batalkan notifikasinya.

```dart
await jadwalService.deleteJadwal('uuid-1');
```

#### `toggleNotifikasi(String jadwalId)`

Aktifkan/matikan notifikasi untuk jadwal tertentu.

```dart
await jadwalService.toggleNotifikasi('uuid-1');
```

---

## 💻 Contoh Penggunaan

### Contoh 1: Menambah Jadwal dengan Notifikasi

```dart
import 'package:campus_buddy/services/jadwal_service.dart';
import 'package:campus_buddy/features/jadwal/data/models/jadwal_model.dart';
import 'package:uuid/uuid.dart';

void tambahJadwalKuliah() async {
  final jadwalService = JadwalService();

  final jadwalBaru = Jadwal(
    id: const Uuid().v4(),
    judul: 'Kuliah Algoritma',
    deskripsi: 'Kuliah',
    hari: 'Senin',
    jam: '10:00',
    notifikasi: 1,  // Notifikasi aktif
    dibuatPada: DateTime.now(),
    diperbarui: DateTime.now(),
  );

  try {
    await jadwalService.addJadwal(jadwalBaru);
    print('✅ Jadwal ditambahkan! Notifikasi akan muncul pada 09:50');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### Contoh 2: Membaca Semua Jadwal Senin

```dart
void lihatJadwalSenin() {
  final jadwalService = JadwalService();

  final jadwalSenin = jadwalService.getJadwalByHari('Senin');

  for (var jadwal in jadwalSenin) {
    print('📅 ${jadwal.judul} - ${jadwal.jam}');
  }
}
```

### Contoh 3: Mengedit Jadwal dengan Update Notifikasi

```dart
Future<void> editJadwal(Jadwal jadwalLama) async {
  final jadwalService = JadwalService();

  final jadwalBaru = jadwalLama.copyWith(
    judul: 'Kuliah Algoritma Lanjutan',
    jam: '13:00',  // Ganti jam
    diperbarui: DateTime.now(),
  );

  try {
    await jadwalService.updateJadwal(jadwalBaru);
    print('✅ Jadwal diupdate! Notifikasi dijadwalkan ulang.');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### Contoh 4: Menampilkan Jadwal dalam ListView

```dart
class JadwalListWidget extends StatefulWidget {
  @override
  State<JadwalListWidget> createState() => _JadwalListWidgetState();
}

class _JadwalListWidgetState extends State<JadwalListWidget> {
  late JadwalService _jadwalService;
  List<Jadwal> _daftarJadwal = [];

  @override
  void initState() {
    super.initState();
    _jadwalService = JadwalService();
    _loadJadwal();
  }

  void _loadJadwal() {
    setState(() {
      _daftarJadwal = _jadwalService.getAllJadwal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
    );
  }
}
```

---

## 📱 UI Components

### Dialog Tambah Jadwal

Sudah disediakan di: `lib/features/jadwal/presentation/pages/tambah_jadwal_dialog.dart`

Fitur:

- ✅ Input nama kegiatan
- ✅ Pilih hari (Senin - Minggu)
- ✅ Pilih jam dengan TimePicker
- ✅ Pilih kategori dengan warna berbeda
- ✅ Toggle notifikasi
- ✅ Simpan/Update/Hapus

**Cara penggunaan:**

```dart
showDialog(
  context: context,
  builder: (context) => TambahJadwalDialog(
    onSave: (jadwal) async {
      await jadwalService.addJadwal(jadwal);
      Navigator.pop(context);
    },
  ),
);
```

### Jadwal Page

Sudah disediakan di: `lib/features/jadwal/presentation/pages/jadwal_page.dart`

Fitur:

- ✅ Tampilkan list jadwal dengan warna kategori
- ✅ Urutkan berdasarkan hari
- ✅ Toggle notifikasi dengan icon
- ✅ Edit jadwal
- ✅ Hapus jadwal (swipe atau button)
- ✅ FAB untuk tambah jadwal
- ✅ Empty state jika belum ada jadwal

---

## 🔍 Troubleshooting

### ❌ Notifikasi tidak muncul di Android

**Solusi:**

1. Pastikan permissions di AndroidManifest.xml sudah ada
2. Cek API level 33+
3. Ajarkan user untuk enable notifikasi di Settings
4. Test dengan `showTestNotification()`

```dart
// Test notifikasi
final notificationService = NotificationService();
await notificationService.showTestNotification('Test');
```

### ❌ Error "timezoneImplementation is not initialized"

**Solusi:** Pastikan `initNotification()` dipanggil di main():

```dart
await notificationService.initNotification();  // ✅ Jangan lupa!
```

### ❌ Data jadwal hilang saat app di-restart

**Solusi:** Data disimpan di SharedPreferences, cek:

```dart
final jadwalService = JadwalService();
await jadwalService.init();  // ✅ Inisialisasi dulu!
List<Jadwal> jadwal = jadwalService.getAllJadwal();
```

### ❌ Notifikasi tidak dimulai pada waktu yang tepat

**Solusi:**

1. Pastikan device time sudah benar
2. Hitung ulang timing: jam - 10 menit
3. Test dengan waktu yang lebih dekat

```dart
// Misal jadwal jam 10:00
// Notifikasi seharusnya muncul 09:50
// Jika tidak, cek waktu device
```

### ❌ "Unexpected null value" error

**Solusi:** Pastikan semua field required di Jadwal model terisi:

```dart
final jadwal = Jadwal(
  id: uuid.v4(),          // ✅ Required
  judul: 'Kuliah',       // ✅ Required
  hari: 'Senin',         // ✅ Required
  jam: '10:00',          // ✅ Required
  notifikasi: 1,         // ✅ Default 1
  dibuatPada: DateTime.now(),     // ✅ Required
  diperbarui: DateTime.now(),     // ✅ Required
);
```

---

## 📊 Statistik & Debug

### Cek Statistik Jadwal

```dart
final jadwalService = JadwalService();
final stats = jadwalService.getStatistik();

print('Total jadwal: ${stats['total']}');
print('Dengan notifikasi: ${stats['dengan_notifikasi']}');
print('Tanpa notifikasi: ${stats['tanpa_notifikasi']}');
```

### Debug: Print semua jadwal

```dart
final jadwalService = JadwalService();
final allJadwal = jadwalService.getAllJadwal();

for (var j in allJadwal) {
  print('📅 ID: ${j.id}');
  print('   Judul: ${j.judul}');
  print('   Hari: ${j.hari}');
  print('   Jam: ${j.jam}');
  print('   Notifikasi: ${j.notifikasi == 1 ? "✅ ON" : "❌ OFF"}');
  print('---');
}
```

---

## 📌 Checklist Implementasi

- [x] NotificationService setup
- [x] JadwalService setup
- [x] TambahJadwalDialog UI
- [x] JadwalPage dengan list jadwal
- [x] Inisialisasi di main.dart
- [x] Dokumentasi lengkap

**Siap digunakan! 🚀**

---

## 📞 Support

Jika ada masalah, check:

1. Console logs (print statements)
2. Flutter Diagnostic: `flutter doctor`
3. Cek permissions di device settings
4. Restart app dan clear cache

---

**Terakhir diupdate:** May 13, 2026
**Versi:** 1.0.0
