import 'package:flutter/material.dart';

/// Comprehensive color palette for light and dark themes
class AppColors {
  // ============ PRIMARY PALETTE ============
  // Professional restaurant purple-blue gradient
  static const Color primaryDark = Color(0xFF5B4C93);
  static const Color primary = Color(0xFF7B68EE);
  static const Color primaryLight = Color(0xFFA99CED);
  static const Color primaryLighter = Color(0xFFE8E4F8);

  // ============ ACCENT PALETTE ============
  static const Color accentOrange = Color(0xFFFF8C42);
  static const Color accentGold = Color(0xFFFFB347);
  static const Color accentRed = Color(0xFFFF6B6B);
  static const Color accentPink = Color(0xFFFF69B4);

  // ============ SEMANTIC COLORS ============
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFECB3);
  static const Color error = Color(0xFFFF5252);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ============ LIGHT THEME ============
  static const Color lightBg = Color(0xFFFAFAFC);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardSecondary = Color(0xFFF8F9FA);

  static const Color lightText = Color(0xFF1A1D29);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFF0F0F0);
  static const Color lightShadow = Color(0x14000000);

  // ============ DARK THEME ============
  static const Color darkBg = Color(0xFF0F1419);
  static const Color darkSurfaceVariant = Color(0xFF1A1F2B);
  static const Color darkCard = Color(0xFF1F2536);
  static const Color darkCardSecondary = Color(0xFF2A3142);

  static const Color darkText = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFFBCC0C7);
  static const Color darkTextTertiary = Color(0xFF8A90A0);
  static const Color darkBorder = Color(0xFF3A404E);
  static const Color darkDivider = Color(0xFF2A3142);
  static const Color darkShadow = Color(0x29000000);

  // ============ GLASSMORPHISM OVERLAY ============
  static const Color glassOverlay = Color(0x0DFFFFFF); // White with 5% opacity
  static const Color glassOverlayDark = Color(
    0x14000000,
  ); // Black with 8% opacity

  // ============ TABLE STATUS COLORS ============
  static const Color tableAvailable = Color(0xFF4CAF50);
  static const Color tableAvailableBg = Color(0xFFE8F5E9);
  static const Color tableOccupied = Color(0xFFFF5252);
  static const Color tableOccupiedBg = Color(0xFFFFEBEE);
  static const Color tableReserved = Color(0xFFFFC107);
  static const Color tableReservedBg = Color(0xFFFFF3E0);
  static const Color tableMaintenance = Color(0xFF757575);
  static const Color tableMaintenanceBg = Color(0xFFF5F5F5);

  // ============ ORDER STATUS COLORS ============
  static const Color orderPending = Color(0xFFFFC107);
  static const Color orderConfirmed = Color(0xFF2196F3);
  static const Color orderPreparing = Color(0xFFFF9800);
  static const Color orderReady = Color(0xFF4CAF50);
  static const Color orderCompleted = Color(0xFF7B68EE);
  static const Color orderCancelled = Color(0xFF757575);
}
