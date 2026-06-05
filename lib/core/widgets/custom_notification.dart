import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/app_colors.dart';

class CustomNotification {
  static OverlayEntry? _currentOverlay;

  static void show({
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
    Color? color,
    Duration duration = const Duration(milliseconds: 1500), // Fast but readable duration
  }) {
    final context = Get.context;

    // Dismiss any existing custom notification immediately
    dismiss();

    OverlayState? overlayState;
    try {
      overlayState = Get.key.currentState?.overlay;
    } catch (_) {}

    if (overlayState == null && context != null) {
      try {
        final oContext = Get.overlayContext ?? context;
        overlayState = Overlay.of(oContext);
      } catch (_) {}
    }

    if (overlayState == null) return;
    final themeColor = color ?? AppColors.accentTeal;

    _currentOverlay = OverlayEntry(
      builder: (context) {
        return _NotificationOverlayWidget(
          title: title,
          message: message,
          icon: icon,
          color: themeColor,
          duration: duration,
          onDismiss: () => dismiss(),
        );
      },
    );

    overlayState.insert(_currentOverlay!);
  }

  static void showSnackbar(
    String title,
    String message, {
    Color? backgroundColor,
    Color? colorText,
    Duration duration = const Duration(milliseconds: 1500),
    IconData? icon,
  }) {
    Color themeColor = backgroundColor ?? AppColors.accentTeal;
    IconData themeIcon = icon ?? Icons.info_outline;

    final lowerTitle = title.toLowerCase();
    final lowerMessage = message.toLowerCase();

    // soft green accent for success while maintaining a clean look
    if (lowerTitle.contains('success') || lowerMessage.contains('success') || 
        lowerTitle.contains('saved') || lowerMessage.contains('saved') ||
        lowerTitle.contains('approved') || lowerTitle.contains('updated') ||
        lowerTitle.contains('created') || lowerTitle.contains('ready')) {
      themeColor = const Color(0xFF2ECC71); // Soft premium success green
      themeIcon = Icons.check_circle_outline;
    } else if (lowerTitle.contains('error') || lowerMessage.contains('error') || 
               lowerTitle.contains('fail') || lowerMessage.contains('fail')) {
      themeColor = AppColors.error;
      themeIcon = Icons.error_outline;
    } else if (lowerTitle.contains('warning') || lowerMessage.contains('warning') || 
               lowerTitle.contains('validation') || lowerTitle.contains('invalid')) {
      themeColor = AppColors.warning;
      themeIcon = Icons.warning_amber_outlined;
    }

    show(
      title: title,
      message: message,
      color: themeColor,
      icon: themeIcon,
      duration: duration,
    );
  }

  static void dismiss() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }
  }
}

class _NotificationOverlayWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Duration duration;
  final VoidCallback onDismiss;

  const _NotificationOverlayWidget({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.duration,
    required this.onDismiss,
  }) : super(key: key);

  @override
  _NotificationOverlayWidgetState createState() =>
      _NotificationOverlayWidgetState();
}

class _NotificationOverlayWidgetState extends State<_NotificationOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180), // Subtle and fast fade in/out
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    _dismissTimer = Timer(widget.duration, () {
      _close();
    });
  }

  void _close() {
    if (mounted) {
      _controller.reverse().then((_) {
        widget.onDismiss();
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            );
          },
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101015).withOpacity(0.65), // Translucent dark glass
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.color.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.title.isNotEmpty)
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            if (widget.title.isNotEmpty && widget.message.isNotEmpty)
                              const SizedBox(height: 2),
                            if (widget.message.isNotEmpty)
                              Text(
                                widget.message,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
