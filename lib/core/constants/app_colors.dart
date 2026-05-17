import 'package:flutter/material.dart';

/// Warna-warna untuk aplikasi CampusBuddy - Modern Clean Colorful Theme
/// Konsep: Biru Modern, Ungu Soft, Putih, Abu Muda
class AppColors {
  // Primary Colors - Modern Blue (VIBRANT & CLEAR)
  static const Color primary = Color(0xFF3B82F6); // Bright Modern Blue
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFFDEF7FF); // Very light blue

  // Secondary Colors - Soft Purple (VIBRANT & CLEAR)
  static const Color secondary = Color(0xFFA78BFA); // Vibrant Soft Purple
  static const Color secondaryDark = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFF3E8FF);

  // Accent Colors - Additional Vibrant Colors
  static const Color accent = Color(0xFF06B6D4); // Cyan
  static const Color accentDark = Color(0xFF0891B2);
  static const Color accentLight = Color(0xFFCFFAFE);

  // Status Colors - More Vibrant
  static const Color success = Color(0xFF10B981); // Vibrant Green
  static const Color warning = Color(0xFFFCD34D); // Vibrant Yellow
  static const Color error = Color(0xFFF87171); // Vibrant Red
  static const Color info = Color(0xFF06B6D4); // Vibrant Cyan

  // Background & Surface - Clean & Modern
  static const Color lightBg = Color(0xFFFAFBFC); // Clean white-ish
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightBorder = Color(0xFFE5E7EB); // Clean light gray
  static const Color lightText = Color(0xFF111827); // Deep dark gray
  static const Color lightSubText = Color(0xFF6B7280); // Medium gray

  // Gray Scale - For sophisticated look
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);

  // Category Colors - Vibrant & Clear
  static const Color categoryTugas = Color(0xFF3B82F6); // Vibrant Blue
  static const Color categoryScan = Color(0xFFA78BFA); // Vibrant Purple
  static const Color categoryKeuangan = Color(0xFF10B981); // Vibrant Green
  static const Color categoryJadwal = Color(0xFFFCD34D); // Vibrant Yellow
  static const Color categoryOther = Color(0xFF06B6D4); // Vibrant Cyan

  // Vibrant Additional Colors - For colorful design
  static const Color vibrantPink = Color(0xFFEC4899); // Hot Pink
  static const Color vibrantOrange = Color(0xFFFB923C); // Vibrant Orange
  static const Color vibrantRed = Color(0xFFEF4444); // Vibrant Red
  static const Color vibrantCyan = Color(0xFF06B6D4); // Vibrant Cyan
  static const Color softGray = Color(0xFFD1D5DB);
  static const Color veryLightGray = Color(0xFFFAFBFC);

  // Backward Compatibility - Aliases for old color names
  static const Color darkBg = lightBg;
  static const Color darkSurface = lightSurface;
  static const Color darkBorder = lightBorder;
  static const Color darkText = lightText;
  static const Color darkSubText = lightSubText;
  static const Color lightGray = gray100;
  static const Color neonBlue = vibrantCyan;
  static const Color neonPurple = vibrantPink;

  // Gradients - Modern & Professional
  static const List<Color> gradientPrimary = [
    Color(0xFF3B82F6), // Bright Blue
    Color(0xFF06B6D4), // Cyan
  ];

  static const List<Color> gradientSecondary = [
    Color(0xFFA78BFA), // Soft Purple
    Color(0xFFEC4899), // Hot Pink
  ];

  static const List<Color> gradientSuccess = [
    Color(0xFF10B981), // Vibrant Green
    Color(0xFF34D399), // Light Green
  ];

  static const List<Color> gradientWarning = [
    Color(0xFFFCD34D), // Vibrant Yellow
    Color(0xFFFB923C), // Vibrant Orange
  ];

  static const List<Color> gradientClean = [
    Color(0xFFFAFBFC), // Light gray
    Color(0xFFFFFFFF), // Pure white
  ];

  // Shadow Color - Soft & Professional
  static const Color shadowColor = Color(0xFF000000); // For shadow with alpha
}
