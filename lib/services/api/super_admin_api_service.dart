import 'package:campus_care/core/api_client.dart';

class SuperAdminApiService {
  final ApiClient _apiClient = ApiClient();
  final String _basePath = '/super-admin';

  // Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _apiClient.get('$_basePath/dashboard/stats');
    return response['data'];
  }

  // School Management
  Future<List<dynamic>> getAllSchools() async {
    final response = await _apiClient.get('$_basePath/schools');
    return response['data'];
  }

  Future<Map<String, dynamic>> getSchoolById(String id) async {
    final response = await _apiClient.get('$_basePath/schools/$id');
    return response['data'];
  }

  Future<Map<String, dynamic>> updateSchool(
      String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      '$_basePath/schools/$id',
      body: data,
    );
    return response['data'];
  }

  Future<void> deleteSchool(String id) async {
    await _apiClient.delete('$_basePath/schools/$id');
  }

  // Student Management - All Students
  Future<List<dynamic>> getAllStudents() async {
    final response = await _apiClient.get('$_basePath/students');
    return response['data'];
  }

  Future<Map<String, dynamic>> updateStudent(
      String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      '$_basePath/students/$id',
      body: data,
    );
    return response['data'];
  }

  Future<void> deleteStudent(String id) async {
    await _apiClient.delete('$_basePath/students/$id');
  }

  // Student Management - By School
  Future<List<dynamic>> getSchoolStudents(String schoolId) async {
    final response =
        await _apiClient.get('$_basePath/schools/$schoolId/students');
    return response['data'];
  }

  Future<Map<String, dynamic>> createSchoolStudent(
      String schoolId, Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      '$_basePath/schools/$schoolId/students',
      body: data,
    );
    return response['data'];
  }

  // Teacher Management - All Teachers
  Future<List<dynamic>> getAllTeachers() async {
    final response = await _apiClient.get('$_basePath/teachers');
    return response['data'];
  }

  Future<Map<String, dynamic>> updateTeacher(
      String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      '$_basePath/teachers/$id',
      body: data,
    );
    return response['data'];
  }

  Future<void> deleteTeacher(String id) async {
    await _apiClient.delete('$_basePath/teachers/$id');
  }

  // Teacher Management - By School
  Future<List<dynamic>> getSchoolTeachers(String schoolId) async {
    final response =
        await _apiClient.get('$_basePath/schools/$schoolId/teachers');
    return response['data'];
  }

  Future<Map<String, dynamic>> createSchoolTeacher(
      String schoolId, Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      '$_basePath/schools/$schoolId/teachers',
      body: data,
    );
    return response['data'];
  }

  // Resource Management - By School
  Future<List<dynamic>> getSchoolClasses(String schoolId) async {
    final response =
        await _apiClient.get('$_basePath/schools/$schoolId/classes');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolAttendance(String schoolId) async {
    final response =
        await _apiClient.get('$_basePath/schools/$schoolId/attendance');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolExams(String schoolId) async {
    final response = await _apiClient.get('$_basePath/schools/$schoolId/exams');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolFees(String schoolId) async {
    final response = await _apiClient.get('$_basePath/schools/$schoolId/fees');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolHomework(String schoolId) async {
    final response =
        await _apiClient.get('$_basePath/schools/$schoolId/homework');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolNotices(String schoolId) async {
    final response =
        await _apiClient.get('$_basePath/schools/$schoolId/notices');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolTimetables(String schoolId) async {
    final response =
        await _apiClient.get('$_basePath/schools/$schoolId/timetables');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolMedicalRecords(String schoolId) async {
    final response =
        await _apiClient.get('$_basePath/schools/$schoolId/medical-records');
    return response['data'];
  }
}
