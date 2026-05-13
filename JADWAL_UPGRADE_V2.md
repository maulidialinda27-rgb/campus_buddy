# 🚀 UPGRADE JADWAL - Time Range & Modern UI

## 📋 Apa yang Baru

### 1. ✅ Time Range Support

**Before:** Hanya satu `jam`
**After:** `jamMulai` dan `jamSelesai`

```dart
Jadwal(
  jamMulai: '08:00',    // Sebelumnya: jam: '08:00'
  jamSelesai: '09:30',  // Baru!
)
```

**Format Tampilan:**

```
08:00 – 09:30
Durasi: 1j 30m
```

### 2. ✅ Status Waktu Real-time

Menampilkan status current berdasarkan waktu:

| Status                | Kondisi                           |
| --------------------- | --------------------------------- |
| 🟢 Sedang berlangsung | Waktu sekarang dalam range jadwal |
| ⏰ Dalam X menit      | Jadwal akan datang                |
| ✅ Selesai            | Waktu sudah lewat                 |
| 🎯 Dimulai sekarang   | Exact time match                  |

### 3. ✅ Next Event Card

Kartu khusus menampilkan jadwal berikutnya:

- Nama kegiatan
- Waktu dimulai
- Berapa menit lagi
- Design eye-catching dengan gradient

### 4. ✅ Modern UI Design

- Timeline style layout
- Colored borders per kategori
- Status & kategori badges
- Smooth animations (FadeInUp)
- Dark mode compatible
- Better spacing & hierarchy

### 5. ✅ Durasi Display

Menampilkan durasi kegiatan otomatis:

```
Kuliah Algoritma
08:00 – 09:30
Durasi: 1j 30m
```

---

## 📁 File yang Di-upgrade

### 1. Model (`jadwal_model.dart`)

**Changed:**

- `jam` → `jamMulai` + `jamSelesai`
- Updated `toMap()`, `fromMap()`, `copyWith()`
- Backward compatible dengan old data

### 2. Services

#### `notification_service.dart`

- No changes (sudah support jamMulai)

#### `jadwal_service.dart`

- Updated untuk menggunakan `jamMulai` di semua places
- Backward compatible migration

### 3. UI Components

#### `tambah_jadwal_dialog.dart`

- Tambah 2 TimePicker: Jam Mulai & Jam Selesai
- Form validation untuk time range
- Better layout dengan row untuk 2 jam

#### `jadwal_page.dart`

- Complete redesign dengan timeline style
- Next event card builder
- Status badges
- Kategori badges
- Duration display
- Modern card design

### 4. Utilities (`time_helper.dart`)

**New file dengan helper functions:**

```dart
parseJam(String jam)              // Parse HH:MM
formatJam(DateTime time)           // Format ke HH:MM
isTimeInRange(String s1, String s2) // Check sedang berlangsung
minutesUntilSchedule(String jam)   // Hitung menit sampai jadwal
formatDuration(String s1, String s2) // Format durasi
getScheduleStatus(String s1, String s2) // Get status text
isValidTimeFormat(String time)     // Validasi format
isValidTimeRange(String s1, String s2) // Validasi range
```

---

## 🎨 Design Features

### Color Scheme

```dart
'Kuliah': #6366F1 (Indigo)
'Tugas': #F97316 (Orange)
'Meeting': #8B5CF6 (Purple)
'Olahraga': #10B981 (Green)
'Istirahat': #00D4FF (Cyan) ← Updated
'Lainnya': #64748B (Slate)
```

### Card Design

```
┌─────────────────────────────────────┐
│ 🟢 08:00 – 09:30           🔔      │ ← Time range + notification toggle
│                                     │
│ Kuliah Algoritma                    │ ← Title
│                                     │
│ [Sedang berlangsung] [Kuliah]       │ ← Status & Category badges
│                                     │
│ [Edit] [Hapus]                      │ ← Action buttons
└─────────────────────────────────────┘
```

### Indicator Colors

- 🟢 Green = Sedang berlangsung
- 🟡 kategoriColor = Akan datang
- Status badge color matches indicator

---

## 💻 Usage Examples

### Buat Jadwal Baru dengan Time Range

```dart
final jadwal = Jadwal(
  id: uuid.v4(),
  judul: 'Kuliah Algoritma',
  deskripsi: 'Kuliah',
  hari: 'Senin',
  jamMulai: '08:00',    // Start time
  jamSelesai: '09:30',  // End time
  notifikasi: 1,
  dibuatPada: DateTime.now(),
  diperbarui: DateTime.now(),
);

await jadwalService.addJadwal(jadwal);
```

### Check Status

```dart
import 'package:campus_buddy/core/utils/time_helper.dart';

final status = getScheduleStatus('08:00', '09:30');
// Returns: "Sedang berlangsung" atau "Dalam 45 menit" dst

final isOngoing = isTimeInRange('08:00', '09:30');
// Returns: true/false

final duration = formatDuration('08:00', '09:30');
// Returns: "1j 30m"
```

### Get Next Schedule

```dart
// Di JadwalPage sudah di-implement
final nextSchedule = _getNextSchedule();
if (nextSchedule != null) {
  print('Jadwal berikutnya: ${nextSchedule.judul}');
}
```

---

## ✨ UI Features

### 1. Next Event Card

- Gradient background
- White text dengan shadow
- Icon + judul + waktu
- Muncul hanya jika ada jadwal berikutnya

### 2. Status Badges

- "Sedang berlangsung" dengan background hijau
- Status lainnya sesuai kategori warna
- Semi-transparent background

### 3. Category Badges

- Display kategori (Kuliah, Tugas, Meeting, etc)
- Warna sesuai kategori
- Semi-transparent background

### 4. Timeline Style

- Indicator dot di sebelah kiri time
- Border warna kategori (left side)
- Clean spacing & alignment

### 5. Animations

- FadeInUp untuk semua cards
- Smooth transitions
- Dismissible swipe untuk delete

---

## 🔄 Migration from Old Data

Semua old data dengan field `jam` akan otomatis di-convert:

```dart
// Old format di SharedPreferences:
{
  'jam': '08:00'
}

// Akan di-parse sebagai:
Jadwal(
  jamMulai: '08:00',
  jamSelesai: '08:00'  // Default sama dengan mulai
)
```

Untuk update, user harus edit dan set `jamSelesai` yang benar.

---

## 🧪 Testing

### Test 1: Tambah Jadwal Baru

```
1. Klik FAB +
2. Isi form:
   - Nama: "Test Jadwal"
   - Hari: "Senin"
   - Jam Mulai: "10:00"
   - Jam Selesai: "11:30"
3. Klik Simpan
Expected: ✅ Jadwal muncul dengan "10:00 – 11:30"
```

### Test 2: Status Real-time

```
1. Buat jadwal untuk waktu sekarang +30 menit
2. Lihat status badge
Expected: ✅ "Dalam 30 menit"

3. Wait sampai jam mulai
Expected: ✅ "Sedang berlangsung" (status berubah)
```

### Test 3: Next Event

```
1. Buat 3 jadwal berbeda hari
2. Lihat halaman Jadwal
Expected: ✅ Card khusus "Kegiatan Berikutnya" muncul
Expected: ✅ Menampilkan jadwal yang akan datang
```

### Test 4: Duration

```
1. Lihat card jadwal
Expected: ✅ Tampil durasi, contoh "1j 30m"
```

---

## 🚀 Deploy Checklist

- [x] Update Jadwal model
- [x] Update JadwalService
- [x] Update TambahJadwalDialog (2 TimePickers)
- [x] Redesign JadwalPage (modern UI)
- [x] Create time_helper.dart
- [x] Test form validation
- [x] Test status display
- [x] Test next event
- [x] Backward compatibility

---

## 📊 Before & After

### Before

```
📱 Jadwal Page
─────────────
[Kuliah Algoritma]
Senin - 08:00
[Edit] [Hapus]
```

### After

```
📱 Jadwal Page (Modern)
──────────────────────
┌─ Next Event ─────────┐
│ 📅 Kuliah Algoritma  │
│ Dalam 45 menit       │
└──────────────────────┘

┌─ All Schedules ───────┐
│ 🟢 08:00 – 09:30 🔔   │
│ Kuliah Algoritma      │
│ [Sedang berlangsung]  │
│ [Edit] [Hapus]        │
└───────────────────────┘
```

---

## 🎯 Key Improvements

✅ More intuitive time input (start & end)
✅ Real-time status updates
✅ Better visual hierarchy
✅ Easier to understand duration
✅ Next event visibility
✅ Modern, professional design
✅ Better mobile UX
✅ Backward compatible

---

**Version:** 2.0.0

**Release Date:** May 13, 2026

**Status:** READY TO USE ✅
