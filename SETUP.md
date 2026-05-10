# SETUP GUIDE - CampusBuddy

## 🚀 Panduan Setup Awal CampusBuddy

Dokumen ini berisi panduan lengkap untuk setup awal dan menjalankan aplikasi CampusBuddy.

---

## ✅ Prerequisites

Sebelum memulai, pastikan Anda sudah menginstall:

### 1. Flutter SDK

- **Download**: https://flutter.dev/docs/get-started/install
- **Version**: 3.11.0 atau lebih baru
- **Verifikasi**:
  ```bash
  flutter --version
  ```

### 2. Dart SDK

- Sudah included dalam Flutter SDK
- **Verifikasi**:
  ```bash
  dart --version
  ```

### 3. IDE (Pilih salah satu)

- **Android Studio** (Recommended)
  - Download: https://developer.android.com/studio
  - Install Flutter & Dart plugins
- **Visual Studio Code**
  - Download: https://code.visualstudio.com/
  - Install Flutter & Dart extensions

### 4. Android Setup (untuk testing di Android)

- Android SDK
- Android Emulator atau Physical Device
- Min SDK: API 21 (Android 5.0)

### 5. iOS Setup (untuk testing di iOS)

- macOS
- Xcode
- CocoaPods

---

## 📦 Project Setup

### Step 1: Clone Repository

```bash
# Clone project
git clone https://github.com/username/campus_buddy.git

# Masuk ke folder
cd campus_buddy
```

### Step 2: Install Dependencies

```bash
# Download semua dependencies
flutter pub get

# Verify pub get berhasil
flutter pub global activate
```

### Step 3: Setup Database

Database akan otomatis dibuat saat aplikasi pertama kali dijalankan.

Jika ingin reset database:

```bash
# Delete app dan reinstall
flutter clean
flutter pub get
```

### Step 4: Verify Setup

```bash
# Check Flutter environment
flutter doctor

# Analyze code
flutter analyze

# Output should show:
# Analyzing campus_buddy...
# [info messages yang tidak kritis]
# [finished without errors]
```

---

## 🎯 Running the App

### Development Mode

```bash
# Run di device/emulator yang terhubung
flutter run

# Run dengan verbose output
flutter run -v

# Run dengan specific device
flutter run -d <device_id>
```

### Get List of Available Devices

```bash
flutter devices
```

### Hot Reload & Hot Restart

```bash
# Dalam flutter run session:
# Press 'r' untuk hot reload
# Press 'R' untuk hot restart
# Press 'q' untuk quit
```

### Release Mode

```bash
# Run di release mode (lebih cepat)
flutter run --release
```

---

## 🔨 Building APK

### Build Debug APK

```bash
flutter build apk
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Build Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build APK Split by ABI

```bash
flutter build apk --split-per-abi --release
# Output untuk:
# - arm64-v8a
# - armeabi-v7a
# - x86_64
```

### Build AAB (Android App Bundle)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 🏗️ Building for iOS

### Build iOS App

```bash
flutter build ios --release

# Output dapat di-upload ke App Store
```

### Catatan

- Memerlukan Apple Developer Account
- Memerlukan provisioning profile
- Lebih detail di Apple Developer Documentation

---

## 📱 Testing di Emulator

### Android Emulator

```bash
# List available emulators
emulator -list-avds

# Launch emulator
emulator -avd <emulator_name>

# Run app
flutter run
```

### iOS Simulator

```bash
# List simulators
xcrun simctl list devices

# Launch simulator
open /Applications/Simulator.app

# Run app
flutter run
```

---

## 🐛 Troubleshooting

### Problem: Flutter tidak recognize

**Solution:**

```bash
# Add Flutter to PATH (Windows)
# Edit Environment Variables > Path
# Add: C:\path\to\flutter\bin

# Verify
flutter --version
```

### Problem: Devices tidak terdeteksi

**Solution:**

```bash
# Android
adb devices

# Jika tidak muncul, enable USB Debugging di device
# Settings > Developer Options > USB Debugging

# Verify connection
flutter devices
```

### Problem: Build error: "SDK version too high"

**Solution:**

```bash
# Update Flutter
flutter upgrade

# Update dependencies
flutter pub get

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Problem: Hot reload tidak bekerja

**Solution:**

```bash
# Stop flutter run
# Run tanpa fast-start
flutter run --no-fast-start
```

### Problem: Database corrupted

**Solution:**

```bash
# Clean project
flutter clean

# Delete build folders
rm -rf build/ ios/ android/

# Get dependencies
flutter pub get

# Run again
flutter run
```

### Problem: Memory error saat build

**Solution:**

```bash
# Tambah memory untuk gradle
# File: android/gradle.properties
# Tambahkan:
org.gradle.jvmargs=-Xmx2048m
```

---

## 📋 Project Structure Verification

Verifikasi struktur project sudah sesuai:

```
campus_buddy/
├── .git/                      # Git repository
├── .gitignore
├── android/                   # Android native code
├── ios/                       # iOS native code
├── linux/                     # Linux native code
├── macos/                     # macOS native code
├── windows/                   # Windows native code
├── lib/
│   ├── core/                  # Core utilities
│   ├── features/              # App features
│   ├── widgets/               # Reusable widgets
│   ├── database/              # Database setup
│   ├── models/                # Data models
│   ├── app.dart
│   └── main.dart
├── test/                      # Unit tests
├── pubspec.yaml               # Dependencies
├── analysis_options.yaml      # Lint rules
├── README.md                  # Main documentation
├── SETUP.md                   # Setup guide
└── DEVELOPMENT_GUIDE.md       # Development guide
```

---

## 🔐 Environment Setup

### Setting up Git

```bash
# Configure git (first time only)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify
git config --list
```

### SSH Key for GitHub (Optional)

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to GitHub
# Paste content dari ~/.ssh/id_ed25519.pub ke GitHub SSH settings
```

---

## 💾 Database Initialization

Database akan otomatis dibuat dengan struktur berikut:

### Tables Created:

1. **tugas** - Manajemen tugas
2. **scan** - Catatan foto
3. **keuangan** - Pengeluaran
4. **jadwal** - Jadwal kegiatan
5. **profil** - Informasi pengguna

Jika ingin membuat database dari scratch:

```dart
// File: lib/database/database_helper.dart sudah handle ini
// Cukup jalankan aplikasi untuk auto-initialize
```

---

## 🎨 Customization

### Change App Name

```dart
// File: pubspec.yaml
name: campus_buddy

// Android: android/app/build.gradle
applicationId "com.example.campus_buddy"

// iOS: ios/Runner/Info.plist
<key>CFBundleName</key>
<string>CampusBuddy</string>
```

### Change App Icon

```bash
# Prepare icon (1024x1024 PNG)
# Place at: assets/icon/icon.png

# Generate icons
flutter pub get
flutter pub run flutter_launcher_icons:main

# Output akan update di:
# - android/app/src/main/res/
# - ios/Runner/Assets.xcassets/
```

### Change App Splash Screen

- Gunakan flutter_native_splash package
- atau customize secara manual di native code

---

## 📊 Project Statistics

### Current Status

- ✅ Project Structure Created
- ✅ Dependencies Installed
- ✅ Theme Setup Complete
- ✅ Database Schema Ready
- ✅ Navigation Structure Ready
- 🔄 Feature Implementation (In Progress)

### Code Metrics

- Total Files: 30+
- Core Files: 15
- Feature Files: 15+
- Lines of Code: 2000+

---

## 📞 Getting Help

### Documentation Links

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [GetX Documentation](https://github.com/jonataslaw/getx)

### Common Errors

- Check `flutter doctor` output
- Read error message carefully
- Search issue on GitHub
- Create new issue if not found

---

## ✅ Verification Checklist

- [ ] Flutter installed (version 3.11+)
- [ ] IDE setup dengan Flutter plugin
- [ ] Android SDK/Emulator tersedia
- [ ] Project cloned
- [ ] Dependencies installed (`flutter pub get`)
- [ ] No analyze errors (`flutter analyze`)
- [ ] App runs successfully (`flutter run`)
- [ ] Database initialized
- [ ] Navigation working
- [ ] Dark mode toggle working

---

## 🎓 Next Steps

Setelah setup selesai:

1. **Pelajari Project Structure**
   - Baca DEVELOPMENT_GUIDE.md
   - Explore folder structure

2. **Setup Development Environment**
   - Configure IDE
   - Setup debugging tools

3. **Start Development**
   - Pick a feature to implement
   - Follow DEVELOPMENT_GUIDE.md
   - Test thoroughly

4. **Version Control**
   - Commit regularly
   - Use meaningful commit messages
   - Push weekly

---

## 📝 Important Notes

- Database adalah local storage (tidak cloud)
- Notifications require proper permissions
- Image picker needs camera/gallery permissions
- Test di Android dan iOS untuk compatibility

---

**Setup selesai! Siap untuk development! 🚀**

Last Updated: May 10, 2026
