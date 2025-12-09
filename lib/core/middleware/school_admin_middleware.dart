import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/services/institute_context_service.dart';

import '../../controllers/admin/admin_auth_controller.dart';

/// School admin middleware
/// Ensures only school admins (or super admins with institute context) can access school admin routes
class SchoolAdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AdminAuthController>();

    // If not logged in, redirect to login
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // // If super admin with institute context, allow access to admin routes
    // if (authController.isSuperAdmin) {
    //   try {
    //     final contextService = Get.find<InstituteContextService>();
    //     if (contextService.isInInstituteContext) {
    //       return null; // Allow access
    //     }
    //   } catch (e) {
    //     // Context service not initialized yet
    //   }
    //   // Super admin without context should go to super admin dashboard
    //   return const RouteSettings(name: AppRoutes.superAdminDashboard);
    // }

    // If not school admin, redirect to appropriate dashboard
    if (!authController.isSchoolAdmin) {
      if (authController.isTeacher) {
        return const RouteSettings(name: AppRoutes.teacherDashboard);
      } else if (authController.isStudent) {
        return const RouteSettings(name: AppRoutes.studentDashboard);
      }

      // Fallback to login if role is unknown
      return const RouteSettings(name: AppRoutes.login);
    }

    return null; // Allow access for school admin
  }
}
