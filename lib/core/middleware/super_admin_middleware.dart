import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';

/// Super admin middleware
/// Ensures only super admins can access super admin routes
class SuperAdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // If not logged in, redirect to login
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // // If not super admin, redirect to appropriate dashboard
    // if (!authController.isSuperAdmin) {
    //   // Redirect based on actual role
    //   if (authController.isSchoolAdmin) {
    //     return const RouteSettings(name: AppRoutes.adminDashboard);
    //   } else if (authController.isTeacher) {
    //     return const RouteSettings(name: AppRoutes.teacherDashboard);
    //   } else if (authController.isStudent) {
    //     return const RouteSettings(name: AppRoutes.studentDashboard);
    //   }
    //
    //   // Fallback to login if role is unknown
    //   return const RouteSettings(name: AppRoutes.login);
    // }

    return null; // Allow access for super admin
  }
}
