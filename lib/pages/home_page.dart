import 'package:flutter/material.dart';

import 'GetRewards_page.dart';
import '../core/session_store.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'notifications_page.dart';
import 'chatbot_page.dart';
import 'map_page.dart';
import 'settings_page.dart';
import 'coupon_page.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color tealDark = Color(0xFF2B6E7F);
  static const Color tealMid = Color(0xFF5FA9BB);
  static const Color tealLight = Color(0xFFDFF4F8);
  static const Color pageBg = Color(0xFFF6F6F6);

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
                          SessionStore.current = null;
                          //Navigator.pushAndRemoveUntil(
                          //  context,
                          //  MaterialPageRoute(
                          //    builder: (_) => const LoginPage(),
                          //  ),
                          // (route) => false,
                         // );
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
        : 'Guest User';

    final String phone = (session?.phoneNumber.trim().isNotEmpty ?? false)
        ? session!.phoneNumber
        : '—';

    final String points = (session != null)
        ? _formatPoints(session.totalPoints)
        : '0';

    return Scaffold(
      backgroundColor: pageBg,
      drawer: _HomeDrawer(
        name: name,
        onLogoutTap: () => _showLogoutDialog(context),
      ),
      bottomNavigationBar: const _HomeBottomNavBar(),
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeHeader(
                    userName: name,
                    onMenuTap: () => Scaffold.of(context).openDrawer(),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Column(
                      children: [
                        _NewLoyaltyCard(
                          name: name.toUpperCase(),
                          phone: phone,
                          points: points,
                        ),
                        const SizedBox(height: 14),
                        _SectionHeader(
                          title: 'Coupons',
                          onViewAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CouponPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        const _HorizontalCoupons(),
                        const SizedBox(height: 18),
                        _SectionHeader(
                          title: 'Offers & Announcement',
                          onViewAll: () {},
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: _AnnouncementCard(),
                        ),
                        const SizedBox(height: 18),
                        _SectionHeader(title: 'Shops', onViewAll: () {}),
                        const SizedBox(height: 10),
                        const _ShopsGrid(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.userName, required this.onMenuTap});

  final String userName;
  final VoidCallback onMenuTap;

  static const Color tealMid = Color(0xFF5FA9BB);

  @override
  Widget build(BuildContext context) {
    final firstName = userName.trim().split(' ').first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 70),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [tealMid, Color(0xFF88C7D5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'WELCOME ${firstName.toUpperCase()} !',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onMenuTap,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.menu, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewLoyaltyCard extends StatelessWidget {
  const _NewLoyaltyCard({
    required this.name,
    required this.phone,
    required this.points,
  });

  final String name;
  final String phone;
  final String points;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF15385E), Color(0xFF7BC6D3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'LOYALTY CARD',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Image.asset(
                  'assets/images/logo3.png',
                  height: 42,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/star(1).png',
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  points,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'points',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.grey.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  phone,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              'view all',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6A8D95),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalCoupons extends StatelessWidget {
  const _HorizontalCoupons();

  @override
  Widget build(BuildContext context) {
    final coupons = [
      const _CouponData(
        bgColor: Color(0xFF0FA44A),
        titleTop: 'Buy 2 get 1 free',
        brand: 'SUBWAY',
        brandColor: Color(0xFFF7D235),
      ),
      const _CouponData(
        bgColor: Color(0xFFDDBA61),
        titleTop: '30% off',
        brand: 'max',
        brandColor: Colors.white,
      ),
      const _CouponData(
        bgColor: Color(0xFF2C79C1),
        titleTop: '20% off',
        brand: 'ZARA',
        brandColor: Colors.white,
      ),
    ];

    return SizedBox(
      height: 98,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: coupons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, index) => _CouponCard(data: coupons[index]),
      ),
    );
  }
}

class _CouponData {
  final Color bgColor;
  final String titleTop;
  final String brand;
  final Color brandColor;

  const _CouponData({
    required this.bgColor,
    required this.titleTop,
    required this.brand,
    required this.brandColor,
  });
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.data});

  final _CouponData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: data.bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.titleTop,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.brand,
            style: TextStyle(
              color: data.brandColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo3.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'VAT-FREE Weekend!',
            style: TextStyle(
              color: Color(0xFF4D7E8A),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Valid across all stores.',
            style: TextStyle(
              color: Color(0xFF7FADB6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopsGrid extends StatelessWidget {
  const _ShopsGrid();

  @override
  Widget build(BuildContext context) {
    final shops = [
      'assets/images/shop1.png',
      'assets/images/shop2.png',
      'assets/images/shop3.png',
      'assets/images/shop4.png',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: shops.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (_, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF6DAAB4), width: 1.4),
            ),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                shops[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Text(
                    'Shop ${index + 1}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4D7E8A),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({required this.name, required this.onLogoutTap});

  final String name;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.zero,
          right: Radius.zero,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 10, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFE9F4F6),
                    child: Image.asset(
                      'assets/images/logo3.png',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _DrawerTile(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
            _DrawerTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
            _DrawerTile(
              icon: Icons.history,
              title: 'Transactions',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                );
              },
            ),
            const Spacer(),
            _DrawerTile(
              icon: Icons.logout,
              title: 'log out',
              onTap: () {
                Navigator.pop(context);
                onLogoutTap();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF50646B)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2F3A3E),
        ),
      ),
      onTap: onTap,
    );
  }
}

class _HomeBottomNavBar extends StatelessWidget {
  const _HomeBottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF5FA9BB),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MapPage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatBotPage()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
        }
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
          label: 'Chatbot',
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

