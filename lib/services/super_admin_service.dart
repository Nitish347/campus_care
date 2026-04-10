import 'package:campus_care/core/constants/admin_module_permissions.dart';
import 'package:campus_care/models/admin/admin.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/services/api/super_admin_api_service.dart';

class SuperAdminService {
  static final SuperAdminApiService _apiService = SuperAdminApiService();

  static Map<String, bool> _normalizeModulePermissions(dynamic raw) {
    final normalized = Map<String, bool>.from(defaultAdminModulePermissions);
    if (raw is Map) {
      for (final key in AdminModulePermissionKeys.all) {
        if (raw.containsKey(key)) {
          final value = raw[key];
          if (value is bool) {
            normalized[key] = value;
          } else if (value is num) {
            normalized[key] = value != 0;
          } else if (value is String) {
            final parsed = value.trim().toLowerCase();
            if (parsed == 'true' || parsed == '1' || parsed == 'yes') {
              normalized[key] = true;
            } else if (parsed == 'false' || parsed == '0' || parsed == 'no') {
              normalized[key] = false;
            }
          }
        }
      }
    }
    return normalized;
  }

  // Dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      return await _apiService.getDashboardStats();
    } catch (e) {
      throw Exception('Failed to load dashboard stats: $e');
    }
  }

  // School Management
  static Future<List<Admin>> getAllSchools() async {
    try {
      final List<dynamic> data = await _apiService.getAllSchools();
      return data.map((json) => Admin.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load schools: $e');
    }
  }

  static Future<Admin> getSchoolById(String id) async {
    try {
      final data = await _apiService.getSchoolById(id);
      return Admin.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load school: $e');
    }
  }

  static Future<Admin> updateSchool(
      String id, Map<String, dynamic> schoolData) async {
    try {
      final data = await _apiService.updateSchool(id, schoolData);
      return Admin.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update school: $e');
    }
  }

  static Future<void> deleteSchool(String id) async {
    try {
      await _apiService.deleteSchool(id);
    } catch (e) {
      throw Exception('Failed to delete school: $e');
    }
  }

  static Future<Admin> createSchool(Map<String, dynamic> schoolData) async {
    try {
      final data = await _apiService.createSchool(schoolData);
      return Admin.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create school: $e');
    }
  }

  static Future<Map<String, bool>> getSchoolModulePermissions(
      String schoolId) async {
    try {
      final data = await _apiService.getSchoolModulePermissions(schoolId);
      return _normalizeModulePermissions(data['module_permissions']);
    } catch (e) {
      throw Exception('Failed to load module permissions: $e');
    }
  }

  static Future<Map<String, bool>> updateSchoolModulePermissions(
    String schoolId,
    Map<String, bool> permissions,
  ) async {
    try {
      final data = await _apiService.updateSchoolModulePermissions(
          schoolId, permissions);
      return _normalizeModulePermissions(data['module_permissions']);
    } catch (e) {
      throw Exception('Failed to update module permissions: $e');
    }
  }

  // Student Management - All
  static Future<List<Student>> getAllStudents() async {
    try {
      final List<dynamic> data = await _apiService.getAllStudents();
      return data.map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

  static Future<Student> updateStudent(String id, Student student) async {
    try {
      final data = await _apiService.updateStudent(id, student.toJson());
      return Student.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  static Future<void> deleteStudent(String id) async {
    try {
      await _apiService.deleteStudent(id);
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  // Student Management - By School
  static Future<List<Student>> getSchoolStudents(String schoolId) async {
    try {
      final List<dynamic> data = await _apiService.getSchoolStudents(schoolId);
      return data.map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load school students: $e');
    }
  }

  static Future<Student> createSchoolStudent(
      String schoolId, Student student) async {
    try {
      final data =
          await _apiService.createSchoolStudent(schoolId, student.toJson());
      return Student.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }

  // Teacher Management - All
  static Future<List<Teacher>> getAllTeachers() async {
    try {
      final List<dynamic> data = await _apiService.getAllTeachers();
      return data.map((json) => Teacher.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load teachers: $e');
    }
  }

  static Future<Teacher> updateTeacher(String id, Teacher teacher) async {
    try {
      final data = await _apiService.updateTeacher(id, teacher.toJson());
      return Teacher.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update teacher: $e');
    }
  }

  static Future<void> deleteTeacher(String id) async {
    try {
      await _apiService.deleteTeacher(id);
    } catch (e) {
      throw Exception('Failed to delete teacher: $e');
    }
  }

  // Teacher Management - By School
  static Future<List<Teacher>> getSchoolTeachers(String schoolId) async {
    try {
      final List<dynamic> data = await _apiService.getSchoolTeachers(schoolId);
      return data.map((json) => Teacher.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load school teachers: $e');
    }
  }

  static Future<Teacher> createSchoolTeacher(
      String schoolId, Teacher teacher) async {
    try {
      final data =
          await _apiService.createSchoolTeacher(schoolId, teacher.toJson());
      return Teacher.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create teacher: $e');
    }
  }

  // Resource Management - By School
  static Future<List<dynamic>> getSchoolClasses(String schoolId) async {
    try {
      return await _apiService.getSchoolClasses(schoolId);
    } catch (e) {
      throw Exception('Failed to load school classes: $e');
    }
  }

  static Future<List<dynamic>> getSchoolAttendance(String schoolId) async {
    try {
      return await _apiService.getSchoolAttendance(schoolId);
    } catch (e) {
      throw Exception('Failed to load school attendance: $e');
    }
  }

  static Future<List<dynamic>> getSchoolExams(String schoolId) async {
    try {
      return await _apiService.getSchoolExams(schoolId);
    } catch (e) {
      throw Exception('Failed to load school exams: $e');
    }
  }

  static Future<List<dynamic>> getSchoolFees(String schoolId) async {
    try {
      return await _apiService.getSchoolFees(schoolId);
    } catch (e) {
      throw Exception('Failed to load school fees: $e');
    }
  }

  static Future<List<dynamic>> getSchoolHomework(String schoolId) async {
    try {
      return await _apiService.getSchoolHomework(schoolId);
    } catch (e) {
      throw Exception('Failed to load school homework: $e');
    }
  }

  static Future<List<dynamic>> getSchoolNotices(String schoolId) async {
    try {
      return await _apiService.getSchoolNotices(schoolId);
    } catch (e) {
      throw Exception('Failed to load school notices: $e');
    }
  }

  static Future<List<dynamic>> getSchoolTimetables(String schoolId) async {
    try {
      return await _apiService.getSchoolTimetables(schoolId);
    } catch (e) {
      throw Exception('Failed to load school timetables: $e');
    }
  }

  static Future<List<dynamic>> getSchoolMedicalRecords(String schoolId) async {
    try {
      return await _apiService.getSchoolMedicalRecords(schoolId);
    } catch (e) {
      throw Exception('Failed to load school medical records: $e');
    }
  }
}
