import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/glassmorphic_widgets.dart';
import '../../../services/auth_service.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RegisterController>()) {
      Get.lazyPut(() => RegisterController());
    }
    final controller = Get.find<RegisterController>();
    final roles = AuthService.instance.getAssignableRoles();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Register Account',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
      body: FluidVideoBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 100, bottom: 24),
            child: FadeInWidget(
              duration: const Duration(milliseconds: 1000),
              child: SlideInWidget(
                begin: const Offset(0, 0.1),
                duration: const Duration(milliseconds: 1000),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(32),
                    borderRadius: BorderRadius.circular(24),
                    backdropColor: const Color(0x13FFFFFF),
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
                        const SizedBox(height: 24),
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
                                    selectedColor: AppColors.primary.withOpacity(0.6),
                                    backgroundColor: Colors.white.withOpacity(0.08),
                                    labelStyle: TextStyle(
                                      color: controller.selectedRole.value == role
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: controller.selectedRole.value == role
                                            ? AppColors.primaryLight
                                            : Colors.white.withOpacity(0.15),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Obx(
                          () => _buildGlassmorphicButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.register,
                            isLoading: controller.isLoading.value,
                            label: 'Submit for Approval',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Get.offAllNamed('/login'),
                          child: const Text(
                            'Already have an account? Sign in',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
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
        hintStyle: const TextStyle(color: Colors.white54),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildGlassmorphicButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.85),
            Colors.white.withOpacity(0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
