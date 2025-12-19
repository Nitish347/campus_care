// import 'package:campus_care/models/admin/admin.dart';
// import 'package:campus_care/services/storage_service.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
//
// import 'package:campus_care/core/constants/app_constants.dart';
// import 'package:campus_care/core/routes/app_routes.dart';
// import 'package:campus_care/services/auth_service.dart';
//
// class AdminAuthController extends GetxController {
//   final _isLoading = false.obs;
//   final _currentUser = Rxn<Admin>();
//   final _isLoggedIn = false.obs;
//
//   // Form controllers
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//
//   // Getters
//   bool get isLoading => _isLoading.value;
//   Admin? get currentUser => _currentUser.value;
//   bool get isLoggedIn => _isLoggedIn.value;
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Defer navigation check until GetMaterialApp is fully initialized
//     // Future.microtask(() {
//     //   checkLoginStatus();
//     // });
//   }
//
//   @override
//   void onClose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
//
//   void checkLoginStatus() {
//     _isLoggedIn.value = AuthService.isLoggedIn;
//     if (_isLoggedIn.value) {
//       _currentUser.value = Admin.fromJson(StorageService.currentUser ?? {});
//       if (_currentUser.value != null) {
//         _navigateToRoleDashboard();
//       }
//     }
//   }
//
//   Future<void> login() async {
//     if (!formKey.currentState!.validate()) return;
//
//     try {
//       _isLoading.value = true;
//
//       // Determine role based on email or default to student
//       String role = AppConstants.roleAdmin;
//       final email = emailController.text.trim().toLowerCase();
//
//       final user = await AuthService.login(
//         emailController.text.trim(),
//         passwordController.text.trim(),
//         role,
//       );
//
//       if (user != null) {
//         _currentUser.value = Admin.fromJson(user);
//         _isLoggedIn.value = true;
//
//         // Clear form
//         emailController.clear();
//         passwordController.clear();
//
//         // Navigate to appropriate dashboard
//         _navigateToRoleDashboard();
//
//         Get.snackbar(
//           'Success',
//           'Welcome back, ${_currentUser.value?.fullName ?? ""}!',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//         );
//       } else {
//         Get.snackbar(
//           'Login Failed',
//           'Invalid email or password. Please try again.',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         e.toString().replaceAll('Exception: ', ''),
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//       );
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   void _navigateToRoleDashboard() {
//     // Admin users always go to admin dashboard
//     Get.offAllNamed(AppRoutes.adminDashboard);
//   }
//
//   Future<void> logout() async {
//     try {
//       _isLoading.value = true;
//
//       await AuthService.logout();
//
//       _currentUser.value = null;
//       _isLoggedIn.value = false;
//
//       // Clear form controllers
//       emailController.clear();
//       passwordController.clear();
//
//       Get.offAllNamed(AppRoutes.login);
//
//       Get.snackbar(
//         'Success',
//         'You have been logged out successfully.',
//         backgroundColor: Colors.blue,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//       );
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'An error occurred during logout.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//       );
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> changePassword(String oldPassword, String newPassword) async {
//     try {
//       _isLoading.value = true;
//
//       final success =
//           await AuthService.changePassword(oldPassword, newPassword);
//
//       if (success) {
//         Get.snackbar(
//           'Success',
//           'Password changed successfully.',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//         );
//       } else {
//         Get.snackbar(
//           'Error',
//           'Failed to change password. Please check your current password.',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'An error occurred while changing password.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//       );
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> updateProfile(Map<String, dynamic> profileData) async {
//     try {
//       _isLoading.value = true;
//
//       final success = await AuthService.updateProfile(profileData);
//
//       if (success) {
//         // _currentUser.value = AuthService.getCurrentUser();
//
//         Get.snackbar(
//           'Success',
//           'Profile updated successfully.',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//         );
//       } else {
//         Get.snackbar(
//           'Error',
//           'Failed to update profile.',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'An error occurred while updating profile.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//       );
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   // Demo login methods for quick testing
//   void loginAsSuperAdmin() {
//     emailController.text = 'superadmin@campuscare.com';
//     passwordController.text = 'superadmin123';
//     login();
//   }
//
//   void loginAsAdmin() {
//     emailController.text = 'admin@schoolstream.com';
//     passwordController.text = 'admin123';
//     login();
//   }
//
//   void loginAsTeacher() {
//     emailController.text = 'teacher@schoolstream.com';
//     passwordController.text = 'teacher123';
//     login();
//   }
//
//   void loginAsStudent() {
//     emailController.text = 'student1@schoolstream.com';
//     passwordController.text = 'student123';
//     login();
//   }
// }
