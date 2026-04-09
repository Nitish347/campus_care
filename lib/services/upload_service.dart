import 'package:campus_care/services/api/upload_api_service.dart';

class UploadService {
  static final UploadApiService _apiService = UploadApiService();

  static Future<String> uploadTeacherProfileImage({
    required String teacherId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final data = await _apiService.uploadProfileImage(
      entityType: 'teacher',
      entityId: teacherId,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    return (data['profile_image_url'] ?? '').toString();
  }

  static Future<String> uploadStudentProfileImage({
    required String studentId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final data = await _apiService.uploadProfileImage(
      entityType: 'student',
      entityId: studentId,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    return (data['profile_image_url'] ?? '').toString();
  }

  static Future<String> uploadNoticeImage({
    required List<int> fileBytes,
    required String fileName,
    String? adminId,
  }) async {
    final data = await _apiService.uploadNoticeImage(
      fileBytes: fileBytes,
      fileName: fileName,
      adminId: adminId,
    );
    return (data['notice_image_url'] ?? '').toString();
  }

  static Future<String> uploadAdminProfileImage({
    required String adminId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final data = await _apiService.uploadProfileImage(
      entityType: 'admin',
      entityId: adminId,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    return (data['profile_image_url'] ?? '').toString();
  }
}
