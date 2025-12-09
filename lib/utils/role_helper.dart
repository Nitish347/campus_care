import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// Helper class for role-based access control
class RoleHelper {
  /// Check if current user has super admin role
  static bool isSuperAdmin() {
    final authController = Get.find<AuthController>();
    return authController.isSuperAdmin;
  }

  /// Check if current user has school admin role
  static bool isSchoolAdmin() {
    final authController = Get.find<AuthController>();
    return authController.isSchoolAdmin;
  }

  /// Check if current user has teacher role
  static bool isTeacher() {
    final authController = Get.find<AuthController>();
    return authController.isTeacher;
  }

  /// Check if current user has student role
  static bool isStudent() {
    final authController = Get.find<AuthController>();
    return authController.isStudent;
  }

  /// Check if current user has any admin role (super admin or school admin)
  static bool isAnyAdmin() {
    final authController = Get.find<AuthController>();
    return authController.isSuperAdmin || authController.isSchoolAdmin;
  }

  /// Get user's role as string
  static String? getUserRole() {
    final authController = Get.find<AuthController>();
    return authController.userRole;
  }

  /// Check if user has specific role
  static bool hasRole(String role) {
    final authController = Get.find<AuthController>();
    return authController.userRole == role;
  }

  /// Get display name for role
  static String getRoleDisplayName(String? role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        return 'Super Admin';
      case AppConstants.roleAdmin:
        return 'School Admin';
      case AppConstants.roleTeacher:
        return 'Teacher';
      case AppConstants.roleStudent:
        return 'Student';
      default:
        return 'Unknown';
    }
  }

  /// Check if user can access super admin features
  static bool canAccessSuperAdminFeatures() {
    return isSuperAdmin();
  }

  /// Check if user can access school admin features
  static bool canAccessSchoolAdminFeatures() {
    return isSchoolAdmin();
  }

  /// Check if user can access teacher features
  static bool canAccessTeacherFeatures() {
    return isTeacher();
  }

  /// Check if user can access student features
  static bool canAccessStudentFeatures() {
    return isStudent();
  }

  /// Get allowed routes for current user role
  static List<String> getAllowedRoutes() {
    final authController = Get.find<AuthController>();

    if (authController.isSuperAdmin) {
      return _getSuperAdminRoutes();
    } else if (authController.isSchoolAdmin) {
      return _getSchoolAdminRoutes();
    } else if (authController.isTeacher) {
      return _getTeacherRoutes();
    } else if (authController.isStudent) {
      return _getStudentRoutes();
    }

    return [];
  }

  static List<String> _getSuperAdminRoutes() {
    return [
      '/super-admin/dashboard',
      '/super-admin/institutes',
      '/super-admin/institute-detail',
      '/super-admin/add-edit-institute',
    ];
  }

  static List<String> _getSchoolAdminRoutes() {
    return [
      '/admin/dashboard',
      '/admin/students',
      '/admin/teachers',
      '/admin/classes',
      '/admin/exams',
      '/admin/fees',
      '/admin/medical',
      '/admin/notices',
      '/admin/timetable',
    ];
  }

  static List<String> _getTeacherRoutes() {
    return [
      '/teacher/dashboard',
      '/teacher/attendance',
      '/teacher/homework',
      '/teacher/marks',
      '/teacher/profile',
      '/teacher/timetable',
      '/teacher/chat',
    ];
  }

  static List<String> _getStudentRoutes() {
    return [
      '/student/dashboard',
      '/student/homework',
      '/student/attendance',
      '/student/fees',
      '/student/profile',
      '/student/timetable',
      '/student/notifications',
      '/student/medical-reports',
      '/student/exam-timetable',
      '/student/results',
    ];
  }
}
