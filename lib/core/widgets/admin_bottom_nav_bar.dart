import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/app_colors.dart';
import '../themes/app_animations.dart';
import 'glassmorphic_widgets.dart';
import '../../services/auth_service.dart';

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only show if the user is an Admin
    final role = AuthService.instance.getUserRole();
    if (role != 'admin') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        backdropColor: Colors.black.withValues(alpha: 0.65),
        borderRadius: AppAnimations.radiusXL,
        shadows: AppAnimations.shadowGlow,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.people_outline,
              activeIcon: Icons.people,
              label: 'Users',
              index: 0,
              route: '/admin/users',
            ),
            _buildNavItem(
              icon: Icons.table_bar_outlined,
              activeIcon: Icons.table_bar,
              label: 'Tables',
              index: 1,
              route: '/tables',
            ),
            _buildNavItem(
              icon: Icons.point_of_sale_outlined,
              activeIcon: Icons.point_of_sale,
              label: 'Cashier',
              index: 2,
              route: '/cashier',
            ),
            _buildNavItem(
              icon: Icons.soup_kitchen_outlined,
              activeIcon: Icons.soup_kitchen,
              label: 'Kitchen',
              index: 3,
              route: '/kitchen',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required String route,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.accentTeal : Colors.white60;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          Get.offAllNamed(route);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.12) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
