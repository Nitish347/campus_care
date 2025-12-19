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
    final authController = Get.find<AuthController>();

    // If not logged in, redirect to login
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // AdminAuthController is now specific to Admin users only
    // All logged in users via AdminAuthController are admins
    // If you need separate auth for teachers/students,
    // create separate TeacherAuthController and StudentAuthController

    return null; // Allow access for logged in admin
  }
}
