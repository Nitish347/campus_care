import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/core/api_exception.dart';
import 'package:campus_care/services/storage_service.dart';

/// Centralized API client for making HTTP requests
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();

  /// Get the full API URL
  String _getUrl(String endpoint) {
    return '${AppConstants.baseUrl}${AppConstants.apiVersion}$endpoint';
  }

  /// Get headers with authentication token
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle API response and errors
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // Try to parse response body
    dynamic responseData;
    try {
      responseData =
          response.body.isNotEmpty ? json.decode(response.body) : null;
    } catch (e) {
      responseData = {'message': response.body};
    }

    // Handle different status codes
    if (statusCode >= 200 && statusCode < 300) {
      return responseData;
    }

    // Extract error message
    String errorMessage = 'An error occurred';
    if (responseData is Map) {
      errorMessage =
          responseData['message'] ?? responseData['error'] ?? errorMessage;
    }

    // Throw appropriate exception based on status code
    switch (statusCode) {
      case 400:
        throw BadRequestException(message: errorMessage, data: responseData);
      case 401:
        // Clear stored token on unauthorized
        StorageService.clearData(AppConstants.keyAuthToken);
        throw UnauthorizedException(message: errorMessage, data: responseData);
      case 403:
        throw ForbiddenException(message: errorMessage, data: responseData);
      case 404:
        throw NotFoundException(message: errorMessage, data: responseData);
      case 408:
        throw TimeoutException(message: errorMessage);
      case 500:
      case 501:
      case 502:
      case 503:
        throw ServerException(
          message: errorMessage,
          statusCode: statusCode,
          data: responseData,
        );
      default:
        throw ApiException(
          message: errorMessage,
          statusCode: statusCode,
          data: responseData,
        );
    }
  }

  /// Handle network and timeout errors
  Future<T> _executeRequest<T>(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(
        Duration(seconds: AppConstants.requestTimeout),
        onTimeout: () {
          throw TimeoutException();
        },
      );
      log(response.body);
      return _handleResponse(response) as T;
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse(_getUrl(endpoint)).replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
    final headers = await _getHeaders(includeAuth: includeAuth);
    log('API GET: $uri');

    return _executeRequest(() => _client.get(uri, headers: headers));
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse(_getUrl(endpoint));
    final headers = await _getHeaders(includeAuth: includeAuth);
    log('API POST: $uri');

    return _executeRequest(
      () => _client.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ),
    );
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse(_getUrl(endpoint));
    final headers = await _getHeaders(includeAuth: includeAuth);
    log('API PUT: $uri');

    return _executeRequest(
      () => _client.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ),
    );
  }

  /// PATCH request
  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse(_getUrl(endpoint));
    final headers = await _getHeaders(includeAuth: includeAuth);
    log('API PATCH: $uri');

    return _executeRequest(
      () => _client.patch(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ),
    );
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse(_getUrl(endpoint));
    final headers = await _getHeaders(includeAuth: includeAuth);
    log('API DELETE: $uri');

    return _executeRequest(() => _client.delete(uri, headers: headers));
  }

  /// Multipart POST request for file uploads
  Future<dynamic> postMultipart(
    String endpoint, {
    required String fileFieldName,
    required List<int> fileBytes,
    required String fileName,
    Map<String, String>? fields,
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse(_getUrl(endpoint));
    final headers = await _getHeaders(includeAuth: includeAuth);
    headers.remove('Content-Type');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..fields.addAll(fields ?? {})
        ..files.add(
          http.MultipartFile.fromBytes(
            fileFieldName,
            fileBytes,
            filename: fileName,
          ),
        );

      log('API MULTIPART POST: $uri');

      final streamed = await request.send().timeout(
        Duration(seconds: AppConstants.requestTimeout),
        onTimeout: () {
          throw TimeoutException();
        },
      );

      final response = await http.Response.fromStream(streamed);
      log(response.body);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  /// Dispose the client
  void dispose() {
    _client.close();
  }
}
