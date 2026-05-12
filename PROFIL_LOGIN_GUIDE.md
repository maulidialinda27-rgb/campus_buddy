# Dokumentasi Fitur Login & Profil CampusBuddy

## 📋 Ringkasan
Fitur Login & Profil telah diimplementasikan dengan lengkap, menggunakan SharedPreferences untuk penyimpanan data lokal tanpa backend.

---

## 🎯 Fitur Utama

### 1. **Sistem Login Sederhana**
**File**: `lib/features/profil/presentation/pages/login_page.dart`

**Fitur:**
- Input nama dan email dengan validasi
- Validasi email format
- Minimal 3 karakter untuk nama
- Simpan data ke SharedPreferences secara otomatis
- UI modern dengan animasi fade-in
- Loading state saat proses login
- Error handling dengan SnackBar

**Contoh Validasi:**
```dart
// Nama minimal 3 karakter
if (value.length < 3) {
  return 'Nama minimal 3 karakter';
}

// Email format validation
bool _isValidEmail(String email) {
  return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
      .hasMatch(email);
}
```

---

### 2. **Halaman Profil Modern**
**File**: `lib/features/profil/presentation/pages/profil_page.dart`

**Fitur:**
- Avatar bulat dengan gradient
- Tampilkan nama dan email user
- Animasi saat halaman dibuka
- Section "Pengaturan" dengan toggle switches:
  - Dark Mode toggle
  - Notifikasi toggle
- Section "Informasi":
  - Tentang Aplikasi (dialog info)
- Section "Akun":
  - Logout dengan konfirmasi

**UI Design:**
- Card dengan shadow effect
- Spacing yang rapi (12px, 16px, 20px, 24px)
- Responsive color (light/dark mode)
- Icon dengan background color
- Smooth transitions dan animations

---

### 3. **Layanan User (UserService)**
**File**: `lib/services/user_service.dart`

**Singleton Pattern** untuk manajemen data:

```dart
// Instance singleton
static final UserService _instance = UserService._();

factory UserService() {
  return _instance;
}
```

**Methods:**
```dart
// Inisialisasi
await _userService.init();

// Save user (login)
await _userService.saveUser(name: 'John', email: 'john@email.com');

// Ambil data
String? name = _userService.getUserName();
String? email = _userService.getUserEmail();

// Check login status
bool isLogged = _userService.isLoggedIn();

// Settings
await _userService.setDarkMode(true);
await _userService.setNotification(false);

// Logout
await _userService.logout();
```

---

### 4. **Auto-Login System**
**File**: `lib/app.dart`

**Proses:**
1. App dibuka → `CampusBuddyApp` (StatefulWidget)
2. `initState` → inisialisasi UserService & cek status login
3. Loading screen ditampilkan selama proses init
4. Jika sudah login → Langsung ke HomePage
5. Jika belum login → Tampilkan LoginPage

**Implementation:**
```dart
@override
void initState() {
  super.initState();
  _initializeApp();
}

Future<void> _initializeApp() async {
  _userService = UserService();
  await _userService.init();
  bool loggedIn = _userService.isLoggedIn();
  setState(() {
    _isLoggedIn = loggedIn;
    _isLoading = false;
  });
}
```

---

### 5. **Named Routes**
**Di app.dart:**
```dart
routes: {
  '/home': (context) => const HomePage(),
  '/login': (context) => const LoginPage(),
  '/profile': (context) => const ProfilePage(),
},
```

**Navigasi:**
```dart
// Dari login ke home (after login success)
Navigator.of(context).pushReplacementNamed('/home');

// Dari profile logout ke login
Navigator.of(context).pushReplacementNamed('/login');
```

---

## 🗂️ Struktur File

```
lib/
├── services/
│   └── user_service.dart          # Manajemen data user
├── features/
│   └── profil/
│       └── presentation/
│           └── pages/
│               ├── login_page.dart        # Halaman login
│               ├── profil_page.dart       # Halaman profil
│               └── profile_page.dart      # Alternatif (tidak digunakan)
├── app.dart                       # Main app dengan auto-login
├── main.dart                      # Entry point
```

---

## 💾 Penyimpanan Data (SharedPreferences)

**Keys yang digunakan:**
```dart
_keyIsLoggedIn = 'isLoggedIn'
_keyUserName = 'userName'
_keyUserEmail = 'userEmail'
_keyDarkMode = 'darkMode'
_keyNotification = 'notification'
```

**Flow Penyimpanan:**
1. User login → Save ke SharedPreferences ✅
2. App dibuka → Cek isLoggedIn di SharedPreferences ✅
3. User ubah setting → Update di SharedPreferences ✅
4. User logout → Hapus data dari SharedPreferences ✅

---

## 🎨 UI/UX Design

### Color Palette (Dark Mode Compatible)
- **Primary**: #6366F1 (Indigo)
- **Secondary**: #00D4FF (Cyan)
- **Error**: #EF4444 (Red)
- **Success**: #10B981 (Green)

### Typography
- Font: Google Fonts - Plus Jakarta Sans
- Sizes: 12px, 13px, 14px, 16px, 20px, 24px, 32px
- Weights: w400, w500, w600, bold

### Spacing
- Small gap: 4px, 8px
- Medium gap: 12px, 16px, 20px
- Large gap: 24px, 28px, 32px

### Components
- Input field dengan border rounded 12px
- Button dengan rounded 12px
- Card dengan shadow & rounded 16px
- Avatar bulat dengan gradient
- Icon dengan background (rounded 8px)

---

## 🚀 Cara Menggunakan

### 1. **Setup Awal**
```dart
// main.dart sudah di-update, cukup run:
flutter run
```

### 2. **Flow Login**
```
1. Aplikasi dibuka → Cek SharedPreferences
2. Jika belum login → Tampilkan LoginPage
3. User input nama & email → Validasi
4. Klik "Masuk" → Save ke SharedPreferences
5. Success → Navigate ke HomePage
```

### 3. **Flow Profil & Logout**
```
1. Dari HomePage → Tap menu Profil
2. Tampilkan data user dari SharedPreferences
3. User bisa toggle Dark Mode & Notifikasi
4. Klik Logout → Show confirmation dialog
5. Confirm → Hapus data & Navigate ke LoginPage
```

### 4. **Testing Auto-Login**
```
1. Login dengan data apapun
2. Restart aplikasi
3. Harusnya langsung masuk ke HomePage (auto-login)
4. Jika logout → Restart aplikasi → Tampilkan LoginPage
```

---

## ⚙️ Dependency yang Ditambahkan

**pubspec.yaml:**
```yaml
dependencies:
  shared_preferences: ^2.2.2  # Local storage
  google_fonts: ^7.0.0        # Typography
  animate_do: ^3.1.2          # Animations
```

---

## 📝 Contoh Data yang Tersimpan

**SharedPreferences Storage:**
```
{
  'isLoggedIn': true,
  'userName': 'Ahmad Reza',
  'userEmail': 'ahmad@email.com',
  'darkMode': false,
  'notification': true
}
```

---

## 🔒 Security Notes

⚠️ **Important**: 
- SharedPreferences TIDAK aman untuk data sensitif seperti password
- Implementasi ini untuk demo/learning purposes
- Untuk production: gunakan `flutter_secure_storage` untuk sensitive data
- Password sebaiknya tidak disimpan sama sekali

---

## 🐛 Troubleshooting

### Masalah: Login gagal, data tidak tersimpan
**Solusi:**
```dart
// Pastikan init() dipanggil sebelum menggunakan UserService
await _userService.init();
```

### Masalah: Auto-login tidak bekerja
**Solusi:**
```dart
// Cek apakah app.dart sudah diupdate dengan stateful widget
// Dan isLoggedIn() dipanggil dengan benar
```

### Masalah: Data tidak terhapus saat logout
**Solusi:**
```dart
// Pastikan logout() menghapus semua keys
await _prefs.remove(_keyUserName);
await _prefs.remove(_keyUserEmail);
await _prefs.setBool(_keyIsLoggedIn, false);
```

---

## 📚 Referensi

- SharedPreferences: https://pub.dev/packages/shared_preferences
- Google Fonts: https://pub.dev/packages/google_fonts
- Animate Do: https://pub.dev/packages/animate_do

---

## ✅ Checklist Implementasi

- ✅ UserService dengan singleton pattern
- ✅ LoginPage dengan validasi
- ✅ ProfilPage dengan UI modern
- ✅ Auto-login system
- ✅ Dark mode toggle
- ✅ Notification toggle
- ✅ Logout functionality
- ✅ Named routes
- ✅ Error handling
- ✅ Loading states
- ✅ Responsive design
- ✅ Dark mode UI support

---

**Status**: Fitur Login & Profil SELESAI dan SIAP DIGUNAKAN ✅
