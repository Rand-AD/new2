import 'package:flutter/material.dart';
import 'package:g_project/pages/login_page.dart';
import 'pages/home_page.dart'; // ✅ add this

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // ✅ start directly from HomePage
    );
  }
}
