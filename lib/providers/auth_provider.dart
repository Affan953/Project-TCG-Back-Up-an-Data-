import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcg_pokemon/config/env.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;
  String? _token;
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;

  /// Clear any previous error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Register a new user via the API
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
    final url = '${Env.baseUrl}/auth/register';
    debugPrint('[AUTH] Register URL: $url');
    debugPrint('[AUTH] Body: name=$name, email=$email');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': name,
        'email': email,
        'password_hash': password,
        'confirm_password': confirmPassword,
      }),
    );

    print(response.body);
    print(response.statusCode);

    debugPrint('[AUTH] Register status: ${response.statusCode}');
    debugPrint('[AUTH] Register body: ${response.body}');

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage =
          responseBody['message'] ?? 'Registrasi gagal. Silakan coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    } catch (e, stackTrace) {
      debugPrint('[AUTH] Register ERROR: $e');
      debugPrint('[AUTH] Stack: $stackTrace');
      _errorMessage = 'Koneksi gagal: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login user via the API and store JWT token
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
    final url = '${Env.baseUrl}/auth/login';
    debugPrint('[AUTH] Login URL: $url');
    debugPrint('[AUTH] Body: email=$email');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': email, 'password': password}),
    );

    debugPrint('[AUTH] Login status: ${response.statusCode}');
    debugPrint('[AUTH] Login body: ${response.body}');

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Extract token from response
      _token = responseBody['token'] ?? responseBody['data']?['token'];
      _userData = responseBody['user'] ?? responseBody['data']?['user'];
      _isLoggedIn = true;

      // Store token using SharedPreferences (works on all platforms including web)
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString('auth_token', _token!);
      }
      if (_userData != null) {
        await prefs.setString('user_data', jsonEncode(_userData));
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage =
          responseBody['message'] ??
          'Login gagal. Periksa email dan password Anda.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    } catch (e, stackTrace) {
      debugPrint('[AUTH] Login ERROR: $e');
      debugPrint('[AUTH] Stack: $stackTrace');
      _errorMessage = 'Koneksi gagal: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Try to restore session from stored token
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');
    final storedUserData = prefs.getString('user_data');

    if (storedToken != null) {
      _token = storedToken;
      _isLoggedIn = true;

      if (storedUserData != null) {
        _userData = jsonDecode(storedUserData);
      }

      notifyListeners();
    }
  }

  /// Logout and clear all stored data
  Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _userData = null;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');

    notifyListeners();
  }
}
