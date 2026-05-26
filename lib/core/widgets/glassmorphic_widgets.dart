import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../themes/app_animations.dart';

/// Premium glassmorphic container with blur and animations
class GlassContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color backdropColor;
  final List<BoxShadow> shadows;
  final VoidCallback? onTap;
  final bool interactive;
  final Duration animationDuration;

  const GlassContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.backdropColor = const Color(0x1AFFFFFF),
    this.shadows = AppAnimations.shadowMedium,
    this.onTap,
    this.interactive = false,
    this.animationDuration = AppAnimations.medium,
  }) : super(key: key);

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (widget.interactive) {
      if (isHovered) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: widget.backdropColor,
                  borderRadius: widget.borderRadius,
                  border: Border.all(color: const Color(0x29FFFFFF), width: 1),
                  boxShadow: widget.shadows,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated gradient background
class AnimatedGradientBG extends StatefulWidget {
  final List<Color> colors;
  final Widget child;
  final Duration animationDuration;
  final Alignment begin;
  final Alignment end;

  const AnimatedGradientBG({
    Key? key,
    required this.colors,
    required this.child,
    this.animationDuration = const Duration(seconds: 5),
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  }) : super(key: key);

  @override
  State<AnimatedGradientBG> createState() => _AnimatedGradientBGState();
}

class _AnimatedGradientBGState extends State<AnimatedGradientBG>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: widget.begin,
              end: widget.end,
              colors: widget.colors,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Smooth fade-in animation widget
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeInWidget({
    Key? key,
    required this.child,
    this.duration = AppAnimations.medium,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fadeAnimation, child: widget.child);
  }
}

/// Slide-in animation widget
class SlideInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset begin;
  final Offset end;
  final Curve curve;

  const SlideInWidget({
    Key? key,
    required this.child,
    this.duration = AppAnimations.medium,
    this.begin = const Offset(-1.0, 0.0),
    this.end = Offset.zero,
    this.curve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  State<SlideInWidget> createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<SlideInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _slideAnimation, child: widget.child);
  }
}

/// Pulse/glow animation effect
class PulseWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  }) : super(key: key);

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _pulseAnimation, child: widget.child);
  }
}

/// Rotating animation widget
class RotateWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const RotateWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<RotateWidget> createState() => _RotateWidgetState();
}

class _RotateWidgetState extends State<RotateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(turns: _controller, child: widget.child);
  }
}

/// Shimmer loading animation
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end: Alignment(-0.5 + _controller.value * 2, 0),
              colors: const [
                Colors.transparent,
                Color(0x1AFFFFFF),
                Colors.transparent,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A premium, hardware-accelerated animated backdrop of shifting colorful gradient light
/// orbs that simulates a dynamic high-definition restaurant ambient video background.
class FluidVideoBackground extends StatefulWidget {
  final Widget child;
  const FluidVideoBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<FluidVideoBackground> createState() => _FluidVideoBackgroundState();
}

class _FluidVideoBackgroundState extends State<FluidVideoBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Base dark luxury color
        Container(color: const Color(0xFF0A0718)),

        // Animated overlapping dynamic light orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            
            return Stack(
              children: [
                // Orb 1: Deep Royal Purple
                Positioned(
                  left: size.width * 0.1 + (size.width * 0.15 * math.sin(t * 2 * math.pi)),
                  top: size.height * 0.1 + (size.height * 0.1 * math.cos(t * 2 * math.pi + 1)),
                  child: Container(
                    width: size.width * 0.6,
                    height: size.width * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF6B4CE6).withOpacity(0.35),
                          const Color(0xFF6B4CE6).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Orb 2: Premium Cyan/Teal
                Positioned(
                  right: size.width * 0.1 + (size.width * 0.12 * math.cos(t * 2 * math.pi + 2)),
                  bottom: size.height * 0.1 + (size.height * 0.15 * math.sin(t * 2 * math.pi)),
                  child: Container(
                    width: size.width * 0.55,
                    height: size.width * 0.55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00D9FF).withOpacity(0.28),
                          const Color(0xFF00D9FF).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Orb 3: Luxurious Purple-Pink
                Positioned(
                  left: size.width * 0.3 + (size.width * 0.1 * math.sin(t * 2 * math.pi + 4)),
                  bottom: size.height * 0.3 + (size.height * 0.1 * math.cos(t * 2 * math.pi + 3)),
                  child: Container(
                    width: size.width * 0.5,
                    height: size.width * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF9D4EDD).withOpacity(0.22),
                          const Color(0xFF9D4EDD).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Orb 4: Deep Wine Red / Sunset Accent
                Positioned(
                  right: size.width * 0.2 + (size.width * 0.08 * math.sin(t * 2 * math.pi + 1.5)),
                  top: size.height * 0.3 + (size.height * 0.12 * math.cos(t * 2 * math.pi + 0.5)),
                  child: Container(
                    width: size.width * 0.45,
                    height: size.width * 0.45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFF2D55).withOpacity(0.18),
                          const Color(0xFFFF2D55).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Deep OLED vignetting & ambient contrast overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),

        // The actual foreground content
        widget.child,
      ],
    );
  }
}
