import 'package:shared_preferences/shared_preferences.dart';

/// UserService mengelola data user menggunakan SharedPreferences
/// Digunakan untuk menyimpan, mengambil, dan menghapus data user secara lokal
class UserService {
  // Konstanta untuk kunci SharedPreferences
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyDarkMode = 'darkMode';
  static const String _keyNotification = 'notification';

  // Private constructor - singleton pattern
  UserService._();

  // Instance singleton
  static final UserService _instance = UserService._();

  // Factory constructor untuk mendapatkan instance
  factory UserService() {
    return _instance;
  }

  // Variabel untuk SharedPreferences
  late SharedPreferences _prefs;

  /// Inisialisasi SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Simpan data user (login)
  /// Parameter: [name] nama user, [email] email user
  Future<bool> saveUser({required String name, required String email}) async {
    try {
      await _prefs.setString(_keyUserName, name);
      await _prefs.setString(_keyUserEmail, email);
      await _prefs.setBool(_keyIsLoggedIn, true);
      return true;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  /// Ambil nama user
  String? getUserName() {
    return _prefs.getString(_keyUserName);
  }

  /// Ambil email user
  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  /// Cek apakah user sudah login
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Simpan preferensi dark mode
  Future<bool> setDarkMode(bool isDark) async {
    try {
      await _prefs.setBool(_keyDarkMode, isDark);
      return true;
    } catch (e) {
      print('Error setting dark mode: $e');
      return false;
    }
  }

  /// Ambil preferensi dark mode
  bool getDarkMode() {
    return _prefs.getBool(_keyDarkMode) ?? false;
  }

  /// Simpan preferensi notifikasi
  Future<bool> setNotification(bool isEnabled) async {
    try {
      await _prefs.setBool(_keyNotification, isEnabled);
      return true;
    } catch (e) {
      print('Error setting notification: $e');
      return false;
    }
  }

  /// Ambil preferensi notifikasi
  bool getNotification() {
    return _prefs.getBool(_keyNotification) ?? true;
  }

  /// Logout - hapus semua data user
  Future<bool> logout() async {
    try {
      await _prefs.remove(_keyUserName);
      await _prefs.remove(_keyUserEmail);
      await _prefs.setBool(_keyIsLoggedIn, false);
      return true;
    } catch (e) {
      print('Error logging out: $e');
      return false;
    }
  }

  /// Hapus semua data (reset aplikasi)
  Future<bool> clearAll() async {
    try {
      await _prefs.clear();
      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }
}
