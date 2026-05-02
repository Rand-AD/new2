import 'package:flutter/material.dart';
import '../core/session_store.dart';
import 'my_coupons_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color topColor = Color(0xFF49AABD);
  static const Color bottomColor = Color(0xFFCBE7BE);
  static const Color whiteSoft = Color(0xFFF7F7F7);

  @override
  Widget build(BuildContext context) {
    final session = SessionStore.current;

    final String fullName = (session?.name.trim().isNotEmpty ?? false)
        ? session!.name
        : 'Rand Abu Dalo';

    final parts = fullName.split(' ');
    final firstName = parts.isNotEmpty ? parts.first : 'Rand';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : 'Abu Dalo';
    final phone = (session?.phoneNumber.trim().isNotEmpty ?? false)
        ? session!.phoneNumber
        : '0712345678';
    final int points = session?.totalPoints ?? 1000;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [topColor, bottomColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 14, top: 8),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  firstName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 220,
                  height: 220,
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/qr.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.qr_code_2,
                      size: 95,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Divider(color: whiteSoft, thickness: 1),
                        const SizedBox(height: 12),

                        const SizedBox(height: 10),
                        _infoRow('Points Balance', '$points pts'),
                        const SizedBox(height: 12),
                        const Divider(color: whiteSoft, thickness: 1),
                        const SizedBox(height: 16),
                        _infoRow('First Name', firstName),
                        const SizedBox(height: 10),
                        _infoRow('Last Name', lastName),
                        const SizedBox(height: 10),
                        _infoRow('Phone Number', phone),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyCouponsPage(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_offer,
                                  color: Color(0xFF2B6E7F),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "My Coupons",
                                  style: TextStyle(
                                    color: Color(0xFF2B6E7F),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoRow(String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16, // 🔥 bigger
              fontWeight: FontWeight.bold, // 🔥 bold
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
