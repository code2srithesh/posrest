import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_animations.dart';

class AppTheme {
  // For backward compatibility
  static const Color primaryColor = AppColors.primary;
  static const Color accentColor = AppColors.accentOrange;
  static const Color bgColor = AppColors.lightBg;
  static const Color cardBg = AppColors.lightCard;
  static const Color shadowColor = AppColors.lightShadow;
  static const Color textPrimary = AppColors.lightText;
  static const Color textSecondary = AppColors.lightTextSecondary;
  static const Color textLight = AppColors.lightTextTertiary;
  static const Color borderColor = AppColors.lightBorder;
  static const Color dividerColor = AppColors.lightDivider;
  static const Color errorColor = AppColors.error;
  static const Color successColor = AppColors.success;
  static const Color warningColor = AppColors.warning;
  static const Color infoColor = AppColors.info;

  // Table Status Colors (for backward compatibility)
  static const Color tableFreeBg = AppColors.tableAvailableBg;
  static const Color tableFreeIcon = AppColors.tableAvailable;
  static const Color tableOccupiedBg = AppColors.tableOccupiedBg;
  static const Color tableOccupiedIcon = AppColors.tableOccupied;
  static const Color tableReservedBg = AppColors.tableReservedBg;
  static const Color tableReservedIcon = AppColors.tableReserved;

  // ============ LIGHT THEME - Dark Gradient Glasmorphic ============
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accentPink,
      onSecondary: Colors.white,
      surface: AppColors.lightCard,
      onSurface: AppColors.lightText,
      error: AppColors.accentRed,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.lightBg,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    textTheme: _buildLightTextTheme(),
    appBarTheme: _buildLightAppBarTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: const Color(0x4D6B4CE6), // Purple glow
        animationDuration: AppAnimations.medium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.lightTextSecondary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.lightTextTertiary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // ============ DARK THEME - Darker Gradient Glasmorphic ============
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accentOrange,
      onSecondary: Colors.white,
      surface: AppColors.darkCard,
      onSurface: AppColors.darkText,
      error: AppColors.error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    textTheme: _buildDarkTextTheme(),
    appBarTheme: _buildDarkAppBarTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: const Color(0x4D6B4CE6), // Purple glow
        animationDuration: AppAnimations.medium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCardSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.darkTextSecondary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.darkTextTertiary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // ============ TEXT THEMES ============
  static TextTheme _buildLightTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText,
      ),
      displayMedium: GoogleFonts.sora(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText,
      ),
      displaySmall: GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText,
      ),
      headlineSmall: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.lightText,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.lightText,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.lightText,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextSecondary,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextTertiary,
      ),
    );
  }

  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
      ),
      displayMedium: GoogleFonts.sora(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
      ),
      displaySmall: GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
      ),
      headlineSmall: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextSecondary,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextTertiary,
      ),
    );
  }

  static AppBarTheme _buildLightAppBarTheme() {
    return AppBarTheme(
      backgroundColor: AppColors.lightCard,
      foregroundColor: AppColors.lightText,
      elevation: 1,
      shadowColor: AppColors.lightShadow,
      centerTitle: true,
      titleTextStyle: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText,
      ),
    );
  }

  static AppBarTheme _buildDarkAppBarTheme() {
    return AppBarTheme(
      backgroundColor: AppColors.darkCard,
      foregroundColor: AppColors.darkText,
      elevation: 1,
      shadowColor: AppColors.darkShadow,
      centerTitle: true,
      titleTextStyle: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
      ),
    );
  }
}
