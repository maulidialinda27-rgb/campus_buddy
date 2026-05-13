# 🚀 QUICK START - Sistem Notifikasi Jadwal

## ⚡ Inisialisasi (Sudah Otomatis di main.dart)

```dart
// ✅ Sudah dilakukan di lib/main.dart
// Tidak perlu setup manual lagi!
```

## 📝 Cara Pakai Fitur

### 1️⃣ Buka Halaman Jadwal

Klik menu "Jadwal" di aplikasi → Halaman jadwal terbuka

### 2️⃣ Tambah Jadwal Baru

```
✅ Klik tombol "+" (FAB)
✅ Isi form:
   - Nama Kegiatan: "Kuliah Algoritma"
   - Hari: "Senin"
   - Jam: "10:00" (pilih dengan TimePicker)
   - Kategori: "Kuliah" (opsional)
✅ Aktifkan "Notifikasi" (toggle)
✅ Klik "Simpan"
```

### 3️⃣ Notifikasi Otomatis

✅ Notifikasi akan muncul **10 menit sebelum** jadwal

- Jadwal: 10:00 → Notifikasi: 09:50

### 4️⃣ Kelola Jadwal

**Edit:**

```
Klik "Edit" pada jadwal → Form terbuka → Update → Klik "Update"
```

**Hapus:**

```
Geser ke kanan (swipe) atau klik "Hapus" → Confirm → Done
```

**Toggle Notifikasi:**

```
Klik icon lonceng (🔔) untuk matikan/nyalakan notifikasi
```

---

## 💻 Untuk Developer

### Akses JadwalService

```dart
import 'package:campus_buddy/services/jadwal_service.dart';

final service = JadwalService();
final semuaJadwal = service.getAllJadwal();
```

### Akses NotificationService

```dart
import 'package:campus_buddy/services/notification_service.dart';

final service = NotificationService();
await service.showTestNotification('Test');
```

---

## 📱 File-file Penting

```
lib/
├── services/
│   ├── notification_service.dart  ← Notifikasi
│   └── jadwal_service.dart        ← Penyimpanan jadwal
├── features/jadwal/
│   └── presentation/pages/
│       ├── jadwal_page.dart              ← Halaman utama
│       └── tambah_jadwal_dialog.dart     ← Form dialog
└── main.dart                      ← Inisialisasi
```

---

## 🧪 Testing

**Test notifikasi manual:**

```dart
// Di file apapun
import 'package:campus_buddy/services/notification_service.dart';

final notifService = NotificationService();
await notifService.showTestNotification('Tes Notifikasi');
```

**Cek semua jadwal:**

```dart
import 'package:campus_buddy/services/jadwal_service.dart';

final jadwalService = JadwalService();
final jadwal = jadwalService.getAllJadwal();
print('Total jadwal: ${jadwal.length}');
```

---

## ⚙️ Troubleshooting

| Problem                        | Solusi                                             |
| ------------------------------ | -------------------------------------------------- |
| Notifikasi tidak muncul        | Cek di Settings → Notifikasi → CampusBuddy → ON    |
| Data hilang saat restart       | Normal, cek SharedPreferences sudah terinit        |
| Jam notifikasi salah           | Cek jam device, timezone di timezoneImplementation |
| Error "timezoneImplementation" | Pastikan `initNotification()` dipanggil di main()  |

---

## 📚 Dokumentasi Lengkap

Lihat: [JADWAL_NOTIFIKASI_GUIDE.md](JADWAL_NOTIFIKASI_GUIDE.md)

Untuk contoh lengkap, lihat: [CONTOH_NOTIFIKASI_LENGKAP.dart](CONTOH_NOTIFIKASI_LENGKAP.dart)

---

**Status:** ✅ Siap digunakan

**Versi:** 1.0.0

**Last Updated:** May 13, 2026
