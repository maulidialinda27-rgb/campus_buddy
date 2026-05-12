# 🧪 Testing Guide - Login & Profil Feature

## Panduan Lengkap untuk Test Fitur Login & Profil

---

## 📋 Pre-Testing Checklist

- [ ] Flutter environment sudah setup
- [ ] Dependencies sudah di-install (`flutter pub get`)
- [ ] Device/Emulator sudah tersedia dan berjalan
- [ ] Build folder sudah di-clear (`flutter clean`)

---

## 🎬 Test Scenario 1: First Time Login

### Steps:
1. **Clean & Build**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Expected Result:**
   - App membuka dengan **LoginPage**
   - Ada logo CampusBuddy
   - Ada 2 input field (Nama, Email)
   - Ada tombol "Masuk"

3. **Test Input Validation:**
   ```
   Test Case 1a: Nama kosong
   - Input: (kosong)
   - Expected: Error "Nama tidak boleh kosong"
   
   Test Case 1b: Nama terlalu pendek
   - Input: "AB"
   - Expected: Error "Nama minimal 3 karakter"
   
   Test Case 1c: Email kosong
   - Input: (kosong)
   - Expected: Error "Email tidak boleh kosong"
   
   Test Case 1d: Email format invalid
   - Input: "notanemail"
   - Expected: Error "Format email tidak valid"
   
   Test Case 1e: Valid input
   - Input: Name="Ahmad Reza", Email="ahmad@email.com"
   - Expected: Tombol bisa ditekan
   ```

4. **Test Login Success:**
   ```
   Input:
   - Nama: Ahmad Reza
   - Email: ahmad@email.com
   
   Expected:
   - Loading spinner muncul 1-2 detik
   - SnackBar hijau: "Selamat datang, Ahmad Reza!"
   - Auto-navigate ke HomePage
   - Data tersimpan di SharedPreferences
   ```

---

## 🎬 Test Scenario 2: Profile Page

### Steps:
1. **From HomePage, tap Profile menu** (icon person di bottom nav)

2. **Expected UI:**
   - Avatar bulat dengan gradient indigo-cyan
   - Nama: "Ahmad Reza" (besar, bold)
   - Email: "ahmad@email.com" (kecil, subtile)
   - Section "Pengaturan" dengan:
     - Dark Mode toggle
     - Notifikasi toggle
   - Section "Informasi":
     - Tentang Aplikasi button
   - Section "Akun":
     - Logout button (merah)

3. **Test Dark Mode Toggle:**
   ```
   Test Case 2a: Toggle On
   - Tap switch "Mode Gelap"
   - Expected: 
     * Switch berubah ke posisi ON
     * UI berubah ke dark mode
     * Data tersimpan
   
   Test Case 2b: Toggle Off
   - Tap switch "Mode Gelap" again
   - Expected:
     * Switch berubah ke posisi OFF
     * UI kembali ke light mode
     * Data tersimpan
   ```

4. **Test Notification Toggle:**
   ```
   Similar to Dark Mode toggle
   ```

5. **Test Tentang Aplikasi:**
   ```
   - Tap "Tentang Aplikasi"
   - Expected: Dialog muncul dengan:
     * Logo CampusBuddy
     * Title: "CampusBuddy"
     * Version: "1.0.0"
     * Description
     * Fitur Utama list
     * Tombol "Tutup"
   
   - Tap "Tutup"
   - Expected: Dialog tertutup
   ```

---

## 🎬 Test Scenario 3: Logout

### Steps:
1. **From ProfilePage, tap Logout button**

2. **Expected: Confirmation Dialog**
   - Title: "Logout?"
   - Message: "Apakah Anda yakin ingin keluar?..."
   - 2 buttons: "Batal" & "Logout"

3. **Test Case 3a: Cancel Logout**
   ```
   - Tap "Batal"
   - Expected: Dialog tertutup, masih di ProfilePage
   ```

4. **Test Case 3b: Confirm Logout**
   ```
   - Tap "Logout"
   - Expected:
     * Dialog tertutup
     * Auto-navigate ke LoginPage
     * Data user dihapus dari SharedPreferences
     * Field input kosong kembali
   ```

---

## 🎬 Test Scenario 4: Auto-Login

### Steps:
1. **Login terlebih dahulu** (dari Test Scenario 1)

2. **Restart App**
   ```bash
   # Tekan R di terminal untuk hot reload
   # Atau tekan Shift+R untuk hot restart
   # Atau tutup & buka app manual
   ```

3. **Expected:**
   - App langsung menampilkan **HomePage** (TIDAK ke LoginPage)
   - Tidak perlu input nama/email lagi
   - Data user masih tersimpan

4. **Verify Data:**
   - Buka ProfilePage
   - Check nama & email masih sama dengan yang di-login sebelumnya

---

## 🎬 Test Scenario 5: Persistent Data (After Restart)

### Steps:
1. **Setup: Login dengan data tertentu**
   ```
   Nama: Budi Santoso
   Email: budi@student.com
   Dark Mode: ON
   Notification: OFF
   ```

2. **Close app completely** (force close atau tutup emulator)

3. **Reopen app**
   ```bash
   flutter run
   ```

4. **Expected:**
   - Auto-login ke HomePage ✅
   - ProfilePage menampilkan data yang sama ✅
   - Dark Mode masih ON ✅
   - Notification masih OFF ✅

---

## 🎬 Test Scenario 6: Edge Cases

### Test Case 6a: Very Long Input
```
Nama: "Muhammad Reza Pratama Yusup Rondho Santoso Budi Utomo"
Email: "verylongemailaddresswithonetofmorecharactersthanusual@university.edu"

Expected:
- Input accepted (no crash)
- Display properly (text wrapping if needed)
- Saved successfully
```

### Test Case 6b: Special Characters
```
Nama: "Ahmad_Reza-123"
Email: "ahmad.reza+test@university.co.id"

Expected:
- Input accepted
- Email validation passes
- Saved successfully
```

### Test Case 6c: Rapid Clicking
```
- Tap "Masuk" button multiple times rapidly
- Expected: Only one login attempt, no duplicate entries
```

### Test Case 6d: Memory/Storage Issue
```
- Fill SharedPreferences with lots of data
- Expected: App still works normally
```

---

## 🎬 Test Scenario 7: UI Responsiveness

### Test Case 7a: Different Screen Sizes
```
- Test on phone (5-6 inch)
- Test on tablet (7+ inch)
- Expected: UI responsive, no overflow, proper spacing
```

### Test Case 7b: Landscape Mode
```
- Rotate device to landscape
- Expected: UI adapts properly (if implemented)
```

### Test Case 7c: Different Font Sizes
```
- Change system font size to large/small
- Expected: UI still readable, no layout break
```

---

## 📊 Performance Testing

### Check App Performance:
```bash
# Monitor frame rate
flutter run --profile

# Check memory usage
flutter run --profile
# Then use DevTools -> Memory tab
```

**Expected:**
- Smooth animations (60 FPS)
- No memory leaks
- App starts quickly

---

## 🔍 Debug Testing

### Check SharedPreferences Data:
```dart
// Uncomment ini di user_service.dart untuk debug
Future<void> debugPrintAllData() async {
  final keys = _prefs.getKeys();
  print('=== SharedPreferences Data ===');
  for (var key in keys) {
    print('$key: ${_prefs.get(key)}');
  }
  print('=============================');
}
```

### Check Navigation:
```bash
# Enable verbose logging
flutter run -v

# Look for navigation logs
# Search for "Navigator" in output
```

---

## ✅ Final Checklist

### Functionality
- [ ] Login dengan validasi bekerja
- [ ] Data tersimpan di SharedPreferences
- [ ] Auto-login bekerja
- [ ] Profile page menampilkan data correct
- [ ] Dark mode toggle bekerja
- [ ] Notification toggle bekerja
- [ ] Tentang app dialog tampil
- [ ] Logout bekerja dan clear data
- [ ] Navigasi smooth tanpa error

### UI/UX
- [ ] Layout responsive
- [ ] Colors konsisten
- [ ] Typography readable
- [ ] Spacing teratur
- [ ] Animasi smooth
- [ ] Icon proper
- [ ] Dark mode support baik

### Performance
- [ ] App launch cepat
- [ ] No lag saat navigate
- [ ] No crash on edge cases
- [ ] Memory usage normal

### Error Handling
- [ ] Error messages jelas
- [ ] No unhandled exceptions
- [ ] Graceful recovery

---

## 📝 Bug Report Template

Jika menemukan bug, gunakan template ini:

```
## Bug Report

### Description
[Jelaskan bug dengan detail]

### Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Expected Behavior
[Apa yang seharusnya terjadi]

### Actual Behavior
[Apa yang benar-benar terjadi]

### Screenshots/Logs
[Attach screenshot atau error log]

### Device Info
- Device: [e.g., Pixel 4, iPhone 12]
- OS: [e.g., Android 11, iOS 14]
- App Version: 1.0.0
```

---

## 🎉 Test Complete!

Jika semua test scenario berhasil, fitur Login & Profil sudah **PRODUCTION READY** ✅

---

**Last Updated**: May 2024
**Version**: 1.0.0
