import 'package:flutter/material.dart';
import 'login_page.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.59, 0.88],
            colors: [
              Color(0xFFFFFFFF), // #FFFFFF
              Color(0xFF5CA8B9), // #5CA8B9
            ],
          ),
        ),
        child: Stack(
          children: [
            // اللوجو بالنص
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 251,
                height: 228,
                errorBuilder: (context, error, stack) {
                  return const Icon(Icons.image, size: 80);
                },
              ),
            ),

            // زر Login or Register
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SizedBox(
                    width: 320,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4E4E4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Text(
                        'Login or Register',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
