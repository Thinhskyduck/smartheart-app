import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized API Service for HTTP requests with JWT token management
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  // Save token to local storage
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Load token from local storage
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Clear token (for logout)
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get authorization headers
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (includeAuth && _token != null) {
      headers['x-auth-token'] = _token!;
    }
    
    return headers;
  }

  // POST request
  Future<http.Response> post(String url, {Map<String, dynamic>? body, bool includeAuth = true}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(includeAuth: includeAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(Duration(seconds: 3)); // Fast timeout for better UX
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET request
  Future<http.Response> get(String url, {bool includeAuth = true}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(includeAuth: includeAuth),
      ).timeout(Duration(seconds: 3)); // Fast timeout for better UX
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  Future<http.Response> put(String url, {Map<String, dynamic>? body, bool includeAuth = true}) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _getHeaders(includeAuth: includeAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(Duration(seconds: 3)); // Fast timeout for better UX
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  Future<http.Response> delete(String url, {bool includeAuth = true}) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _getHeaders(includeAuth: includeAuth),
      ).timeout(Duration(seconds: 3)); // Fast timeout for better UX
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Check if response is successful
  bool isSuccess(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  // Parse JSON response
  Map<String, dynamic> parseResponse(http.Response response) {
    if (response.body.isEmpty) return {};
    return jsonDecode(response.body);
  }
}

final apiService = ApiService();
