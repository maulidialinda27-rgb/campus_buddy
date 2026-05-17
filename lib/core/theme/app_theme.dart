import 'package:flutter/material.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';

/// Modern Light Theme for CampusBuddy
/// Clean, minimalist design with soft colors
class AppTheme {
  /// Light Theme - Primary theme for the app
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBg,
    
    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    ),

    // Text Theme
    textTheme: _buildTextTheme(isDark: false),

    // AppBar Theme
    appBarTheme: _buildAppBarTheme(isDark: false),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: _buildBottomNavTheme(isDark: false),

    // Chip Theme
    chipTheme: _buildChipTheme(isDark: false),

    // Input Decoration Theme
    inputDecorationTheme: _buildInputDecorationTheme(isDark: false),

    // FAB Theme
    floatingActionButtonTheme: _buildFabTheme(isDark: false),

    // Card Theme
    cardTheme: _buildCardTheme(isDark: false),

    // Dialog Theme
    dialogTheme: _buildDialogTheme(isDark: false),

    // Button Themes
    elevatedButtonTheme: _buildElevatedButtonTheme(isDark: false),
    outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: false),
    textButtonTheme: _buildTextButtonTheme(isDark: false),
  );

  /// Dark Theme - Elegant Dark Navy theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.darkBg,
    
    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    ),

    // Text Theme
    textTheme: _buildTextTheme(isDark: true),

    // AppBar Theme
    appBarTheme: _buildAppBarTheme(isDark: true),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: _buildBottomNavTheme(isDark: true),

    // Chip Theme
    chipTheme: _buildChipTheme(isDark: true),

    // Input Decoration Theme
    inputDecorationTheme: _buildInputDecorationTheme(isDark: true),

    // FAB Theme
    floatingActionButtonTheme: _buildFabTheme(isDark: true),

    // Card Theme
    cardTheme: _buildCardTheme(isDark: true),

    // Dialog Theme
    dialogTheme: _buildDialogTheme(isDark: true),

    // Button Themes
    elevatedButtonTheme: _buildElevatedButtonTheme(isDark: true),
    outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: true),
    textButtonTheme: _buildTextButtonTheme(isDark: true),
  );


  /// Text Theme - Clean & Readable
  static TextTheme _buildTextTheme({required bool isDark}) {
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subTextColor = isDark ? AppColors.darkSubText : AppColors.lightSubText;
    
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: subTextColor,
      ),
      labelLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: subTextColor,
      ),
      labelSmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: subTextColor,
      ),
    );
  }

  /// AppBar Theme - Clean white with subtle shadow
  static AppBarTheme _buildAppBarTheme({required bool isDark}) {
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final iconColor = isDark ? AppColors.primaryDark : AppColors.primary;
    final shadowColor = textColor.withValues(alpha: 0.08);

    return AppBarTheme(
      backgroundColor: bgColor,
      foregroundColor: textColor,
      elevation: 2,
      shadowColor: shadowColor,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      iconTheme: IconThemeData(color: iconColor, size: 24),
    );
  }

  /// Bottom Navigation Bar Theme
  static BottomNavigationBarThemeData _buildBottomNavTheme({required bool isDark}) {
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final selectedColor = isDark ? AppColors.primaryDark : AppColors.primary;
    final unselectedColor = isDark ? AppColors.darkSubText : AppColors.lightSubText;

    return BottomNavigationBarThemeData(
      backgroundColor: bgColor,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      selectedLabelStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: selectedColor,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: unselectedColor,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      showUnselectedLabels: true,
      enableFeedback: true,
    );
  }

  /// Chip Theme
  static ChipThemeData _buildChipTheme({required bool isDark}) {
    final bgColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final selectedColor = isDark ? AppColors.primaryDark : AppColors.primary;

    return ChipThemeData(
      backgroundColor: bgColor,
      disabledColor: isDark ? AppColors.gray600 : AppColors.gray100,
      selectedColor: selectedColor,
      secondarySelectedColor: AppColors.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      secondaryLabelStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
  }

  /// Input Decoration Theme - Clean & Simple
  static InputDecorationTheme _buildInputDecorationTheme({required bool isDark}) {
    final fillColor = isDark ? AppColors.darkBg : AppColors.gray100;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final focusColor = isDark ? AppColors.primaryDark : AppColors.primary;
    final subTextColor = isDark ? AppColors.darkSubText : AppColors.lightSubText;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: subTextColor,
      ),
      hintStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: subTextColor,
      ),
      errorStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.error,
      ),
    );
  }

  /// FAB Theme - Soft shadow with modern styling
  static FloatingActionButtonThemeData _buildFabTheme({required bool isDark}) {
    return FloatingActionButtonThemeData(
      backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      hoverElevation: 10,
      highlightElevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  /// Card Theme - Light & Clean with subtle shadow
  static CardThemeData _buildCardTheme({required bool isDark}) {
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final shadowColor = (isDark ? Colors.black : AppColors.lightText).withValues(alpha: 0.08);

    return CardThemeData(
      color: bgColor,
      elevation: 2,
      shadowColor: shadowColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 0.5),
      ),
    );
  }

  /// Dialog Theme
  static DialogThemeData _buildDialogTheme({required bool isDark}) {
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return DialogThemeData(
      backgroundColor: bgColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      contentTextStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
    );
  }

  /// Elevated Button Theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme({required bool isDark}) {
    final bgColor = isDark ? AppColors.primaryDark : AppColors.primary;

    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        textStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Outlined Button Theme
  static OutlinedButtonThemeData _buildOutlinedButtonTheme({required bool isDark}) {
    final color = isDark ? AppColors.primaryDark : AppColors.primary;

    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Text Button Theme
  static TextButtonThemeData _buildTextButtonTheme({required bool isDark}) {
    final color = isDark ? AppColors.primaryDark : AppColors.primary;

    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
