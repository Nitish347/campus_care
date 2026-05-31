import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/services/storage_service.dart';

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

    final role = authController.currentRole?.isNotEmpty == true
        ? authController.currentRole
        : StorageService.userRole;

    if (role != AppConstants.roleSuperAdmin) {
      return const RouteSettings(name: AppRoutes.login);
    }

    return null; // Allow access for super admin
  }
}
