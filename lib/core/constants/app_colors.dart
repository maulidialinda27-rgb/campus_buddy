import 'package:flutter/material.dart';

/// Warna-warna untuk aplikasi CampusBuddy
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFEEF2FF);

  // Secondary Colors
  static const Color secondary = Color(0xFF00D4FF);
  static const Color secondaryDark = Color(0xFF00B8E6);

  // Accent Colors
  static const Color accent = Color(0xFFFFB84D);
  static const Color accentDark = Color(0xFFFFA500);

  // Success, Warning, Error
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Neutral Colors - Light Mode
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightText = Color(0xFF1F2937);
  static const Color lightSubText = Color(0xFF6B7280);

  // Neutral Colors - Dark Mode
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkSubText = Color(0xFFCBD5E1);

  // Category Colors
  static const Color categoryTugas = Color(0xFF6366F1);
  static const Color categoryScan = Color(0xFF8B5CF6);
  static const Color categoryKeuangan = Color(0xFF10B981);
  static const Color categoryJadwal = Color(0xFFF59E0B);

  // Gradient Colors
  static const List<Color> gradientPrimary = [
    Color(0xFF6366F1),
    Color(0xFF00D4FF),
  ];
  static const List<Color> gradientSecondary = [
    Color(0xFF8B5CF6),
    Color(0xFFFF5E78),
  ];

  // Neon Colors for Futuristic Theme
  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color glowBlue = Color(0xFF00FFFF);
  static const Color glowPurple = Color(0xFF9D4EDD);
}
