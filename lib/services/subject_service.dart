import 'package:campus_care/models/subject.dart';
import 'package:campus_care/services/api/subject_api_service.dart';

class SubjectService {
  static final SubjectApiService _apiService = SubjectApiService();

  static Future<List<Subject>> getAllSubjects() async {
    try {
      final List<dynamic> data = await _apiService.getSubjects();
      return data.map((json) => Subject.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load subjects: $e');
    }
  }

  static Future<List<Subject>> getSubjectsByClass(String classId) async {
    try {
      final subjects = await getAllSubjects();
      return subjects.where((s) => s.classId == classId).toList();
    } catch (e) {
      throw Exception('Failed to load subjects for class: $e');
    }
  }

  static Future<Subject?> getSubjectById(String id) async {
    try {
      final data = await _apiService.getSubjectById(id);
      if (data != null) {
        return Subject.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String> addSubject(Subject subject) async {
    try {
      final response = await _apiService.createSubject(subject.toJson());
      return response['id'] ?? '';
    } catch (e) {
      throw Exception('Failed to create subject: $e');
    }
  }

  static Future<bool> updateSubject(Subject subject) async {
    try {
      await _apiService.updateSubject(subject.id, subject.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> deleteSubject(String id) async {
    await _apiService.deleteSubject(id);
  }
}
