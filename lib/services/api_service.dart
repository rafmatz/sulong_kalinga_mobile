import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sulong_kalinga_mobile/config/api_config.dart';
import 'dart:math';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

class ApiService {
  final http.Client _client;
  String? _token;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      // Make sure token format is correct
      headers['Authorization'] = 'Bearer $_token';
      print('Using token in request: Bearer ${_token!.substring(0, min(20, _token!.length))}...');
    } else {
      print('No token available for request');
    }

    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ));
      }

      final response = await _client.get(
        uri,
        headers: _getHeaders(),
      );

      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _getHeaders(),
        body: body != null ? json.encode(body) : null,
      );

      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  ApiResponse<T> _processResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    try {
      final responseBody = json.decode(response.body);
      print('Raw response body: $responseBody');
      
      final bool success = response.statusCode >= 200 && response.statusCode < 300;
      final String message = responseBody['message'] ?? (success ? 'Success' : 'Error');
      
      // IMPORTANT FIX: Return the entire response body as data
      return ApiResponse(
        success: success,
        message: message,
        data: responseBody as T?, // This is the critical change
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('Process response error: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to process response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }
  String get baseUrl => ApiConfig.baseUrl; // Replace with your actual base URL
}