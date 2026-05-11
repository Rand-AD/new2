import 'package:flutter/material.dart';

import '../pages/home_page.dart';

class RewardsHeader extends StatelessWidget {
  const RewardsHeader({super.key});

  static const Color teal = Color(0xFF51A2B4);

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 0)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: teal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(56),
          bottomRight: Radius.circular(56),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              left: 18,
              top: 16,
              child: IconButton(
                onPressed: () => _goHome(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const Positioned.fill(
              child: Center(
                child: Text(
                  'Coupons',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
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
