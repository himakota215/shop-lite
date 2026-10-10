import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../errors/api_exception.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Execute an HTTP GET request
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = _buildUri(endpoint, queryParams);

    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(AppConfig.requestTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        message: 'Network request timed out. Please check your internet connection.',
        errorCode: 'TIMEOUT',
      );
    } on SocketException {
      throw const ApiException(
        message: 'Unable to reach backend server. Please verify the server is running.',
        errorCode: 'NETWORK_ERROR',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        message: 'Connection failed: ${e.message}',
        errorCode: 'CLIENT_ERROR',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'An unexpected connection error occurred: $e',
        errorCode: 'UNKNOWN',
      );
    }
  }

  /// Execute an HTTP POST request
  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    final uri = _buildUri(endpoint);

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(AppConfig.requestTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        message: 'Order submission timed out. Please verify your connection before retrying.',
        errorCode: 'TIMEOUT',
      );
    } on SocketException {
      throw const ApiException(
        message: 'Unable to reach server to submit order.',
        errorCode: 'NETWORK_ERROR',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        message: 'Network error during submission: ${e.message}',
        errorCode: 'CLIENT_ERROR',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Unexpected submission failure: $e',
        errorCode: 'UNKNOWN',
      );
    }
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final base = AppConfig.baseUrl;
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '$base$normalizedEndpoint';

    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      // Filter out null or empty params
      final cleanParams = Map<String, String>.fromEntries(
        queryParams.entries.where((e) => e.value.trim().isNotEmpty),
      );
      return uri.replace(queryParameters: cleanParams);
    }
    return uri;
  }

  dynamic _handleResponse(http.Response response) {
    dynamic decoded;
    try {
      if (response.body.isNotEmpty) {
        decoded = jsonDecode(response.body);
      }
    } catch (_) {
      throw ApiException(
        message: 'Failed to decode server response: Invalid JSON',
        statusCode: response.statusCode,
        errorCode: 'INVALID_JSON',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    String errorMessage = 'Request failed with status ${response.statusCode}';
    String? errorCode;
    dynamic details;

    if (decoded is Map<String, dynamic>) {
      if (decoded['error'] != null) {
        errorMessage = decoded['error'].toString();
      } else if (decoded['message'] != null) {
        errorMessage = decoded['message'].toString();
      }

      if (decoded['code'] != null) {
        errorCode = decoded['code'].toString();
      }

      if (decoded['details'] != null) {
        details = decoded['details'];
      }
    }

    throw ApiException(
      message: errorMessage,
      statusCode: response.statusCode,
      errorCode: errorCode,
      details: details,
    );
  }
}
