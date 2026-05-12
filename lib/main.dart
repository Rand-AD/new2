import 'package:flutter/material.dart';
import 'package:g_project/core/session_store.dart';
import 'package:g_project/pages/home_page.dart';
import 'package:g_project/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionStore.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SessionStore.current == null
          ? const LoginPage()
          : const HomePage(initialIndex: 0),
    );
  }
}
