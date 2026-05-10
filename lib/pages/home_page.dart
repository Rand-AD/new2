import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:g_project/Services/api_service.dart';
import 'package:g_project/pages/login_page.dart';

import '../core/session_store.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'notifications_page.dart';
import 'chatbot_page.dart';
import 'map_page.dart';
import 'settings_page.dart';
import 'coupon_page.dart';
import 'announcements_page.dart';
import 'shops_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
        : '-';

    final String points = (session != null)
        ? _formatPoints(session.totalPoints)
        : '0';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 14),
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

          const SizedBox(height: 6),

          _SectionHeader(
            title: 'Coupons',
            onViewAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CouponPage()),
              );
            },
          ),

          const SizedBox(height: 8),
          const _HorizontalCoupons(),

          const SizedBox(height: 16),

          _SectionHeader(
            title: 'Offers & Announcement',
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

          const SizedBox(height: 16),

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
        return ProfilePage(
          onBack: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
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
      ),
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
    final welcomeName = userName.trim().isNotEmpty
        ? userName.trim()
        : 'Guest User';

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 371
            ? 355.0
            : constraints.maxWidth - 32;
        final cardLeft = (constraints.maxWidth - cardWidth) / 2;
        final innerWidth = cardWidth - 13;

        return SizedBox(
          height: 286,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 226,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF51A2B4),
                      Color(0xFF69BACA),
                      Color(0xFFF6F6F6),
                    ],
                    stops: [0.0, 0.76, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                ),
              ),

              Positioned(
                left: 27,
                top: 45,
                child: SizedBox(
                  width: constraints.maxWidth - 96,
                  height: 29,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'WELCOME $welcomeName !',
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Gabarito',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 27,
                top: 45,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: onMenuTap,
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(Icons.menu, color: Colors.white, size: 29),
                  ),
                ),
              ),

              Positioned(
                left: cardLeft,
                top: 88,
                child: Container(
                  width: cardWidth,
                  height: 189,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 5,
                        top: 12,
                        child: Container(
                          width: innerWidth,
                          height: 148,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A365D), Color(0xFF3C7381)],
                              stops: [0.15, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              const Positioned(
                                left: 22,
                                top: 21,
                                child: SizedBox(
                                  width: 127,
                                  height: 18,
                                  child: Text(
                                    'LOYALTY CARD',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Judson',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 62,
                                top: 34,
                                right: 18,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/coin.png',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          points,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'K2D',
                                            fontSize: 40,
                                            fontWeight: FontWeight.w700,
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    const Text(
                                      'points',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'K2D',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 104,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/logo3.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 74,
                        right: 16,
                        bottom: 5,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                name.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF111111),
                                  fontFamily: 'Judson',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(0xFF111111),
                                fontFamily: 'Judson',
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              'view all',
              style: TextStyle(
                fontSize: 18,
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

class _AnnouncementCard extends StatelessWidget {
  final String title;
  final String content;

  const _AnnouncementCard({required this.title, required this.content});

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(
              content.trim().isEmpty ? 'No details available' : content,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        width: 219,
        height: 136,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 12,
              top: 10,
              child: Image.asset(
                'assets/images/logo.png',
                width: 62,
                height: 46,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              top: 58,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Color(0xFF4D7E8A),
                ),
              ),
            ),
          ],
        ),
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
      final sortedStores = List<dynamic>.from(data);
      sortedStores.sort((a, b) {
        final aPriority = _isAlameedStore(a) ? 0 : 1;
        final bPriority = _isAlameedStore(b) ? 0 : 1;
        return aPriority.compareTo(bPriority);
      });

      setState(() {
        stores = sortedStores;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("STORES ERROR = $e");
      setState(() => isLoading = false);
    }
  }

  bool _isAlameedStore(dynamic store) {
    final name = (store['name'] ?? '').toString().toLowerCase();
    final image = (store['storeImageUrl'] ?? '').toString().toLowerCase();
    final searchable = '$name $image';

    return searchable.contains('alameed') ||
        searchable.contains('ameed') ||
        searchable.contains('\u0627\u0644\u0639\u0645\u064a\u062f');
  }

  String _floorLabel(dynamic store) {
    final value =
        store['floorName'] ??
        store['floor'] ??
        store['storeFloor'] ??
        store['level'];

    if (value == null || value.toString().trim().isEmpty) {
      return 'Ground Floor';
    }

    final text = value.toString().trim();
    final floorNumber = int.tryParse(text);

    if (floorNumber != null) {
      const floors = ['Ground Floor', 'First Floor', 'Second Floor', 'Third Floor'];
      if (floorNumber >= 0 && floorNumber < floors.length) {
        return floors[floorNumber];
      }
    }

    if (text.toLowerCase().contains('ground')) {
      return 'Ground Floor';
    }

    return text;
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

    return Transform.translate(
      offset: Offset.zero,
      child: SizedBox(
        height: 184,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final store = stores[index];
            final imageUrl = (store['storeImageUrl'] ?? '').toString();

            return Container(
              width: 168,
              height: 172,
              margin: const EdgeInsets.only(right: 10, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: const Color(0xFF6DAAB4), width: 1.4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30000000),
                    blurRadius: 8,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 12,
                    right: 12,
                    top: 12,
                    child: SizedBox(
                      height: 86,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.store, size: 78),
                            )
                          : const Icon(Icons.store, size: 78),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 31,
                    child: Text(
                      _floorLabel(store),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF67B4C3),
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 8,
                    bottom: 7,
                    child: Text(
                      'more details',
                      style: TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
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
      width: MediaQuery.of(context).size.width * 0.84,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.zero,
          right: Radius.zero,
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 12, 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFE9F4F6),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 28,
                        color: Color(0xFF4D4D4D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFD6D6D6)),
          const SizedBox(height: 22),
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
            icon: Icons.logout_outlined,
            title: 'log out',
            onTap: () {
              Navigator.pop(context);
              onLogoutTap();
            },
          ),
          const SizedBox(height: 24),
        ],
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 14, 18, 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0D6678), size: 30),
            const SizedBox(width: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
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
      debugPrint(e.toString());
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 146,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: announcements.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const _AnnouncementCard(
              title: 'VAT-FREE Weekend!',
              content: 'Valid across all stores.',
            );
          }

          final item = announcements[index - 1];

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
      debugPrint("ERROR COUPONS = $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 146,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: const [
            SizedBox(width: 219, child: Card(margin: EdgeInsets.only(bottom: 8))),
            SizedBox(width: 12),
            SizedBox(width: 219, child: Card(margin: EdgeInsets.only(bottom: 8))),
            SizedBox(width: 12),
            SizedBox(width: 219, child: Card(margin: EdgeInsets.only(bottom: 8))),
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
      height: 146,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          final item = coupons[index];

          return Container(
            width: 219,
            margin: const EdgeInsets.only(right: 12, bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF4D7E8A),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
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
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 8),

                Flexible(
                  child: Text(
                    item['discription'] ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 8),

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
