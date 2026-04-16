import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Test API register langsung
  final response = await http.post(
    Uri.parse('https://api-tcg-backend.vercel.app/api/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': 'testuser123',
      'email': 'test@example.com',
      'password_hash': 'password123',
      'confirm_password': 'password123',
    }),
  );

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  final data = jsonDecode(response.body);
  print('Parsed Data: $data');
}