import 'package:flutter/material.dart';

/// Warna-warna untuk aplikasi CampusBuddy - Light Modern Theme
class AppColors {
  // Primary Colors - Modern Blue (more vibrant)
  static const Color primary = Color(0xFF2563EB); // Modern Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFDBEAFE);

  // Secondary Colors - Soft Purple (more vibrant)
  static const Color secondary = Color(0xFF8B5CF6); // Soft Purple
  static const Color secondaryDark = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFF3E8FF);

  // Accent Colors
  static const Color accent = Color(0xFF06B6D4); // Cyan
  static const Color accentDark = Color(0xFF0891B2);

  // Status Colors
  static const Color success = Color(0xFF34D399); // Soft Green
  static const Color warning = Color(0xFFFCD34D); // Soft Yellow
  static const Color error = Color(0xFFF87171); // Soft Red

  // Background & Surface - Light Mode (CLEAN)
  static const Color lightBg = Color(0xFFFBFCFE); // Almost white
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightBorder = Color(0xFFE8EAED); // Light gray
  static const Color lightText = Color(0xFF1F2937); // Dark gray
  static const Color lightSubText = Color(0xFF6B7280); // Medium gray

  // Dark Mode (DEPRECATED - akan dihapus di versi depan)
  static const Color darkBg = Color(0xFFFBFCFE);
  static const Color darkSurface = Color(0xFFFFFFFF);
  static const Color darkBorder = Color(0xFFE8EAED);
  static const Color darkText = Color(0xFF1F2937);
  static const Color darkSubText = Color(0xFF6B7280);

  // Category Colors - Soft & Modern
  static const Color categoryTugas = Color(0xFF5B7FFF); // Soft Blue
  static const Color categoryScan = Color(0xFFB592FF); // Soft Purple
  static const Color categoryKeuangan = Color(0xFF34D399); // Soft Green
  static const Color categoryJadwal = Color(0xFFFCD34D); // Soft Yellow

  // Additional Soft Colors
  static const Color softRed = Color(0xFFF87171);
  static const Color softOrange = Color(0xFFFB923C);
  static const Color softPink = Color(0xFFF472B6);
  static const Color softCyan = Color(0xFF06B6D4);
  static const Color softGray = Color(0xFFD1D5DB);
  static const Color lightGray = Color(0xFFF3F4F6);

  // Neon Colors for special effects
  static const Color neonBlue = Color(0xFF00BFFF); // Bright blue
  static const Color neonPurple = Color(0xFF9D4EDD); // Bright purple
  static const Color veryLightGray = Color(0xFFFAFBFC);

  // Gradients - Soft & Modern
  static const List<Color> gradientPrimary = [
    Color(0xFF5B7FFF),
    Color(0xFF7DD3FC),
  ];
  static const List<Color> gradientSecondary = [
    Color(0xFFB592FF),
    Color(0xFFF472B6),
  ];
  static const List<Color> gradientSoft = [
    Color(0xFFFBFCFE),
    Color(0xFFF0F4FF),
  ];
}
