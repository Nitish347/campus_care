import 'package:campus_care/models/user.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/services/dummy_data_service.dart';

class AuthService {
  // Sample users for demonstration
  static final List<Map<String, dynamic>> _sampleUsers = [
    {
      'id': 'admin_001',
      'email': 'admin@schoolstream.com',
      'password': 'admin123',
      'name': 'School Administrator',
      'role': AppConstants.roleAdmin,
      'phone': '+1234567890',
      'createdAt':
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    },
    {
      'id': 'teacher_001',
      'email': 'teacher@schoolstream.com',
      'password': 'teacher123',
      'name': 'Sarah Johnson',
      'role': AppConstants.roleTeacher,
      'phone': '+1234567891',
      'createdAt':
          DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    },
    {
      'id': 'teacher_002',
      'email': 'math.teacher@schoolstream.com',
      'password': 'teacher123',
      'name': 'Michael Brown',
      'role': AppConstants.roleTeacher,
      'phone': '+1234567892',
      'createdAt':
          DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    },
    {
      'id': 'student_001',
      'email': 'student1@schoolstream.com',
      'password': 'student123',
      'name': 'Emma Wilson',
      'role': AppConstants.roleStudent,
      'phone': '+1234567001',
      'createdAt':
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    },
    {
      'id': 'student_002',
      'email': 'student2@schoolstream.com',
      'password': 'student123',
      'name': 'Liam Johnson',
      'role': AppConstants.roleStudent,
      'phone': '+1234567002',
      'createdAt':
          DateTime.now().subtract(const Duration(days: 28)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    },
  ];

  static Future<void> initializeSampleData() async {
    // Initialize sample users if not already present
    if (!StorageService.hasData('users')) {
      await StorageService.saveData('users', _sampleUsers);
    }

    // Initialize dummy data
    await _initializeDummyData();
  }

  static Future<void> _initializeDummyData() async {
    // Initialize homework data
    if (!StorageService.hasData(AppConstants.keyHomework)) {
      await StorageService.saveData(
        AppConstants.keyHomework,
        DummyDataService.getSampleHomework(),
      );
    }
    
    // Initialize attendance data
    if (!StorageService.hasData(AppConstants.keyAttendance)) {
      await StorageService.saveData(
        AppConstants.keyAttendance,
        DummyDataService.getSampleAttendance(),
      );
    }
    
    // Initialize fee data
    if (!StorageService.hasData(AppConstants.keyFees)) {
      await StorageService.saveData(
        AppConstants.keyFees,
        DummyDataService.getSampleFees(),
      );
    }
    
    // Initialize notices
    if (!StorageService.hasData(AppConstants.keyNotices)) {
      await StorageService.saveData(
        AppConstants.keyNotices,
        DummyDataService.getSampleNotices(),
      );
    }
    
    // Initialize classes
    if (!StorageService.hasData(AppConstants.keyClasses)) {
      await StorageService.saveData(
        AppConstants.keyClasses,
        DummyDataService.getSampleClasses(),
      );
    }
    
    // Initialize subjects
    if (!StorageService.hasData(AppConstants.keySubjects)) {
      await StorageService.saveData(
        AppConstants.keySubjects,
        DummyDataService.getSampleSubjects(),
      );
    }
    
    // Initialize exams
    if (!StorageService.hasData(AppConstants.keyExams)) {
      await StorageService.saveData(
        AppConstants.keyExams,
        DummyDataService.getSampleExams(),
      );
    }
    
    // Initialize medical records
    if (!StorageService.hasData(AppConstants.keyMedicalRecords)) {
      await StorageService.saveData(
        AppConstants.keyMedicalRecords,
        DummyDataService.getSampleMedicalRecords(),
      );
    }
    
    // Initialize messages
    if (!StorageService.hasData(AppConstants.keyMessages)) {
      await StorageService.saveData(
        AppConstants.keyMessages,
        DummyDataService.getSampleChats(),
      );
    }
  }

  static Future<User?> login(String email, String password) async {
    try {
      await initializeSampleData();

      // Get all users from storage
      final users = StorageService.getData('users');

      // Find user by email and password
      final userData = users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (userData.isNotEmpty) {
        final user = User.fromJson(userData);

        // Store login state
        await StorageService.setLoggedIn(true);
        await StorageService.setCurrentUser(userData);
        await StorageService.setUserRole(user.role);

        return user;
      }

      return null;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  static Future<void> logout() async {
    await StorageService.setLoggedIn(false);
    await StorageService.clearData(AppConstants.keyCurrentUser);
    await StorageService.clearData(AppConstants.keyUserRole);
  }

  static User? getCurrentUser() {
    final userData = StorageService.currentUser;
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  static bool get isLoggedIn => StorageService.isLoggedIn;

  static String? get userRole => StorageService.userRole;

  static Future<bool> changePassword(
      String oldPassword, String newPassword) async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) return false;

      // Get all users from storage
      final users = StorageService.getData('users');

      // Find and verify current user's password
      final userIndex =
          users.indexWhere((user) => user['id'] == currentUser.id);
      if (userIndex == -1 || users[userIndex]['password'] != oldPassword) {
        return false;
      }

      // Update password
      users[userIndex]['password'] = newPassword;
      users[userIndex]['updatedAt'] = DateTime.now().toIso8601String();

      // Save back to storage
      await StorageService.saveData('users', users);

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) return false;

      // Get all users from storage
      final users = StorageService.getData('users');

      // Find current user
      final userIndex =
          users.indexWhere((user) => user['id'] == currentUser.id);
      if (userIndex == -1) return false;

      // Update profile data
      users[userIndex].addAll(profileData);
      users[userIndex]['updatedAt'] = DateTime.now().toIso8601String();

      // Save back to storage
      await StorageService.saveData('users', users);

      // Update current user in storage
      await StorageService.setCurrentUser(users[userIndex]);

      return true;
    } catch (e) {
      return false;
    }
  }
}
