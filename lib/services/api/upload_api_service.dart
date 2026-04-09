import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

class UploadApiService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> uploadProfileImage({
    required String entityType,
    required String entityId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final response = await _apiClient.postMultipart(
      '${AppConstants.uploadsEndpoint}/profile-image/$entityType/$entityId',
      fileFieldName: 'file',
      fileBytes: fileBytes,
      fileName: fileName,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception(response['message'] ?? 'Failed to upload profile image');
  }

  Future<Map<String, dynamic>> uploadNoticeImage({
    required List<int> fileBytes,
    required String fileName,
    String? adminId,
  }) async {
    final endpoint = (adminId != null && adminId.trim().isNotEmpty)
        ? '${AppConstants.uploadsEndpoint}/notice-image?admin_id=${Uri.encodeQueryComponent(adminId.trim())}'
        : '${AppConstants.uploadsEndpoint}/notice-image';

    final response = await _apiClient.postMultipart(
      endpoint,
      fileFieldName: 'file',
      fileBytes: fileBytes,
      fileName: fileName,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception(response['message'] ?? 'Failed to upload notice image');
  }
}
