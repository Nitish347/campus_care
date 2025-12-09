import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/models/user.dart';
import 'package:campus_care/services/auth_service.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Artificial delay for splash screen visibility (optional)
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = AuthService.isLoggedIn;

    if (isLoggedIn) {
      final user = AuthService.getCurrentUser();
      if (user != null) {
        _navigateToRoleDashboard(user);
      } else {
        // Fallback if data is corrupted or missing
        Get.offNamed(AppRoutes.login);
      }
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }

  void _navigateToRoleDashboard(User user) {
    if (user.role == AppConstants.roleSuperAdmin) {
      Get.offNamed(AppRoutes.superAdminDashboard);
    } else if (user.role == AppConstants.roleAdmin) {
      Get.offNamed(AppRoutes.adminDashboard);
    } else if (user.role == AppConstants.roleTeacher) {
      Get.offNamed(AppRoutes.teacherDashboard);
    } else if (user.role == AppConstants.roleStudent) {
      Get.offNamed(AppRoutes.studentDashboard);
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }
}
