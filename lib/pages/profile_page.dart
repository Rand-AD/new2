import 'package:flutter/material.dart';
import '../core/session_store.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'chatbot_page.dart';
import 'notifications_page.dart';

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
                  width: 140,
                  height: 140,
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
                        _infoRow('Your Points Value', '10 jds'),
                        const SizedBox(height: 10),
                        _infoRow('Your Points Balance', '$points pts'),
                        const SizedBox(height: 12),
                        const Divider(color: whiteSoft, thickness: 1),
                        const SizedBox(height: 16),
                        _infoRow('First Name', firstName),
                        const SizedBox(height: 10),
                        _infoRow('Last Name', lastName),
                        const SizedBox(height: 10),
                        _infoRow('Phone Number', phone),
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
      bottomNavigationBar: _AppBottomNav(currentIndex: 4),
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
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
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

class _AppBottomNav extends StatelessWidget {
  const _AppBottomNav({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF5FA9BB),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (index) {
        if (index == currentIndex) return;

        Widget page;
        switch (index) {
          case 0:
            page = const HomePage();
            break;
          case 1:
            page = const MapPage();
            break;
          case 2:
            page = const ChatBotPage();
            break;
          case 3:
            page = const NotificationsPage();
            break;
          default:
            page = const ProfilePage();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'ChatBot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          activeIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
