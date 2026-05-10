# CampusBuddy - Aplikasi Asisten Mahasiswa

![Flutter](https://img.shields.io/badge/Flutter-3.11+-blue)
![Dart](https://img.shields.io/badge/Dart-3.11+-blue)
![Database](https://img.shields.io/badge/Database-SQLite-lightgrey)

## 📱 Deskripsi Aplikasi

**CampusBuddy** adalah aplikasi mobile multifungsi berbasis Flutter yang dirancang khusus untuk membantu mahasiswa dalam mengelola berbagai kebutuhan akademik dan aktivitas harian secara lebih efisien dan terorganisir.

Aplikasi ini menyediakan solusi terintegrasi dalam satu platform untuk:

- Mengelola tugas dan deadline
- Mencatat materi kuliah dengan fitur scan
- Mengontrol pengeluaran keuangan harian
- Mengatur jadwal kegiatan dengan notifikasi otomatis
- Melihat ringkasan aktivitas di dashboard

## 🎯 Target Pengguna

- Mahasiswa aktif
- Pelajar tingkat akhir
- Pengguna dengan aktivitas harian yang padat

## 🚀 Fitur Utama

### 1. **Dashboard (Beranda)**

- Ringkasan tugas terdekat
- Jadwal hari ini
- Pengeluaran hari ini
- Catatan terbaru
- Quick access ke semua fitur

### 2. **Manajemen Tugas (StudyMate)** 📋

- ✅ Menambahkan tugas baru
- ✅ Menetapkan deadline
- ✅ Mengatur prioritas
- ✅ Menandai tugas selesai/belum
- ✅ Edit dan hapus tugas
- ✅ Filter berdasarkan status dan prioritas

### 3. **Scan & Catatan (Scan2Note)** 📸

- ✅ Mengambil foto catatan dari kamera
- ✅ Pilih dari galeri
- ✅ Menambahkan judul dan deskripsi
- ✅ Menyimpan catatan dalam bentuk foto

### 4. **Manajemen Keuangan (KostBudget)** 💰

- ✅ Menambahkan pengeluaran
- ✅ Kategorisasi pengeluaran
- ✅ Menampilkan total pengeluaran
- ✅ Ringkasan keuangan

### 5. **Jadwal & Notifikasi** 📅

- ✅ Menambahkan jadwal kegiatan
- ✅ Menetapkan hari dan jam
- ✅ Notifikasi pengingat otomatis

### 6. **Profil Pengguna** 👤

- ✅ Informasi pengguna
- ✅ Pengaturan aplikasi
- ✅ Dark Mode support

## 🏗️ Arsitektur Aplikasi

Aplikasi menggunakan **Clean Architecture** dengan struktur folder:

```
lib/
 ├── core/
 │    ├── theme/           # Tema Light & Dark
 │    ├── utils/           # Utility functions
 │    └── constants/       # Konstanta & warna
 ├── features/             # Fitur-fitur aplikasi
 │    ├── home/
 │    ├── tugas/
 │    ├── scan/
 │    ├── keuangan/
 │    ├── jadwal/
 │    └── profil/
 ├── database/             # SQLite setup
 ├── models/               # Data models
 ├── widgets/              # Reusable widgets
 └── main.dart
```

## 🛠️ Technologies Used

- **Framework**: Flutter 3.11+
- **Language**: Dart 3.11+
- **Database**: SQLite
- **UI Framework**: Material Design 3
- **Fonts**: Google Fonts (Plus Jakarta Sans)
- **Animations**: Lottie, Animate Do
- **State Management**: GetX
- **Notifications**: flutter_local_notifications

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^7.0.0
  sqflite: ^2.3.0
  path: ^1.8.3
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.2
  lottie: ^3.0.0
  animate_do: ^3.1.2
  image_picker: ^1.1.0
  intl: ^0.19.0
  uuid: ^4.0.0
  get: ^4.6.5
```

## 🎨 Design Features

- Minimalis & Modern Interface
- Material Design 3 Components
- Dark Mode Support
- Glassmorphism Effects
- Smooth Animations
- Responsive Layout

## 💾 Database Schema

### Tables

- **tugas**: Manajemen tugas
- **scan**: Catatan foto
- **keuangan**: Pengeluaran
- **jadwal**: Jadwal kegiatan
- **profil**: Informasi pengguna

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.11+
- Dart SDK 3.11+

### Installation

```bash
# Clone repository
git clone <repository-url>
cd campus_buddy

# Install dependencies
flutter pub get

# Run aplikasi
flutter run

# Build APK
flutter build apk --release
```

## 📱 Platform Support

- ✅ Android 5.0+
- ✅ iOS 11.0+
- 🔄 Web (In Development)
- 🔄 macOS (In Development)
- 🔄 Windows (In Development)

## 📋 Roadmap

- [ ] Cloud Synchronization
- [ ] Export Data (PDF/Excel)
- [ ] Social Sharing
- [ ] Collaborative Tasks
- [ ] Advanced Analytics
- [ ] Calendar Integration
- [ ] Offline Support
- [ ] Multiple Languages

## 🐛 Troubleshooting

```bash
# Clean build
flutter clean
flutter pub get
flutter run

# Hot reload issues
flutter run --no-fast-start
```

## 📄 License

Academic Project - CampusBuddy

## 👨‍💻 Author

Mahasiswa IT - CampusBuddy Developer

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

**CampusBuddy** - Membuat Hidup Mahasiswa Lebih Terorganisir ✨

Last Updated: May 10, 2026
