import 'package:campus_care/core/api_client.dart';

class SuperAdminApiService {
  final ApiClient _apiClient = ApiClient();

  // Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _apiClient.get('/super-admin/analytics');
    return response['data'];
  }

  // ================== School Management ==================

  Future<List<dynamic>> getAllSchools() async {
    final response = await _apiClient.get('/admins');
    return response['data'];
  }

  Future<Map<String, dynamic>> getSchoolById(String id) async {
    final response = await _apiClient.get('/admins/$id');
    return response['data'];
  }

  // Create School - NEW METHOD
  Future<Map<String, dynamic>> createSchool(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/admins', body: data);
    return response['data'];
  }

  Future<Map<String, dynamic>> updateSchool(
      String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch('/admins/$id', body: data);
    return response['data'];
  }

  Future<Map<String, dynamic>> getSchoolModulePermissions(String id) async {
    final response = await _apiClient.get('/admins/$id/module-permissions');
    return response['data'];
  }

  Future<Map<String, dynamic>> updateSchoolModulePermissions(
      String id, Map<String, bool> modulePermissions) async {
    final response = await _apiClient.put(
      '/admins/$id/module-permissions',
      body: {'module_permissions': modulePermissions},
    );
    return response['data'];
  }

  Future<void> deleteSchool(String id) async {
    await _apiClient.delete('/admins/$id');
  }

  // ================== Student Management ==================

  // Get all students (no admin_id parameter)
  Future<List<dynamic>> getAllStudents() async {
    final response = await _apiClient.get('/students');
    return response['data'];
  }

  // Get students from specific school
  Future<List<dynamic>> getSchoolStudents(String schoolId) async {
    final response = await _apiClient.get('/students?admin_id=$schoolId');
    return response['data'];
  }

  // Create student in specific school
  Future<Map<String, dynamic>> createSchoolStudent(
      String schoolId, Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      '/students?admin_id=$schoolId',
      body: data,
    );
    return response['data'];
  }

  // Update any student
  Future<Map<String, dynamic>> updateStudent(
      String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch('/students/$id', body: data);
    return response['data'];
  }

  // Delete any student
  Future<void> deleteStudent(String id) async {
    await _apiClient.delete('/students/$id');
  }

  // ================== Teacher Management ==================

  // Get all teachers
  Future<List<dynamic>> getAllTeachers() async {
    final response = await _apiClient.get('/teachers');
    return response['data'];
  }

  // Get teachers from specific school
  Future<List<dynamic>> getSchoolTeachers(String schoolId) async {
    final response = await _apiClient.get('/teachers?admin_id=$schoolId');
    return response['data'];
  }

  // Create teacher in specific school
  Future<Map<String, dynamic>> createSchoolTeacher(
      String schoolId, Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      '/teachers?admin_id=$schoolId',
      body: data,
    );
    return response['data'];
  }

  // Update any teacher
  Future<Map<String, dynamic>> updateTeacher(
      String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch('/teachers/$id', body: data);
    return response['data'];
  }

  // Delete any teacher
  Future<void> deleteTeacher(String id) async {
    await _apiClient.delete('/teachers/$id');
  }

  // ================== Resource Management ==================

  Future<List<dynamic>> getSchoolClasses(String schoolId) async {
    final response = await _apiClient.get('/classes?admin_id=$schoolId');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolAttendance(String schoolId) async {
    final response = await _apiClient.get('/attendance?admin_id=$schoolId');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolExams(String schoolId) async {
    final response = await _apiClient.get('/exams?admin_id=$schoolId');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolFees(String schoolId) async {
    final response = await _apiClient.get('/fees?admin_id=$schoolId');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolHomework(String schoolId) async {
    final response = await _apiClient.get('/homework?admin_id=$schoolId');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolNotices(String schoolId) async {
    final response = await _apiClient.get('/notices?admin_id=$schoolId');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolTimetables(String schoolId) async {
    final response = await _apiClient.get('/timetables?admin_id=$schoolId');
    return response['data'];
  }

  Future<List<dynamic>> getSchoolMedicalRecords(String schoolId) async {
    final response =
        await _apiClient.get('/medical-records?admin_id=$schoolId');
    return response['data'];
  }
}
