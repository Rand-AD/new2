import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';
import 'verify_page.dart';
import '../Services/auth_service.dart';
import '../core/session_store.dart';
import '../models/user_session.dart';
import '../core/error_popup.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Color primaryTeal = Color(0xFF1D5D6D);
  static const Color createButtonColor = Color(0xFF3C7381);

  final AuthService _auth = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _loading = false;

  InputDecoration _pillInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB8B8B8), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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

  Future<void> _doCreate() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || phone.isEmpty || pass.isEmpty || confirm.isEmpty) {
      await ErrorPopup.show(context, message: "Please fill all fields.");
      return;
    }
    if (pass != confirm) {
      await ErrorPopup.show(
        context,
        message: "Password and confirm password do not match.",
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final UserSession session = await _auth.loginOrRegister(
        phoneNumber: phone,
        password: pass,
        name: name,
      );

      SessionStore.current = session;

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VerifyPage()),
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
      await ErrorPopup.show(context, message: "Create failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    final topGap = h * 0.14;
    final fieldsTopGap = h * 0.055;
    final bottomSpace = h * 0.05;
    final gradientStart = h * 0.55;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Colors.white)),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: gradientStart,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00FFFFFF), Color(0xFF66BFD3)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  children: [
                    SizedBox(height: topGap),

                    const Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      'fill your information below or register\nwith your social account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.35,
                      ),
                    ),

                    SizedBox(height: fieldsTopGap),

                    TextField(
                      controller: _nameController,
                      decoration: _pillInput('Full name'),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _pillInput('Phone number'),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _passController,
                      obscureText: true,
                      decoration: _pillInput('Create password'),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: _pillInput('Confirm password'),
                    ),

                    const SizedBox(height: 28),

                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 44,
                        width: 130,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _doCreate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: createButtonColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
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
                                  'create',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    SizedBox(height: bottomSpace),

                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'log in',
                            style: const TextStyle(
                              color: primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.08),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
