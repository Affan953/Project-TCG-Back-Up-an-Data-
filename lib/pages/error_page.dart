import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tcg_pokemon/routes/app_routes.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Page Not Found")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 80),
            SizedBox(height: 16),
            Text(
              "404 - Halaman tidak ditemukan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.pushNamed(AppRoutes.loginPath);
              },
              child: Text("Kembali ke Login"),
            ),
          ],
        ),
      ),
    );
  }
}
