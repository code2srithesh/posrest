import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  void resetLoginForm() {
    emailController.clear();
    passwordController.clear();
    errorMessage.value = '';
    isPasswordVisible.value = false;
  }

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

    if (isClosed) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      await AuthService.instance.initialize();

      final result = await AuthService.instance.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (result['success']) {
        if (isClosed) {
          return;
        }

        final user = result['user'];
        final targetRoute = AuthService.instance.getLandingRouteForRole(
          user?.role ?? 'waiter',
        );
        resetLoginForm();
        Get.snackbar(
          'Success',
          '${result['message']}\nWelcome ${result['user']?.name}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        Get.offAllNamed(targetRoute);
      } else {
        if (isClosed) {
          return;
        }

        errorMessage.value = result['message'] ?? 'Login failed';
        Get.snackbar(
          'Login Failed',
          result['message'] ?? 'Invalid credentials',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (!isClosed) {
        errorMessage.value = 'Error: $e';
      }
      Get.snackbar(
        'Error',
        'Login error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
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
