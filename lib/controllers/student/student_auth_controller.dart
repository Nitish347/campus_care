// import 'package:campus_care/models/user.dart';
// import 'package:campus_care/services/storage_service.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
//
// import 'package:campus_care/core/constants/app_constants.dart';
// import 'package:campus_care/core/routes/app_routes.dart';
// import 'package:campus_care/services/auth_service.dart';
//
// class StudentAuthController extends GetxController {
//   final _isLoading = false.obs;
//   final _currentUser = Rxn<User>();
//   final _isLoggedIn = false.obs;
//
//   // Form controllers
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//
//   // Getters
//   bool get isLoading => _isLoading.value;
//   User? get currentUser => _currentUser.value;
//   bool get isLoggedIn => _isLoggedIn.value;
//
//   @override
//   void onInit() {
//     super.onInit();
//     checkLoginStatus();
//   }
//
//   void checkLoginStatus() {
//     _isLoggedIn.value = AuthService.isLoggedIn;
//     if (_isLoggedIn.value) {
//       final userData = StorageService.currentUser;
//       if (userData != null) {
//         try {
//           _currentUser.value = User.fromJson(userData);
//         } catch (e) {
//           debugPrint('Error parsing user data: $e');
//         }
//       }
//     }
//   }
//
//   @override
//   void onClose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
//
//   Future<void> login() async {
//     if (!formKey.currentState!.validate()) return;
//
//     try {
//       _isLoading.value = true;
//
//       // Force role to student
//       String role = AppConstants.roleStudent;
//
//       final userData = await AuthService.login(
//         emailController.text.trim(),
//         passwordController.text.trim(),
//         role,
//       );
//
//       if (userData != null) {
//         final user = User.fromJson(userData);
//         _currentUser.value = user;
//         _isLoggedIn.value = true;
//
//         // Clear form
//         emailController.clear();
//         passwordController.clear();
//
//         // Navigate to dashboard
//         if (user.role == AppConstants.roleStudent) {
//           Get.offAllNamed(AppRoutes.studentDashboard);
//         } else {
//           // Fallback if role mismatch
//           Get.snackbar(
//             'Error',
//             'Login successful but role mismatch. Expected Student.',
//             backgroundColor: Colors.orange,
//             colorText: Colors.white,
//           );
//         }
//
//         Get.snackbar(
//           'Success',
//           'Welcome back, ${user.name}!',
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
//   Future<void> logout() async {
//     try {
//       _isLoading.value = true;
//       await AuthService.logout();
//       _currentUser.value = null;
//       _isLoggedIn.value = false;
//       emailController.clear();
//       passwordController.clear();
//       Get.offAllNamed(AppRoutes.login);
//     } catch (e) {
//       Get.snackbar('Error', 'Logout failed');
//     } finally {
//       _isLoading.value = false;
//     }
//   }
// }
