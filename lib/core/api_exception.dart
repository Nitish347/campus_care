/// Base class for all API-related exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

/// Exception thrown when authentication fails (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException({
    String message = 'Unauthorized. Please login again.',
    dynamic data,
  }) : super(
          message: message,
          statusCode: 401,
          data: data,
        );
}

/// Exception thrown when access is forbidden (403)
class ForbiddenException extends ApiException {
  ForbiddenException({
    String message = 'Access forbidden. You do not have permission.',
    dynamic data,
  }) : super(
          message: message,
          statusCode: 403,
          data: data,
        );
}

/// Exception thrown when resource is not found (404)
class NotFoundException extends ApiException {
  NotFoundException({
    String message = 'Resource not found.',
    dynamic data,
  }) : super(
          message: message,
          statusCode: 404,
          data: data,
        );
}

/// Exception thrown when validation fails (400)
class BadRequestException extends ApiException {
  BadRequestException({
    String message = 'Invalid request.',
    dynamic data,
  }) : super(
          message: message,
          statusCode: 400,
          data: data,
        );
}

/// Exception thrown when server error occurs (500+)
class ServerException extends ApiException {
  ServerException({
    String message = 'Server error. Please try again later.',
    int? statusCode,
    dynamic data,
  }) : super(
          message: message,
          statusCode: statusCode ?? 500,
          data: data,
        );
}

/// Exception thrown when network connection fails
class NetworkException extends ApiException {
  NetworkException({
    String message = 'Network error. Please check your internet connection.',
  }) : super(
          message: message,
          statusCode: null,
        );
}

/// Exception thrown when request times out
class TimeoutException extends ApiException {
  TimeoutException({
    String message = 'Request timeout. Please try again.',
  }) : super(
          message: message,
          statusCode: 408,
        );
}
