import 'package:flutter/material.dart';

/// Premium animation and transition configurations
/// Provides smooth, sophisticated animations for the app
class AppAnimations {
  // ============ DURATION CONSTANTS ============
  static const Duration superFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // ============ CURVES ============
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticInOut = Curves.elasticInOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  // Custom curves for premium feel
  static const Curve smoothInOut = Curves.decelerate;
  static const Curve quickReturn = Curves.elasticOut;

  // ============ SCALE ANIMATIONS ============
  // Used for button presses, card expansions
  static const double scaleHover = 1.05;
  static const double scalePressed = 0.95;
  static const double scaleExpanded = 1.02;

  // ============ OPACITY TRANSITIONS ============
  static const double opacityHidden = 0.0;
  static const double opacityLow = 0.3;
  static const double opacityMedium = 0.6;
  static const double opacityHigh = 0.85;
  static const double opacityFull = 1.0;

  // ============ SHADOW ANIMATIONS ============
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x2D000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color(0x3A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowGlow = [
    BoxShadow(
      color: Color(0x4D6B4CE6), // Purple glow
      blurRadius: 20,
      offset: Offset(0, 0),
    ),
  ];

  static const List<BoxShadow> shadowGlowTeal = [
    BoxShadow(
      color: Color(0x4D00D9FF), // Teal glow
      blurRadius: 20,
      offset: Offset(0, 0),
    ),
  ];

  // ============ BORDER RADIUS ============
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(6));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(20));
  static const BorderRadius radiusCircle = BorderRadius.all(Radius.circular(50));

  // ============ GRADIENT ANIMATION BUILDER ============
  /// Create animated gradient background
  static BoxDecoration gradientAnimated({
    required List<Color> colors,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    TileMode tileMode = TileMode.clamp,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: begin,
        end: end,
        colors: colors,
        tileMode: tileMode,
      ),
    );
  }

  // ============ GLASSMORPHISM DECORATION ============
  /// Create premium glassmorphic container decoration
  static BoxDecoration glassDecoration({
    Color backdropColor = const Color(0x1AFFFFFF),
    BorderRadius borderRadius = AppAnimations.radiusMedium,
    Border? border,
    List<BoxShadow> shadows = const [],
  }) {
    return BoxDecoration(
      color: backdropColor,
      borderRadius: borderRadius,
      border: border ?? Border.all(
        color: const Color(0x29FFFFFF),
        width: 1,
      ),
      boxShadow: shadows.isNotEmpty ? shadows : shadowSmall,
    );
  }

  // ============ SHIMMER ANIMATION HELPER ============
  /// Create shimmer loading effect
  static Widget shimmerEffect({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1530),
        borderRadius: radiusMedium,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1530),
            const Color(0xFF2A2540),
            const Color(0xFF1A1530),
          ],
        ),
      ),
    );
  }

  // ============ PULSE ANIMATION ============
  /// Pulse effect for highlights
  static Animation<double> getPulseAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  // ============ SLIDE IN ANIMATION ============
  /// Slide in from left/right/top/bottom
  static Animation<Offset> getSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(-1.0, 0.0),
    Offset end = Offset.zero,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );
  }

  // ============ FADE IN ANIMATION ============
  /// Fade in animation
  static Animation<double> getFadeAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  // ============ SCALE ANIMATION ============
  /// Scale animation for emphasis
  static Animation<double> getScaleAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticOut),
    );
  }

  // ============ ROTATION ANIMATION ============
  /// Rotation animation for spinners/loaders
  static Animation<double> getRotationAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(controller);
  }
}
