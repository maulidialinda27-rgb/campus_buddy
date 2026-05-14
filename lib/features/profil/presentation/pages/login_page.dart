import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';
import 'package:campus_buddy/services/user_service.dart';

/// LoginPage - Halaman login dengan input nama dan email
/// Fitur:
/// - Input nama dan email dengan validasi
/// - Simpan data ke SharedPreferences
/// - Navigasi ke home setelah login
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk input
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  // Form key untuk validasi
  late GlobalKey<FormState> _formKey;

  // Loading state
  bool _isLoading = false;

  // User service
  late UserService _userService;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _userService = UserService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Validasi email sederhana
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Fungsi login
  void _handleLogin() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      // Simpan data user
      bool success = await _userService.saveUser(name: name, email: email);

      if (success) {
        // Tampilkan snackbar success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selamat datang, $name!'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigasi ke Home
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          });
        }
      } else {
        // Tampilkan error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan data. Silakan coba lagi.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                // Header dengan animasi
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: [
                      // Icon/Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.gradientPrimary,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.school_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        'CampusBuddy',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Manajemen Kampus Terpadu',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkSubText
                              : AppColors.lightSubText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Form dengan animasi
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Input Nama
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Nama Lengkap',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: AppColors.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.error,
                              ),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkSurface
                                : Colors.white,
                          ),
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            if (value.length < 3) {
                              return 'Nama minimal 3 karakter';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Input Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColors.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.error,
                              ),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkSurface
                                : Colors.white,
                          ),
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!_isValidEmail(value)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Tombol Masuk
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 800),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withOpacity(
                          0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Masuk',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Info text
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'Login dengan nama dan email Anda\nuntuk memulai',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkSubText
                          : AppColors.lightSubText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
