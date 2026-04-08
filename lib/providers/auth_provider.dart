import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tcg_pokemon/config/env.dart';

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
  required String name,
  required String email,
  required String password,
  required String confirmPassword,
}) async {
  try {
    final response = await http.post(
      Uri.parse('${Env.baseUrl}/register'), // ganti endpoint sesuai API
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );

    if (response.statusCode == 201) {
      print('Yeeee, Berhasil!');
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