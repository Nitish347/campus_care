import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/services/api/teacher_api_service.dart';

class TeacherService {
  static final TeacherApiService _apiService = TeacherApiService();

  static Future<List<Teacher>> getAllTeachers() async {
    try {
      final List<dynamic> data = await _apiService.getTeachers();
      return data.map((json) => Teacher.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load teachers: $e');
    }
  }

  static Future<Teacher?> getTeacherById(String id) async {
    try {
      final data = await _apiService.getTeacherById(id);
      if (data != null) {
        return Teacher.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String> addTeacher(Teacher teacher) async {
    try {
      final response = await _apiService.createTeacher(teacher.toJson());
      return (response['id'] ?? response['_id'] ?? '').toString();
    } catch (e) {
      throw Exception('Failed to create teacher: $e');
    }
  }

  static Future<bool> updateTeacher(Teacher teacher) async {
    try {
      await _apiService.updateTeacher(teacher.id, teacher.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> deleteTeacher(String id) async {
    await _apiService.deleteTeacher(id);
  }
}
