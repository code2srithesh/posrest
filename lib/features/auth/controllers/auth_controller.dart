import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter email and password');
      return;
    }

    isLoading.value = true;
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // For demo purposes, accept any email/password
      await AuthService().login(emailController.text, passwordController.text);
      await AuthService().setUserInfo(
        const Uuid().v4(),
        emailController.text,
        AppConstants.roleWaiter,
      );

      Get.offAllNamed('/tables');
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> demoLogin() async {
    emailController.text = 'demo@posrest.com';
    passwordController.text = 'demo123';
    await login();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
