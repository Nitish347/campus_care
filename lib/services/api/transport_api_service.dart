import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

class TransportApiService {
  final ApiClient _apiClient = ApiClient();

  String get _endpoint => AppConstants.transportEndpoint;

  Future<List<dynamic>> getDrivers({bool? isActive}) async {
    final queryParams = <String, dynamic>{};
    if (isActive != null) {
      queryParams['is_active'] = isActive ? 1 : 0;
    }

    final response = await _apiClient.get(
      '$_endpoint/drivers',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>?> getDriverById(String id) async {
    final response = await _apiClient.get('$_endpoint/drivers/$id');
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>> createDriver(
      Map<String, dynamic> payload) async {
    final response = await _apiClient.post('$_endpoint/drivers', body: payload);
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to create driver');
  }

  Future<Map<String, dynamic>> updateDriver(
      String id, Map<String, dynamic> payload) async {
    final response =
        await _apiClient.patch('$_endpoint/drivers/$id', body: payload);
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to update driver');
  }

  Future<void> deleteDriver(String id) async {
    await _apiClient.delete('$_endpoint/drivers/$id');
  }

  Future<List<dynamic>> getVehicles(
      {bool? isActive, String? vehicleType}) async {
    final queryParams = <String, dynamic>{};
    if (isActive != null) {
      queryParams['is_active'] = isActive ? 1 : 0;
    }
    if (vehicleType != null && vehicleType.isNotEmpty) {
      queryParams['vehicle_type'] = vehicleType;
    }

    final response = await _apiClient.get(
      '$_endpoint/vehicles',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> createVehicle(
      Map<String, dynamic> payload) async {
    final response =
        await _apiClient.post('$_endpoint/vehicles', body: payload);
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to create vehicle');
  }

  Future<Map<String, dynamic>> updateVehicle(
      String id, Map<String, dynamic> payload) async {
    final response =
        await _apiClient.patch('$_endpoint/vehicles/$id', body: payload);
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to update vehicle');
  }

  Future<void> deleteVehicle(String id) async {
    await _apiClient.delete('$_endpoint/vehicles/$id');
  }

  Future<List<dynamic>> getRoutes({bool? isActive}) async {
    final queryParams = <String, dynamic>{};
    if (isActive != null) {
      queryParams['is_active'] = isActive ? 1 : 0;
    }

    final response = await _apiClient.get(
      '$_endpoint/routes',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> createRoute(Map<String, dynamic> payload) async {
    final response = await _apiClient.post('$_endpoint/routes', body: payload);
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to create route');
  }

  Future<Map<String, dynamic>> updateRoute(
      String id, Map<String, dynamic> payload) async {
    final response =
        await _apiClient.patch('$_endpoint/routes/$id', body: payload);
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to update route');
  }

  Future<void> deleteRoute(String id) async {
    await _apiClient.delete('$_endpoint/routes/$id');
  }

  Future<List<dynamic>> getRouteStops(String routeId) async {
    final response = await _apiClient.get('$_endpoint/routes/$routeId/stops');
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> createRouteStop(
    String routeId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      '$_endpoint/routes/$routeId/stops',
      body: payload,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to create route stop');
  }

  Future<Map<String, dynamic>> updateRouteStop(
    String stopId,
    Map<String, dynamic> payload,
  ) async {
    final response =
        await _apiClient.patch('$_endpoint/stops/$stopId', body: payload);
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to update route stop');
  }

  Future<void> deleteRouteStop(String stopId) async {
    await _apiClient.delete('$_endpoint/stops/$stopId');
  }

  Future<List<dynamic>> getAssignments({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      '$_endpoint/assignments',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> createAssignment(
      Map<String, dynamic> payload) async {
    final response =
        await _apiClient.post('$_endpoint/assignments', body: payload);
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to create assignment');
  }

  Future<Map<String, dynamic>> updateAssignment(
    String assignmentId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch(
      '$_endpoint/assignments/$assignmentId',
      body: payload,
    );
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to update assignment');
  }

  Future<void> deleteAssignment(String assignmentId) async {
    await _apiClient.delete('$_endpoint/assignments/$assignmentId');
  }
}
