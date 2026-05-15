import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_animations.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/glassmorphic_widgets.dart';
import '../../../data/models/user_model.dart';
import '../../../services/auth_service.dart';
import '../controllers/user_management_controller.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserManagementController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }

            AuthService().logout().then((_) => Get.offAllNamed('/login'));
          },
        ),
        actions: [
          IconButton(
            onPressed: controller.loadUsers,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () =>
                AuthService().logout().then((_) => Get.offAllNamed('/login')),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: AnimatedGradientBG(
        colors: const [
          AppColors.gradientStart,
          AppColors.primaryDark,
          AppColors.gradientEnd,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1150;
              final cardWidth = isWide
                  ? (constraints.maxWidth - 60) / 2
                  : constraints.maxWidth;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _sectionCard(
                        title: 'Create User',
                        child: Column(
                          children: [
                            _field(
                              controller.nameController,
                              'Name',
                              Icons.person,
                            ),
                            const SizedBox(height: 12),
                            _field(
                              controller.emailController,
                              'Email',
                              Icons.email_outlined,
                            ),
                            const SizedBox(height: 12),
                            _field(
                              controller.passwordController,
                              'Password',
                              Icons.lock_outline,
                              obscureText: true,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: controller.assignableRoles.map((role) {
                                return Obx(
                                  () => ChoiceChip(
                                    label: Text(
                                      AuthService().getRoleLabel(role),
                                    ),
                                    selected:
                                        controller.selectedRole.value == role,
                                    onSelected: (_) =>
                                        controller.selectedRole.value = role,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            Obx(
                              () => SwitchListTile(
                                value: controller.isApproved.value,
                                onChanged: (value) =>
                                    controller.isApproved.value = value,
                                title: const Text(
                                  'Approve immediately',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: const Text(
                                  'Disable to create a pending account',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                activeColor: AppColors.accentTeal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : controller.createUser,
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Create User'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _sectionCard(
                        title: 'Pending Approval',
                        child: Obx(
                          () => controller.pendingUsers.isEmpty
                              ? const Text(
                                  'No pending users',
                                  style: TextStyle(color: Colors.white70),
                                )
                              : Column(
                                  children: controller.pendingUsers
                                      .map(
                                        (user) => _userTile(
                                          user,
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextButton(
                                                onPressed: () => controller
                                                    .approveUser(user.id),
                                                child: const Text('Approve'),
                                              ),
                                              TextButton(
                                                onPressed: () => controller
                                                    .rejectUser(user.id),
                                                child: const Text('Reject'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: _sectionCard(
                        title: 'Active Users',
                        child: Obx(
                          () => controller.approvedUsers.isEmpty
                              ? const Text(
                                  'No active users',
                                  style: TextStyle(color: Colors.white70),
                                )
                              : Column(
                                  children: controller.approvedUsers
                                      .map(
                                        (user) => _userTile(
                                          user,
                                          trailing: Chip(
                                            label: Text(
                                              AuthService().getRoleLabel(
                                                user.role,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      backdropColor: AppColors.glassOverlayPurpleDeep,
      borderRadius: AppAnimations.radiusXL,
      shadows: AppAnimations.shadowMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _userTile(UserModel user, {required Widget trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(user.email, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  '${AuthService().getRoleLabel(user.role)} · ${user.isActive ? 'Approved' : 'Pending'}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
