import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sulong_kalinga_mobile/models/user_model.dart';
import 'package:sulong_kalinga_mobile/services/api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  final ApiService _apiService;

  AuthService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<ApiResponse<User>> login(String email, String password) async {
    print('==========================================');
    print('Attempting to connect to: ${_apiService.baseUrl}/login');
    print('With credentials: $email');
    print('==========================================');
    
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/login',
        body: {'email': email, 'password': password},
      );

      // Add full response debugging
      print('==========================================');
      print('Response received: ${response.statusCode}');
      print('Response success: ${response.success}');
      print('Response message: ${response.message}');
      print('Response data: ${response.data}');
      print('==========================================');

      // Check if the response has the expected structure and data
      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data!;
        
        // Check if the necessary fields exist in the response
        if (responseData.containsKey('token') && responseData.containsKey('user')) {
          // Save token and user data
          await _saveAuthData(responseData['token'], responseData['user']);
          _apiService.setToken(responseData['token']);
          
          // Return successful response with user data
          return ApiResponse(
            success: true,
            message: 'Login successful',
            data: User.fromJson(responseData['user']),
            statusCode: response.statusCode,
          );
        } else {
          // Missing expected fields in the response
          return ApiResponse(
            success: false,
            message: 'Invalid response format: Missing token or user data',
            statusCode: response.statusCode,
          );
        }
      } else {
        // Response was not successful or data is null
        return ApiResponse(
          success: false,
          message: response.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // An exception occurred
      print('==========================================');
      print('Login error: $e');
      print('==========================================');
      
      return ApiResponse(
        success: false,
        message: 'Error: $e',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<bool>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      print('==========================================');
      print('Attempting logout');
      print('Token available: ${token != null}');
      if (token != null) {
        print('Token first 20 chars: ${token.substring(0, 20)}...');
        _apiService.setToken(token);
      }
      print('==========================================');
      
      final response = await _apiService.post('/logout');
      
      print('==========================================');
      print('Logout response: ${response.statusCode}');
      print('Logout success: ${response.success}');
      print('Logout message: ${response.message}');
      print('==========================================');
      
      // Always clear local data
      await _clearAuthData();
      _apiService.clearToken();
      
      return ApiResponse(
        success: response.success,
        message: response.message,
        data: response.success,
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('Logout error: $e');
      return ApiResponse(
        success: false,
        message: 'Error during logout: $e',
        statusCode: 500,
      );
    }
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    
    if (token != null) {
      _apiService.setToken(token);
      return true;
    }
    
    return false;
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    
    if (userData != null) {
      try {
        return User.fromJson(json.decode(userData));
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    
    return null;
  }

  Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(userData));
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}