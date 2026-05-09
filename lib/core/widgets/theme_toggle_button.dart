import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/settings/controllers/theme_controller.dart';
import '../themes/app_colors.dart';

/// Reusable theme toggle button widget
class ThemeToggleButton extends StatelessWidget {
  final bool compact;

  const ThemeToggleButton({Key? key, this.compact = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => themeController.toggleTheme(),
          child: Padding(
            padding: compact
                ? const EdgeInsets.all(8)
                : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Icon(
              themeController.isDarkMode.value
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              size: compact ? 20 : 24,
            ),
          ),
        ),
      ),
    );
  }
}
