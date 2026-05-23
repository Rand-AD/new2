import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:g_project/Services/api_service.dart';
import 'package:g_project/Services/offers_service.dart';
import 'package:g_project/pages/login_page.dart';

import '../core/session_store.dart';
import 'profile_page.dart';
import 'notifications_page.dart';
import 'chatbot_page.dart';
import 'map_page.dart';
import 'settings_page.dart';
import 'coupon_page.dart';
import 'offers_page.dart';
import 'shop_details_page.dart';
import 'shops_page.dart';
import 'transactions_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;
  static const Color tealDark = Color(0xFF2B6E7F);
  static const Color pageBg = Color(0xFFF6F6F6);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

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
            title: 'Offers',
            onViewAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OffersPage()),
              );
            },
          ),

          const SizedBox(height: 10),
          const _OffersList(),

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
    final pageNavigator = Navigator.of(context);

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
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
                        onPressed: () => Navigator.pop(dialogContext),
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
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await SessionStore.clear();

                          if (!mounted) return;

                          pageNavigator.pushAndRemoveUntil(
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
                                top: 19,
                                child: SizedBox(
                                  width: 170,
                                  height: 22,
                                  child: Text(
                                    'LOYALTY CARD',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Judson',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 50,
                                top: 28,
                                right: 18,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/coin.png',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.contain,
                                    ),
                                    Flexible(
                                      child: Transform.translate(
                                        offset: const Offset(-16, 0),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            points,
                                            maxLines: 1,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'K2D',
                                              fontSize: 46,
                                              fontWeight: FontWeight.w800,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(-14, 0),
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 4),
                                        child: Text(
                                          'points',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'K2D',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            height: 1,
                                          ),
                                        ),
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
                        top: 106,
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Transform.translate(
                              offset: const Offset(0, -2),
                              child: Image.asset(
                                'assets/images/logo3.png',
                                width: 55,
                                height: 55,
                                fit: BoxFit.contain,
                              ),
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

class _OfferCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;

  const _OfferCard({
    required this.title,
    required this.content,
    this.date = '',
  });

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.08),
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 266,
              constraints: const BoxConstraints(minHeight: 173),
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFF1D5D6D), width: 2.4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          content.trim().isEmpty
                              ? 'No details available'
                              : content,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.16,
                          ),
                        ),
                        if (date.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            date,
                            style: const TextStyle(
                              color: Color(0xFF2B6E7F),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    right: -8,
                    top: -10,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      iconSize: 22,
                      color: Color(0xFF777777),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: 'Close',
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
              top: 56,
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
            if (date.isNotEmpty)
              Positioned(
                right: 12,
                bottom: 9,
                child: Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6A8D95),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OfferItem {
  const _OfferItem({
    required this.title,
    required this.content,
    required this.date,
  });

  factory _OfferItem.fromOffer(Map<dynamic, dynamic> json) {
    return _OfferItem(
      title: _stringValue(json, ['title', 'name'], 'Offer'),
      content: _stringValue(json, [
        'description',
        'content',
        'message',
        'body',
      ], 'No details available'),
      date: _dateValue(json, ['startAt', 'start_at', 'madeAt', 'made_at']),
    );
  }

  final String title;
  final String content;
  final String date;

  static String _stringValue(
    Map<dynamic, dynamic> json,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  static String _dateValue(Map<dynamic, dynamic> json, List<String> keys) {
    final raw = _stringValue(json, keys, '');
    if (raw.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return '${parsed.year}/${parsed.month}/${parsed.day}';
    }

    if (raw.length >= 10) {
      return raw.substring(0, 10).replaceAll('-', '/');
    }

    return raw;
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
      final sortedStores = List<dynamic>.from(
        data.where((store) => _hasStoreImage(store) && !_isE2eStore(store)),
      );
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

  bool _isE2eStore(dynamic store) {
    final name = (store['name'] ?? '').toString().trim().toLowerCase();
    return name == 'e2e';
  }

  bool _hasStoreImage(dynamic store) {
    return store['storeImageUrl'] != null &&
        store['storeImageUrl'].toString().isNotEmpty;
  }

  bool _isAlameedStore(dynamic store) {
    final name = (store['name'] ?? '').toString().toLowerCase();
    final image = (store['storeImageUrl'] ?? '').toString().toLowerCase();
    final searchable = '$name $image';

    return searchable.contains('alameed') ||
        searchable.contains('ameed') ||
        searchable.contains('\u0627\u0644\u0639\u0645\u064a\u062f');
  }

  void _openStoreDetails(dynamic store) {
    if (store is! Map) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ShopDetailsPage(store: Map<String, dynamic>.from(store)),
      ),
    );
  }

  String _displayStoreName(dynamic value) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty) {
      return 'Shop';
    }

    return text
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) {
            return word;
          }

          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }

  String _floorLabel(dynamic store) {
    final value =
        store['floorNumber'] ??
        store['floor_number'] ??
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
      const floors = [
        'Ground Floor',
        'First Floor',
        'Second Floor',
        'Third Floor',
      ];
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final store = stores[index];
            final imageUrl = (store['storeImageUrl'] ?? '').toString();

            return InkWell(
              borderRadius: BorderRadius.circular(7),
              onTap: () => _openStoreDetails(store),
              child: Container(
                width: 168,
                height: 172,
                margin: const EdgeInsets.only(right: 10, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0xFF6DAAB4),
                    width: 1.8,
                  ),
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
                        height: 82,
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.store, size: 74),
                              )
                            : const Icon(Icons.store, size: 74),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 38,
                      child: Text(
                        _displayStoreName(store['name']),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF4D7E8A),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 21,
                      child: Text(
                        _floorLabel(store),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF67B4C3),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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
                MaterialPageRoute(builder: (_) => const TransactionsPage()),
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

class _OffersList extends StatefulWidget {
  const _OffersList();

  @override
  State<_OffersList> createState() => _OffersListState();
}

class _OffersListState extends State<_OffersList> {
  List<_OfferItem> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    try {
      final sessionId = SessionStore.current?.sessionId ?? '';
      final offersData = await OffersService.getOffers(sessionId);
      final offers = offersData.whereType<Map>().map(
        (item) => _OfferItem.fromOffer(item),
      ).toList();

      setState(() {
        items = offers;
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

    if (items.isEmpty) {
      return const SizedBox(
        height: 98,
        child: Center(child: Text("No offers available")),
      );
    }

    return SizedBox(
      height: 146,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return _OfferCard(
            title: item.title,
            content: item.content,
            date: item.date,
          );
        },
      ),
    );
  }
}

class _HorizontalCouponsState extends State<_HorizontalCoupons> {
  List<dynamic> coupons = [];
  bool isLoading = true;

  String _stringValue(dynamic coupon, List<String> keys, String fallback) {
    if (coupon is! Map) {
      return fallback;
    }

    for (final key in keys) {
      final value = coupon[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  String _couponTitle(dynamic coupon) {
    return _stringValue(coupon, ['title', 'type', 'couponType'], 'Coupon');
  }

  String _couponDescription(dynamic coupon) {
    return _stringValue(coupon, [
      'description',
      'discription',
      'couponDescription',
    ], 'No description available');
  }

  String _couponPoints(dynamic coupon) {
    if (coupon is! Map) {
      return '0 pts';
    }

    return '${_formatCouponNumber(coupon['costPoint'] ?? coupon['points'] ?? 0)} pts';
  }

  String _formatCouponNumber(dynamic value) {
    final raw = value?.toString().trim() ?? '0';
    final number = int.tryParse(raw) ?? 0;
    final text = number.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final remaining = text.length - i;
      buffer.write(text[i]);

      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  void _showCouponDetails(BuildContext context, dynamic coupon) {
    final title = _couponTitle(coupon);
    final description = _couponDescription(coupon);
    final points = _couponPoints(coupon);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.08),
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 266,
              constraints: const BoxConstraints(minHeight: 173),
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFF1D5D6D), width: 2.4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.16,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          points,
                          style: const TextStyle(
                            color: Color(0xFF2B6E7F),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -8,
                    top: -10,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      iconSize: 22,
                      color: Color(0xFF777777),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: 'Close',
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

  @override
  void initState() {
    super.initState();
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    try {
      final couponsData = await ApiService.getCoupons();

      setState(() {
        coupons = couponsData;
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
            SizedBox(
              width: 219,
              child: Card(margin: EdgeInsets.only(bottom: 8)),
            ),
            SizedBox(width: 12),
            SizedBox(
              width: 219,
              child: Card(margin: EdgeInsets.only(bottom: 8)),
            ),
            SizedBox(width: 12),
            SizedBox(
              width: 219,
              child: Card(margin: EdgeInsets.only(bottom: 8)),
            ),
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
          final title = _couponTitle(item);
          final points = _couponPoints(item);

          return GestureDetector(
            onTap: () => _showCouponDetails(context, item),
            child: Container(
              width: 219,
              margin: const EdgeInsets.only(right: 12, bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1D5D6D),
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
                    left: 8,
                    bottom: 7,
                    child: Image.asset(
                      'assets/images/gift-voucher.png',
                      width: 46,
                      height: 46,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              height: 1.08,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            points,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFF5C95D),
                              fontWeight: FontWeight.w800,
                              fontSize: 21,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
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
