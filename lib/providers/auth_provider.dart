import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tcg_pokemon/config/env.dart';
import 'package:tcg_pokemon/models/user.dart';

class User {
  final String fullName;
  final String email;
  final String phone;
  final String password;

  User({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });
}

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isRegistered = false;
  bool _isLoggedIn = false;
  bool _rememberMe = false;
  String? _currentUser;
  final Map<String, User> _registeredUsers = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isRegistered => _isRegistered;
  bool get isLoggedIn => _isLoggedIn;
  bool get rememberMe => _rememberMe;
  String? get currentUser => _currentUser;

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (password != confirmPassword) {
      _errorMessage = 'Password tidak sama!';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('https://api-tcg-backend.vercel.app/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password_hash': password,
          'confirm_password': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _isRegistered = true;
        _errorMessage = null;
        print('Yeeee, Berhasil!');
      } else {
        if (data['detail']?['code'] == '23505') {
          _errorMessage = 'Username sudah digunakan!';
        } else {
          _errorMessage = data['message'] ?? 'Register gagal';
        }
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan koneksi!';
      print('Error: $e');
    }

    _isLoading = false;
    notifyListeners();

    return _errorMessage == null;
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('https://api-tcg-backend.vercel.app/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        print('Yeeee, Berhasil!');
        final ResponseLogin responseData = responseLoginFromJson(response.body);
        final storage = FlutterSecureStorage();
        await storage.write(key: 'token', value: responseData.token);
        await storage.write(key: 'user', value: responseData.user.toString());
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        print('Gagal Untuk Menambahkan');
        print(response.body); // lihat error dari backend
        return false;
      }
    } catch (e) {
      print('Gagal Lagii: $e');
      return false;
    }
  }
}
