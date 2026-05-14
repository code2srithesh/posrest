import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../services/auth_service.dart';

class UserManagementController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final users = <UserModel>[].obs;
  final selectedRole = AppConstants.roleWaiter.obs;
  final isApproved = true.obs;
  final isLoading = false.obs;

  List<String> get assignableRoles => AuthService.instance.getAssignableRoles();

  List<UserModel> get pendingUsers =>
      users.where((user) => !user.isActive).toList();
  List<UserModel> get approvedUsers =>
      users.where((user) => user.isActive).toList();

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final loaded = await AuthService.instance.getAllUsers();
    users.assignAll(loaded);
  }

  Future<void> createUser() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please fill all fields');
      return;
    }

    isLoading.value = true;
    try {
      final result = await AuthService.instance.createUserByAdmin(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: selectedRole.value,
        isActive: isApproved.value,
      );

      if (result['success'] == true) {
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        isApproved.value = true;
        await loadUsers();
        Get.snackbar('Success', result['message'] ?? 'User created');
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to create user');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveUser(String userId) async {
    final result = await AuthService.instance.approveUser(userId);
    if (result['success'] == true) {
      await loadUsers();
      Get.snackbar('Approved', result['message'] ?? 'User approved');
    } else {
      Get.snackbar('Error', result['message'] ?? 'Approval failed');
    }
  }

  Future<void> rejectUser(String userId) async {
    final result = await AuthService.instance.rejectUser(userId);
    if (result['success'] == true) {
      await loadUsers();
      Get.snackbar('Rejected', result['message'] ?? 'User removed');
    } else {
      Get.snackbar('Error', result['message'] ?? 'Rejection failed');
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
