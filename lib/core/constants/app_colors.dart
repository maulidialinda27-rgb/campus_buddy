import 'package:flutter/material.dart';

/// Warna-warna untuk aplikasi CampusBuddy - Soft Blue Minimalist Theme
/// Konsep: Modern minimalist, soft blue aesthetic, clean UI
class AppColors {
  // Main Theme Colors (Requested)
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color primary = Color(0xFF3B82F6);
  static const Color secondary = Color(0xFF60A5FA);
  static const Color accent = Color(0xFFBFDBFE);

  static const Color lightText = Color(0xFF1E293B);
  static const Color lightSubText = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightSurface = Colors.white;

  // Primary Shades
  static const Color primaryLight = Color(0xFFDBEAFE);

  // Secondary Shades
  static const Color secondaryDark = Color(0xFF3B82F6);
  static const Color secondaryLight = Color(0xFFEFF6FF);

  // Accent Shades
  static const Color accentDark = Color(0xFF93C5FD);
  static const Color accentLight = Color(0xFFEFF6FF);

  // Status Colors - Soft & Elegant
  static const Color success = Color(0xFF34D399); // Soft Green
  static const Color warning = Color(0xFFFBBF24); // Soft Yellow
  static const Color error = Color(0xFFF87171); // Soft Red
  static const Color info = Color(0xFF60A5FA); // Soft Blue

  // Gray Scale
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);

  // Category Colors - Soft & Elegant
  static const Color categoryTugas = primary;
  static const Color categoryScan = secondary;
  static const Color categoryKeuangan = success;
  static const Color categoryJadwal = warning;
  static const Color categoryOther = accent;

  // Previous Vibrant Colors mapped to Soft versions to prevent breaking
  static const Color vibrantPink = Color(0xFFF472B6);
  static const Color vibrantOrange = Color(0xFFFB923C);
  static const Color vibrantRed = error;
  static const Color vibrantCyan = Color(0xFF38BDF8);
  static const Color softGray = gray300;
  static const Color veryLightGray = gray50;

  // Backward Compatibility (Now explicitly defining Dark Navy colors)
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkText = Colors.white;
  static const Color darkSubText = Color(0xFFCBD5E1);

  // Custom dark shades for primary elements
  static const Color primaryDark = Color(0xFF60A5FA);
  static const Color lightGray = gray100;

  // No more neon, but we keep the variable names for compatibility
  static const Color neonBlue = primary;
  static const Color neonPurple = secondary;

  // Gradients - Minimalist & Soft
  static const List<Color> gradientPrimary = [
    Color(0xFF3B82F6),
    Color(0xFF60A5FA),
  ];

  static const List<Color> gradientSecondary = [
    Color(0xFF60A5FA),
    Color(0xFFBFDBFE),
  ];

  static const List<Color> gradientSuccess = [
    Color(0xFF34D399),
    Color(0xFF6EE7B7),
  ];

  static const List<Color> gradientWarning = [
    Color(0xFFFBBF24),
    Color(0xFFFCD34D),
  ];

  static const List<Color> gradientClean = [Color(0xFFF8FAFC), Colors.white];

  // Shadow Color - Thin & Natural
  static const Color shadowColor = Color(
    0xFF0F172A,
  ); // Very dark blue for natural shadow with low alpha
}
