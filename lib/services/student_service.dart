import 'dart:developer';

import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/services/api/student_api_service.dart';

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
