import 'package:flutter/material.dart';

import '../core/session_store.dart';
import '../widgets/code128_barcode.dart';
import 'my_coupons_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.onBack});

  final VoidCallback? onBack;

  static const Color tealDark = Color(0xFF2B6E7F);
  static const Color tealMid = Color(0xFF5FA9BB);
  static const Color tealSoft = Color(0xFFEAF5F7);
  static const Color pageBg = Color(0xFFF6F6F6);
  static const Color textMuted = Color(0xFF6F7A7D);

  @override
  Widget build(BuildContext context) {
    final session = SessionStore.current;
    final fullName = (session?.name.trim().isNotEmpty ?? false)
        ? session!.name.trim()
        : 'Guest User';
    final parts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    final firstName = parts.isNotEmpty ? parts.first : 'Guest';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '-';
    final phone = (session?.phoneNumber.trim().isNotEmpty ?? false)
        ? session!.phoneNumber.trim()
        : '0712345678';
    final points = session?.totalPoints ?? 1000000;

    return PopScope(
      canPop: onBack == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || onBack == null) {
          return;
        }

        onBack!();
      },
      child: Scaffold(
        backgroundColor: pageBg,
        body: Column(
          children: [
            _ProfileHeader(
              name: fullName,
              phone: phone,
              initials: _initials(parts),
              onBack: () => _handleBack(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                children: [
                  _PointsPanel(points: _formatPoints(points)),
                  const SizedBox(height: 14),
                  _BarcodePanel(phone: phone),
                  const SizedBox(height: 14),
                  _DetailsPanel(
                    firstName: firstName,
                    lastName: lastName,
                    phone: phone,
                  ),
                  const SizedBox(height: 16),
                  _MyCouponsButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyCouponsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }

    Navigator.maybePop(context);
  }

  static String _barcodePhone(String phone) {
    return phone.replaceAll(RegExp(r'\s+'), '').trim();
  }

  static String _formatPoints(int points) {
    final value = points.toString();
    final buffer = StringBuffer();

    for (var index = 0; index < value.length; index++) {
      final remaining = value.length - index;
      buffer.write(value[index]);

      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  static String _initials(List<String> parts) {
    if (parts.isEmpty) {
      return 'G';
    }

    final first = parts.first[0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return '$first$second'.toUpperCase();
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.phone,
    required this.initials,
    required this.onBack,
  });

  final String name;
  final String phone;
  final String initials;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 206,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ProfilePage.tealMid, ProfilePage.tealDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(42),
          bottomRight: Radius.circular(42),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
          child: Column(
            children: [
              SizedBox(
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back_ios_new),
                        color: Colors.white,
                        iconSize: 22,
                        tooltip: 'Back',
                      ),
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: ProfilePage.tealDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_android,
                              color: Colors.white,
                              size: 17,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                phone,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PointsPanel extends StatelessWidget {
  const _PointsPanel({required this.points});

  final String points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          _IconTile(
            icon: Icons.stars_rounded,
            backgroundColor: ProfilePage.tealSoft,
            iconColor: ProfilePage.tealDark,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Points Balance',
              style: TextStyle(
                color: ProfilePage.tealDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '$points pts',
                style: const TextStyle(
                  color: ProfilePage.tealDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarcodePanel extends StatelessWidget {
  const _BarcodePanel({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.view_week_rounded,
                color: ProfilePage.tealDark,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Member Barcode',
                style: TextStyle(
                  color: ProfilePage.tealDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final barcodeWidth = (constraints.maxWidth - 24)
                  .clamp(120.0, 252.0)
                  .toDouble();

              return Center(
                child: Container(
                  width: barcodeWidth + 24,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xFFE1ECEF), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Code128Barcode(
                    data: ProfilePage._barcodePhone(phone),
                    width: barcodeWidth,
                    height: 70,
                    label: 'Phone barcode for $phone',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  final String firstName;
  final String lastName;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          _ProfileRow(
            icon: Icons.person_outline,
            title: 'First Name',
            value: firstName,
          ),
          const _ThinDivider(),
          _ProfileRow(
            icon: Icons.badge_outlined,
            title: 'Last Name',
            value: lastName,
          ),
          const _ThinDivider(),
          _ProfileRow(
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            value: phone,
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _IconTile(
            icon: icon,
            backgroundColor: ProfilePage.tealSoft,
            iconColor: ProfilePage.tealDark,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: ProfilePage.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyCouponsButton extends StatelessWidget {
  const _MyCouponsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 3,
      shadowColor: const Color(0x22000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_offer, color: ProfilePage.tealDark),
              SizedBox(width: 10),
              Text(
                'My Coupons',
                style: TextStyle(
                  color: ProfilePage.tealDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFE7ECEE));
  }
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: const [
      BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 5)),
    ],
  );
}
