import 'package:flutter/material.dart';

import 'GetRewards_page.dart';
import 'MyRewards_page.dart';
import '../core/session_store.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color tealDark = Color(0xFF1D5D6D);
  static const Color tealMid = Color(0xFF4F8C97);
  static const Color tealLight = Color(0xFF9ED0DA);

  String _formatPoints(int points) {
    final s = points.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final reverseIndex = s.length - i;
      buf.write(s[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buf.write(',');
      }
    }
    return buf.toString();
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: tealDark, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Are you sure you want to logout?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: tealDark,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "NO",
                          style: TextStyle(
                            color: tealDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);

                          // ✅ Clear session (logout)
                          SessionStore.current = null;

                          // ✅ back to login
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tealDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          "YES",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionStore.current;

    final String name = (session?.name.trim().isNotEmpty ?? false)
        ? session!.name
        : '—';

    final String phone = (session?.phoneNumber.trim().isNotEmpty ?? false)
        ? session!.phoneNumber
        : '—';

    final String points = (session != null)
        ? _formatPoints(session.totalPoints)
        : '0';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        leading: IconButton(
          icon: Image.asset(
            'assets/images/logout.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          onPressed: () => _showLogoutDialog(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.55, 1.0],
            colors: [Colors.white, tealLight],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Image.asset(
                  'assets/images/logo_name.png',
                  height: 42,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 18),
                _LoyaltyCard(
                  logoPath: 'assets/images/logo3.png',
                  name: name,
                  phone: phone,
                  points: points,
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _RewardBox(
                      imagePath: 'assets/images/discount.png',
                      text: 'Get Rewards',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GetRewardsPage(),
                          ),
                        );
                      },
                    ),
                    _RewardBox(
                      imagePath: 'assets/images/bag.png',
                      text: 'My Rewards',
                      onTap: () {
                        final userId = SessionStore.current!.userId;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MyRewardsPage(userId: userId),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 70),
                const Text(
                  'SHOP · EARN · YALLA!',
                  style: TextStyle(
                    fontFamily: 'Judson',
                    fontSize: 20,
                    letterSpacing: 3,
                    color: tealMid,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard({
    required this.logoPath,
    required this.name,
    required this.phone,
    required this.points,
  });

  final String logoPath;
  final String name;
  final String phone;
  final String points;

  static const Color tealMid = Color(0xFF4F8C97);
  static const Color tealLight = Color(0xFF9ED0DA);

  @override
  Widget build(BuildContext context) {
    final double logoSize = (MediaQuery.of(context).size.width * 0.13).clamp(
      46.0,
      54.0,
    );

    const double pointsFont = 40;
    const double pointsWordFont = 20;
    const double starSize = 34;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [tealMid, tealLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Transform.translate(
                offset: const Offset(0, -8),
                child: const Text(
                  'LOYALTY CARD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Image.asset(
                logoPath,
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/star(1).png',
                width: starSize,
                height: starSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Text(
                points,
                style: const TextStyle(
                  fontFamily: 'Judson',
                  color: Colors.white,
                  fontSize: pointsFont,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 10),
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'points',
                  style: TextStyle(
                    fontFamily: 'Judson',
                    color: Colors.white,
                    fontSize: pointsWordFont,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white38, thickness: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Judson',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                phone,
                style: const TextStyle(
                  fontFamily: 'Judson',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardBox extends StatefulWidget {
  const _RewardBox({
    required this.imagePath,
    required this.text,
    required this.onTap,
  });

  final String imagePath;
  final String text;
  final VoidCallback onTap;

  @override
  State<_RewardBox> createState() => _RewardBoxState();
}

class _RewardBoxState extends State<_RewardBox> {
  bool _isPressed = false;

  static const Color tealLight = Color(0xFF9ED0DA);

  @override
  Widget build(BuildContext context) {
    const double w = 140;
    const double h = 140;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        width: w,
        height: h,
        padding: const EdgeInsets.all(14),
        transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: tealLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isPressed
              ? const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(widget.imagePath, height: 48, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(
              widget.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Judson',
                fontSize: 16,
                color: Color.fromARGB(255, 47, 112, 123),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
