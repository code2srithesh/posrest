import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final selectedRole = Rx<String?>(
    null,
  ); // Initialize as null, set with proper value
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Defer the initialization to avoid modifying observables during build
    Future.microtask(() {
      if (selectedRole.value == null || selectedRole.value!.isEmpty) {
        selectedRole.value = AuthService.instance.getAssignableRoles().first;
      }
    });
  }

  Future<void> register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      errorMessage.value = 'Please fill all fields';
      return;
    }

    if (selectedRole.value == null || selectedRole.value!.isEmpty) {
      errorMessage.value = 'Please select a role';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await AuthService.instance.registerUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: selectedRole.value!,
      );

      if (result['success'] == true) {
        Get.snackbar(
          'Registration Submitted',
          result['message'] ?? 'Awaiting admin approval',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed('/login');
      } else {
        errorMessage.value = result['message'] ?? 'Registration failed';
        Get.snackbar(
          'Registration Failed',
          errorMessage.value,
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
        'Registration error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
