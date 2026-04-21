import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final rand = Random().nextInt(100000);
    final user = 'testuser$rand';
    final pass = 'password123';
    
    // Register
    print('Registering $user...');
    final regRes = await http.post(
      Uri.parse('https://api-tcg-backend.vercel.app/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': user,
        'email': '$user@test.com',
        'password_hash': pass,
        'confirm_password': pass,
      }),
    );
    print('Reg Status: ${regRes.statusCode}');
    print('Reg Body: ${regRes.body}');
    
    // Login
    print('Logging in $user...');
    final loginRes = await http.post(
      Uri.parse('https://api-tcg-backend.vercel.app/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': user, 'password': pass}),
    );
    print('Login Status: ${loginRes.statusCode}');
    print('Login Body: ${loginRes.body}');
  } catch (e) {
    print('Error: $e');
  }
}
