import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'register_page.dart';
import '../Services/auth_service.dart';
import '../core/session_store.dart';
import '../models/user_session.dart';
import '../core/error_popup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color primaryTeal = Color(0xFF1D5D6D);

  final AuthService _auth = AuthService();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  InputDecoration _pillInput({
    required String hint,
    Widget? prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB8B8B8), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffix,
      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFFECECEC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primaryTeal, width: 1.2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  ({String message, bool isApiError}) _extractApiMessage(dynamic data) {
    if (data == null) return (message: "", isApiError: false);

    if (data is String) {
      final s = data.trim();
      if (s.startsWith("{") && s.endsWith("}")) {
        try {
          final decoded = jsonDecode(s);
          return _extractApiMessage(decoded);
        } catch (_) {
          return (message: s, isApiError: false);
        }
      }
      return (message: s, isApiError: false);
    }

    if (data is Map) {
      if (data["error"] is Map) {
        final err = data["error"] as Map;
        final msg = (err["message"] ?? "").toString().trim();
        if (msg.isNotEmpty) return (message: msg, isApiError: true);
      }

      if (data["message"] != null) {
        final msg = data["message"].toString().trim();
        if (msg.isNotEmpty) return (message: msg, isApiError: true);
      }

      return (message: data.toString(), isApiError: false);
    }

    return (message: data.toString(), isApiError: false);
  }

  Future<void> _doLogin() async {
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text;

    if (phone.isEmpty || pass.isEmpty) {
      await ErrorPopup.show(
        context,
        message: "Please enter phone number and password.",
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final UserSession session = await _auth.loginOrRegister(
        phoneNumber: phone,
        password: pass,
        name: "",
      );

      SessionStore.current = session;

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on DioException catch (e) {
      final extracted = _extractApiMessage(e.response?.data);

      if (extracted.isApiError && extracted.message.isNotEmpty) {
        await ErrorPopup.show(context, message: extracted.message);
      } else {
        final fallback = extracted.message.isNotEmpty
            ? extracted.message
            : (e.message?.trim().isNotEmpty ?? false)
            ? e.message!.trim()
            : "Something went wrong. Please try again.";
        await ErrorPopup.show(context, message: fallback);
      }
    } catch (e) {
      await ErrorPopup.show(context, message: "Login failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    final topGap = h * 0.30;
    final fieldsGap = h * 0.05;
    final afterFieldsGap = h * 0.04;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.08, 0.34, 0.73, 1.0],
            colors: [
              Color(0xFF9CCAD5),
              Color(0xFFF8F8F8),
              Color(0xFFF8F8F8),
              Color(0xFF9CCAD5),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: topGap),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                    children: [
                      const TextSpan(text: "Don’t have an account? "),
                      TextSpan(
                        text: "register",
                        style: const TextStyle(
                          color: primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: fieldsGap),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _pillInput(hint: 'Phone number'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _pillInput(
                    hint: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFFB8B8B8),
                      size: 20,
                    ),
                    suffix: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        foregroundColor: primaryTeal,
                      ),
                      child: const Text(
                        'FORGOT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: afterFieldsGap),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 44,
                    width: 120,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _doLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
