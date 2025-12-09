import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for medical record operations
class MedicalRecordApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all medical records with optional filters
  Future<List<dynamic>> getMedicalRecords({
    String? studentId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (studentId != null) queryParams['studentId'] = studentId;

    final response = await _apiClient.get(
      AppConstants.medicalRecordsEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get medical record by ID
  Future<Map<String, dynamic>?> getMedicalRecordById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.medicalRecordsEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Create new medical record
  Future<Map<String, dynamic>> createMedicalRecord(
    Map<String, dynamic> recordData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.medicalRecordsEndpoint,
      body: recordData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to create medical record');
  }

  /// Update medical record
  Future<Map<String, dynamic>> updateMedicalRecord(
    String id,
    Map<String, dynamic> recordData,
  ) async {
    final response = await _apiClient.put(
      '${AppConstants.medicalRecordsEndpoint}/$id',
      body: recordData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update medical record');
  }

  /// Delete medical record
  Future<void> deleteMedicalRecord(String id) async {
    await _apiClient.delete('${AppConstants.medicalRecordsEndpoint}/$id');
  }
}
