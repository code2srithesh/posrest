import 'package:flutter/material.dart';

/// Premium dark gradient glasmorphic color palette
/// Combines dark purples, teals, deep blues with glassmorphic effects
class AppColors {
  // ============ PRIMARY PALETTE - Dark Gradient ============
  // Premium purple-blue-teal gradient for glasmorphism
  static const Color primaryDark = Color(0xFF0D0B21);
  static const Color primary = Color(0xFF6B4CE6);
  static const Color primaryLight = Color(0xFF9D82FF);
  static const Color primaryLighter = Color(0xFFBBA5FF);

  // ============ GRADIENT COLORS - PREMIUM DARK ============
  // Base gradients: Deep purple to OLED black with teal accents
  static const Color gradientStart = Color(0xFF0F0C1F);
  static const Color gradientEnd = Color(0xFF050319);
  static const Color gradientMid = Color(0xFF1A0E3F);
  static const Color accentGradient1 = Color(0xFF6B4CE6); // Purple
  static const Color accentGradient2 = Color(0xFF9D4EDD); // Pink-Purple
  static const Color accentGradient3 = Color(0xFF00D9FF); // Cyan/Teal
  static const Color accentGradient4 = Color(0xFF1E3A8A); // Deep Blue

  // ============ ACCENT PALETTE - Cool Tones ============
  static const Color accentTeal = Color(0xFF00D9FF); // Bright Cyan/Teal
  static const Color accentTealDark = Color(0xFF0D9BAE); // Deep Teal
  static const Color accentCyan = Color(0xFF00E5FF); // Cyan
  static const Color accentBlue = Color(0xFF1E3A8A); // Deep Blue
  static const Color accentOrange = Color(0xFFFF8C42); // Warm Orange
  static const Color accentGold = Color(0xFFFFB347); // Gold
  static const Color accentRed = Color(0xFFFF3B30); // Red
  static const Color accentPink = Color(0xFFFF2D55); // Pink

  // ============ SEMANTIC COLORS ============
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFECB3);
  static const Color error = Color(0xFFFF5252);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ============ LIGHT THEME (Dark Glasmorphic - Premium) ============
  static const Color lightBg = Color(0xFF0F0C1F); // Dark purple background
  static const Color lightBgSecondary = Color(0xFF0A0814); // Darker secondary bg
  static const Color lightSurfaceVariant = Color(0xFF16112D); // Dark surface
  static const Color lightCard = Color(0xFF1A1530); // Dark card with purple tint
  static const Color lightCardSecondary = Color(0xFF201935); // Secondary dark card
  static const Color lightCardHover = Color(0xFF251E42); // Card hover state
  static const Color lightCardAccent = Color(0xFF2D2650); // Card accent overlay

  static const Color lightText = Color(0xFFE8EAED); // Light text
  static const Color lightTextSecondary = Color(0xFFBCC0C7); // Secondary text
  static const Color lightTextTertiary = Color(0xFF8A90A0); // Tertiary text
  static const Color lightBorder = Color(0xFF3A3548); // Border color
  static const Color lightDivider = Color(0xFF2A2035); // Divider color
  static const Color lightShadow = Color(0x29000000); // Shadow

  // ============ DARK THEME (Darker Glasmorphic - Premium OLED) ============
  static const Color darkBg = Color(0xFF050319); // OLED black
  static const Color darkBgSecondary = Color(0xFF03010F); // Darker OLED black
  static const Color darkSurfaceVariant = Color(0xFF0D0B21); // Dark surface
  static const Color darkCard = Color(0xFF1A1530); // Dark card
  static const Color darkCardSecondary = Color(0xFF201935); // Secondary dark card
  static const Color darkCardHover = Color(0xFF251E42); // Card hover state
  static const Color darkCardAccent = Color(0xFF2D2650); // Card accent overlay

  static const Color darkText = Color(0xFFE8EAED); // Light text
  static const Color darkTextSecondary = Color(0xFFBCC0C7); // Secondary text
  static const Color darkTextTertiary = Color(0xFF8A90A0); // Tertiary text
  static const Color darkBorder = Color(0xFF2A2540); // Border color
  static const Color darkDivider = Color(0xFF1A1530); // Divider color
  static const Color darkShadow = Color(0x3A000000); // Shadow

  // ============ GLASSMORPHISM OVERLAY - PREMIUM ============
  // Layered glass effects with varying transparency and color
  static const Color glassOverlay = Color(0x0DFFFFFF); // Ultra transparent white (5%)
  static const Color glassOverlayLight = Color(0x1AFFFFFF); // Light white (10%)
  static const Color glassOverlayMedium = Color(0x2DFFFFFF); // Medium white (18%)
  static const Color glassOverlayDark = Color(0x3DFFFFFF); // Dark white (24%)

  // Tinted glass overlays
  static const Color glassOverlayPurple = Color(0x0D6B4CE6); // Purple tint (5%)
  static const Color glassOverlayPurpleMed = Color(0x1D6B4CE6); // Purple tint (12%)
  static const Color glassOverlayPurpleDeep = Color(0x2D6B4CE6); // Purple tint (18%)

  static const Color glassOverlayTeal = Color(0x0D00D9FF); // Teal tint (5%)
  static const Color glassOverlayTealMed = Color(0x1D00D9FF); // Teal tint (12%)
  static const Color glassOverlayTealDeep = Color(0x2D00D9FF); // Teal tint (18%)

  static const Color glassOverlayBlue = Color(0x0D1E3A8A); // Blue tint (5%)
  static const Color glassOverlayBlueMed = Color(0x1D1E3A8A); // Blue tint (12%)
  static const Color glassOverlayBlueDeep = Color(0x2D1E3A8A); // Blue tint (18%)

  static const Color glassOverlayBlack = Color(0x0D000000); // Black tint (5%)
  static const Color glassOverlayBlackMed = Color(0x1D000000); // Black tint (12%)

  // ============ TABLE STATUS COLORS ============
  static const Color tableAvailable = Color(0xFF4CAF50);
  static const Color tableAvailableBg = Color(0xFFE8F5E9);
  static const Color tableOccupied = Color(0xFFFF5252);
  static const Color tableOccupiedBg = Color(0xFFFFEBEE);
  static const Color tableReserved = Color(0xFFFFC107);
  static const Color tableReservedBg = Color(0xFFFFF3E0);
  static const Color tableMaintenance = Color(0xFF757575);
  static const Color tableMaintenanceBg = Color(0xFFF5F5F5);

  // ============ ORDER STATUS COLORS - PREMIUM ============
  static const Color orderPending = Color(0xFFFFC107); // Amber/Yellow
  static const Color orderConfirmed = Color(0xFF00D9FF); // Cyan/Teal
  static const Color orderPreparing = Color(0xFFFF9800); // Deep Orange
  static const Color orderReady = Color(0xFF4CAF50); // Green
  static const Color orderCompleted = Color(0xFF9D4EDD); // Pink-Purple
  static const Color orderCancelled = Color(0xFF757575); // Gray

  // ============ SEMANTIC GRADIENT OVERLAYS ============
  // For smooth transitions and animations
  static const List<Color> gradientPrimaryTeal = [
    Color(0xFF6B4CE6), // Purple
    Color(0xFF00D9FF), // Teal
  ];
  static const List<Color> gradientBluePurple = [
    Color(0xFF1E3A8A), // Deep Blue
    Color(0xFF6B4CE6), // Purple
  ];
  static const List<Color> gradientDarkOLED = [
    Color(0xFF0F0C1F), // Dark Purple
    Color(0xFF050319), // OLED Black
  ];
  static const List<Color> gradientTealBlue = [
    Color(0xFF00D9FF), // Teal
    Color(0xFF1E3A8A), // Deep Blue
  ];
}
