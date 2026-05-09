import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter email and password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Call the new login method
      final result = await AuthService.instance.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (result['success']) {
        Get.snackbar(
          'Success',
          '${result['message']}\nWelcome ${result['user']?.name}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        Get.offAllNamed('/tables');
      } else {
        errorMessage.value = result['message'] ?? 'Login failed';
        Get.snackbar(
          'Login Failed',
          result['message'] ?? 'Invalid credentials',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        'Login error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void demoLogin(String email, String password) async {
    emailController.text = email;
    passwordController.text = password;
    await login();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
