import 'package:flutter/material.dart';

/// Comprehensive dark gradient glasmorphic color palette
class AppColors {
  // ============ PRIMARY PALETTE - Dark Gradient ============
  // Professional dark purple-blue gradient for glasmorphism
  static const Color primaryDark = Color(0xFF1A0E3F);
  static const Color primary = Color(0xFF6B4CE6);
  static const Color primaryLight = Color(0xFF8B7FDB);
  static const Color primaryLighter = Color(0xFFA99CED);

  // ============ GRADIENT COLORS ============
  static const Color gradientStart = Color(0xFF0F0C1F);
  static const Color gradientEnd = Color(0xFF1A0E3F);
  static const Color accentGradient1 = Color(0xFF6B4CE6);
  static const Color accentGradient2 = Color(0xFF9D4EDD);

  // ============ ACCENT PALETTE ============
  static const Color accentOrange = Color(0xFFFF8C42);
  static const Color accentGold = Color(0xFFFFB347);
  static const Color accentRed = Color(0xFFFF3B30);
  static const Color accentPink = Color(0xFFFF2D55);

  // ============ SEMANTIC COLORS ============
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFECB3);
  static const Color error = Color(0xFFFF5252);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ============ LIGHT THEME (Dark Glasmorphic) ============
  static const Color lightBg = Color(0xFF0F0C1F);
  static const Color lightSurfaceVariant = Color(0xFF1A1025);
  static const Color lightCard = Color(0xFF1F1631);
  static const Color lightCardSecondary = Color(0xFF252033);

  static const Color lightText = Color(0xFFE8EAED);
  static const Color lightTextSecondary = Color(0xFFBCC0C7);
  static const Color lightTextTertiary = Color(0xFF8A90A0);
  static const Color lightBorder = Color(0xFF3A3548);
  static const Color lightDivider = Color(0xFF2A2035);
  static const Color lightShadow = Color(0x29000000);

  // ============ DARK THEME (Darker Glasmorphic) ============
  static const Color darkBg = Color(0xFF050319);
  static const Color darkSurfaceVariant = Color(0xFF0F0C1F);
  static const Color darkCard = Color(0xFF1A1530);
  static const Color darkCardSecondary = Color(0xFF201935);

  static const Color darkText = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFFBCC0C7);
  static const Color darkTextTertiary = Color(0xFF8A90A0);
  static const Color darkBorder = Color(0xFF2A2540);
  static const Color darkDivider = Color(0xFF1A1530);
  static const Color darkShadow = Color(0x3A000000);

  // ============ GLASSMORPHISM OVERLAY ============
  static const Color glassOverlay = Color(
    0x1AFFFFFF,
  ); // White with 10% opacity for transparency
  static const Color glassOverlayDark = Color(
    0x1A6B4CE6,
  ); // Purple with 10% opacity
  static const Color glassOverlayMedium = Color(
    0x2D9D4EDD,
  ); // Pink-purple with 18% opacity
  static const Color glassOverlayDeep = Color(
    0x3D1A0E3F,
  ); // Deep purple with 24% opacity

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
