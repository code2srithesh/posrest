import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_colors.dart';
import '../../../services/auth_service.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());
    final roles = AuthService.instance.getAssignableRoles();

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: const Text('Register Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to login',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }

            Get.offAllNamed('/login');
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create your account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your role and submit it for admin approval.',
                    style: TextStyle(color: Colors.white.withOpacity(0.75)),
                  ),
                  const SizedBox(height: 24),
                  _buildField(controller.nameController, 'Name', Icons.person),
                  const SizedBox(height: 16),
                  _buildField(
                    controller.emailController,
                    'Email',
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller.passwordController,
                    'Password',
                    Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select your role',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: roles
                          .map(
                            (role) => ChoiceChip(
                              label: Text(
                                AuthService.instance.getRoleLabel(role),
                              ),
                              selected: controller.selectedRole.value == role,
                              onSelected: (_) =>
                                  controller.selectedRole.value = role,
                              selectedColor: AppColors.accentTeal.withOpacity(
                                0.35,
                              ),
                              labelStyle: TextStyle(
                                color: controller.selectedRole.value == role
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentTeal,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit for Approval'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.offAllNamed('/login'),
                    child: const Text(
                      'Already have an account? Sign in',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
