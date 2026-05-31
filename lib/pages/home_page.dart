import 'package:flutter/material.dart';
import 'package:g_project/Services/api_service.dart';
import 'package:g_project/Services/offers_service.dart';
import 'package:g_project/pages/login_page.dart';
import '../core/session_store.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'notifications_page.dart';
import 'chatbot_page.dart';
import 'map_page.dart';
import 'settings_page.dart';
import 'coupon_page.dart';
import 'offers_page.dart';
import 'announcements_page.dart';
import 'shops_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required int initialIndex});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const Color tealDark = Color(0xFF2B6E7F);
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

  Widget _buildHomeContent() {
    final session = SessionStore.current;

    final String name = (session?.name.trim().isNotEmpty ?? false)
        ? session!.name
        : 'Guest User';

    final String phone = (session?.phoneNumber.trim().isNotEmpty ?? false)
        ? session!.phoneNumber
        : '—';

    final String points = (session != null)
        ? _formatPoints(session.totalPoints)
        : '1,000,000';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) {
                return _TopHomeSection(
                  userName: name,
                  name: name,
                  phone: phone,
                  points: points,
                  onMenuTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            _SectionHeader(
              title: 'Coupons',
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CouponPage()),
                );
              },
            ),

            const SizedBox(height: 10),
            const _HorizontalCoupons(),

            const SizedBox(height: 20),

            _SectionHeader(
              title: 'Offers',
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OffersPage()),
                );
              },
            ),

            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _OffersList(),
            ),

            const SizedBox(height: 20),

            _SectionHeader(
              title: 'Announcements',
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnnouncementsPage()),
                );
              },
            ),

            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _AnnouncementsList(),
            ),

            const SizedBox(height: 20),

            _SectionHeader(
              title: 'Shops',
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShopsPage()),
                );
              },
            ),

            const SizedBox(height: 10),
            const _ShopsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _getPage() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const MapPage();
      case 2:
        return const ChatBotPage();
      case 3:
        return const NotificationsPage();
      case 4:
        return const ProfilePage();
      default:
        return _buildHomeContent();
    }
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
        : 'Guest User';

    return Scaffold(
      backgroundColor: pageBg,
      drawer: _HomeDrawer(
        name: name,
        onLogoutTap: () => _showLogoutDialog(context),
      ),
      bottomNavigationBar: _HomeBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: _getPage(),
    );
  }
}

class _TopHomeSection extends StatelessWidget {
  const _TopHomeSection({
    required this.userName,
    required this.name,
    required this.phone,
    required this.points,
    required this.onMenuTap,
  });

  final String userName;
  final String name;
  final String phone;
  final String points;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final firstName = userName.trim().split(' ').first;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double scale = constraints.maxWidth / 393.0;

        return SizedBox(
          width: double.infinity,
          height: 265 * scale,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 393,
              height: 265,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Blue background 393 x 226
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 393,
                      height: 226,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF51A2B4), Color(0xFF51A2B4)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(60),
                          bottomRight: Radius.circular(60),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 27,
                    top: 30,
                    width: 183,
                    height: 29,
                    child: Text(
                      'WELCOME $firstName !',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Gabarito',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),

                  Positioned(
                    right: 27,
                    top: 28,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: onMenuTap,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.menu, color: Colors.white, size: 24),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 19,
                    top: 62,
                    child: SizedBox(
                      width: 355,
                      height: 196,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // White card x=-1 y=7 size 355x189
                          Positioned(
                            left: -1,
                            top: 7,
                            child: Container(
                              width: 355,
                              height: 189,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                            left: 5,
                            top: 12,
                            child: Container(
                              width: 342,
                              height: 148,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1A365D),
                                    Color(0xFF3C7381),
                                  ],
                                  stops: [0.15, 1.0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            right: 18,
                            top: 28,
                            child: Opacity(
                              opacity: 0.12,
                              child: Image.asset(
                                'assets/images/coin.png',
                                width: 72,
                                height: 72,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          const Positioned(
                            left: 22,
                            top: 21,
                            width: 127,
                            height: 16,
                            child: Text(
                              'LOYALTY CARD',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Judson',
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                              ),
                            ),
                          ),

                          Positioned(
                            left: 76,
                            top: 64,
                            child: Image.asset(
                              'assets/images/coin.png',
                              width: 45,
                              height: 45,
                              fit: BoxFit.contain,
                            ),
                          ),

                          Positioned(
                            left: 126,
                            top: 58,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  points,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'K2D',
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    'points',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'K2D',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Positioned(
                            left: 5,
                            top: 115,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/logo3.png',
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 46,
                            top: 167,
                            width: 150,
                            height: 18,
                            child: Text(
                              name.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Judson',
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                              ),
                            ),
                          ),

                          Positioned(
                            right: 17,
                            top: 167,
                            height: 18,
                            child: Text(
                              phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Judson',
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

class _HorizontalCoupons extends StatefulWidget {
  const _HorizontalCoupons();

  @override
  State<_HorizontalCoupons> createState() => _HorizontalCouponsState();
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
  final String title;
  final String content;

  const _AnnouncementCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      height: 110,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/images/logo3.png', width: 28),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Color(0xFF4D7E8A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF7FADB6)),
          ),
        ],
      ),
    );
  }
}

class _ShopsGrid extends StatefulWidget {
  const _ShopsGrid();

  @override
  State<_ShopsGrid> createState() => _ShopsGridState();
}

class _ShopsGridState extends State<_ShopsGrid> {
  List<dynamic> stores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  Future<void> fetchStores() async {
    try {
      final data = await ApiService.getStores();

      setState(() {
        stores = data;
        isLoading = false;
      });
    } catch (e) {
      print("STORES ERROR = $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (stores.isEmpty) {
      return const Center(child: Text("No stores found"));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: stores.length > 4 ? 4 : stores.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (_, index) {
          final store = stores[index];

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF6DAAB4), width: 1.4),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (store['storeImageUrl'] != null &&
                    store['storeImageUrl'].toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      store['storeImageUrl'],
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.store, size: 40),
                    ),
                  )
                else
                  const Icon(Icons.store, size: 40),
                const SizedBox(height: 6),
                Text(
                  store['name'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
  final int currentIndex;
  final Function(int) onTap;

  const _HomeBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF5FA9BB),
      unselectedItemColor: Colors.grey,
      onTap: onTap,
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

class _OffersList extends StatefulWidget {
  const _OffersList();

  @override
  State<_OffersList> createState() => _OffersListState();
}

class _OffersListState extends State<_OffersList> {
  List offers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    try {
      final sessionId = SessionStore.current?.sessionId ?? "";
      final data = await OffersService.getOffers(sessionId);

      setState(() {
        offers = data;
        isLoading = false;
      });
    } catch (e) {
      print("OFFERS ERROR = $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (offers.isEmpty) {
      return const Text("No offers available");
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];

          return Container(
            width: 250,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF6DAAB4)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(offer['title'] ?? '', textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(
                  offer['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnnouncementsList extends StatefulWidget {
  const _AnnouncementsList();

  @override
  State<_AnnouncementsList> createState() => _AnnouncementsListState();
}

class _AnnouncementsListState extends State<_AnnouncementsList> {
  List<dynamic> announcements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      final data = await ApiService.getAnnouncements();
      setState(() {
        announcements = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (announcements.isEmpty) {
      return const Text("No announcements");
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final item = announcements[index];

          return _AnnouncementCard(
            title: item['title'] ?? '',
            content: item['content'] ?? '',
          );
        },
      ),
    );
  }
}

class _HorizontalCouponsState extends State<_HorizontalCoupons> {
  List<dynamic> coupons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    try {
      final results = await Future.wait([
        ApiService.getCoupons(),
        ApiService.getUserCoupons(),
      ]);

      final couponsData = results[0];
      final userCoupons = results[1];

      final redeemedIds = userCoupons.map((e) => e['couponId']).toSet();

      final filtered = couponsData
          .where((c) => !redeemedIds.contains(c['id']))
          .toList();

      setState(() {
        coupons = filtered;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR COUPONS = $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: const [
            SizedBox(width: 160, child: Card()),
            SizedBox(width: 12),
            SizedBox(width: 160, child: Card()),
            SizedBox(width: 12),
            SizedBox(width: 160, child: Card()),
          ],
        ),
      );
    }

    if (coupons.isEmpty) {
      return const SizedBox(
        height: 98,
        child: Center(child: Text("No coupons available")),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          final item = coupons[index];

          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4D7E8A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['type'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    item['discription'] ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${item['costPoint'] ?? 0} pts",
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
