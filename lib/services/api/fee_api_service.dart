import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for fee operations
class FeeApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all fees with optional filters
  Future<List<dynamic>> getFees({
    String? studentId,
    String? classId,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (studentId != null) queryParams['studentId'] = studentId;
    if (classId != null) queryParams['classId'] = classId;
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      AppConstants.feesEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get fee by ID
  Future<Map<String, dynamic>?> getFeeById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.feesEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Create new fee
  Future<Map<String, dynamic>> createFee(
    Map<String, dynamic> feeData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.feesEndpoint,
      body: feeData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to create fee');
  }

  /// Update fee
  Future<Map<String, dynamic>> updateFee(
    String id,
    Map<String, dynamic> feeData,
  ) async {
    final response = await _apiClient.put(
      '${AppConstants.feesEndpoint}/$id',
      body: feeData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update fee');
  }

  /// Delete fee
  Future<void> deleteFee(String id) async {
    await _apiClient.delete('${AppConstants.feesEndpoint}/$id');
  }
}
