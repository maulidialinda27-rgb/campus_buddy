import 'package:flutter/material.dart';
import 'package:campus_buddy/core/theme/app_theme.dart';
import 'package:campus_buddy/features/home/presentation/pages/home_page.dart';
import 'package:campus_buddy/features/profil/presentation/pages/login_page.dart';
import 'package:campus_buddy/features/profil/presentation/pages/profile_page.dart';
import 'package:campus_buddy/services/user_service.dart';

/// Widget utama aplikasi CampusBuddy
/// Menangani:
/// - Auto-login jika user sudah pernah login
/// - Theme dan dark mode
/// - Routing aplikasi
class CampusBuddyApp extends StatefulWidget {
  const CampusBuddyApp({Key? key}) : super(key: key);

  @override
  State<CampusBuddyApp> createState() => _CampusBuddyAppState();
}

class _CampusBuddyAppState extends State<CampusBuddyApp> {
  late UserService _userService;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Inisialisasi aplikasi dan cek status login
  Future<void> _initializeApp() async {
    _userService = UserService();
    await _userService.init();

    // Cek apakah user sudah login
    bool loggedIn = _userService.isLoggedIn();

    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan splash screen saat loading
    if (_isLoading) {
      return MaterialApp(
        title: 'CampusBuddy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text('Loading CampusBuddy...'),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'CampusBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      // Arahkan ke halaman sesuai status login
      home: _isLoggedIn ? const HomePage() : const LoginPage(),
      // Named routes untuk navigasi
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
