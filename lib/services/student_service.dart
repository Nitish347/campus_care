import 'dart:developer';

import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/services/api/student_api_service.dart';

class StudentPage {
  final List<Student> students;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const StudentPage({
    required this.students,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}

class StudentService {
  static final StudentApiService _apiService = StudentApiService();

  static Future<List<Student>> getAllStudents() async {
    try {
      final List<dynamic> data = await _apiService.getStudents();
      return data.map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

  static Future<Student?> getStudentById(String id) async {
    try {
      final data = await _apiService.getStudentById(id);
      if (data != null) {
        return Student.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Student>> getStudentsByClass(
      String classId, String section) async {
    try {
      final filters = {
        'class': classId,
        if (section.isNotEmpty) 'section': section,
      };
      final List<dynamic> data =
          await _apiService.getStudents(filters: filters);
      return data.map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Student>> searchStudents(String query) async {
    try {
      final List<dynamic> data = await _apiService.searchStudents(query);
      return data.map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<StudentPage> getStudentsPage({
    required int page,
    int limit = 50,
    String? search,
    String? classId,
    String? section,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final response = await _apiService.getStudentsPage(
        page: page,
        limit: limit,
        search: search,
        classId: classId,
        section: section,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      final data = (response['data'] as List<dynamic>? ?? [])
          .map((json) => Student.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      final pagination =
          Map<String, dynamic>.from(response['pagination'] as Map? ?? {});

      return StudentPage(
        students: data,
        total: (pagination['total'] as num?)?.toInt() ?? data.length,
        page: (pagination['page'] as num?)?.toInt() ?? page,
        limit: (pagination['limit'] as num?)?.toInt() ?? limit,
        totalPages: (pagination['totalPages'] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

  static Future<String> addStudent(Student student) async {
    try {
      final response = await _apiService.createStudent(student.toJson());
      return (response['id'] ?? response['_id'] ?? '').toString();
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to create student: $e');
    }
  }

  static Future<bool> updateStudent(Student student) async {
    try {
      await _apiService.updateStudent(student.id, student.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> deleteStudent(String id) async {
    await _apiService.deleteStudent(id);
  }
}
