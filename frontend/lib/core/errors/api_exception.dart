/// Typed domain exception for network and backend communication failures
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.details,
  });

  @override
  String toString() => 'ApiException(status: $statusCode, code: $errorCode, message: $message)';

  /// Returns user-friendly presentation message suitable for UI snackbars or error banners
  String get userFriendlyMessage {
    if (statusCode == 503) {
      return 'The store service is temporarily offline or database is initializing. Please try again shortly.';
    }
    if (statusCode == 404) {
      return message.isNotEmpty ? message : 'The requested item could not be found.';
    }
    if (statusCode == 400) {
      if (errorCode == 'INSUFFICIENT_STOCK') {
        return message;
      }
      return message.isNotEmpty ? message : 'Invalid request details. Please check your inputs.';
    }
    if (statusCode != null && statusCode! >= 500) {
      return 'Server encountered an unexpected issue. Please retry.';
    }
    return message;
  }
}
