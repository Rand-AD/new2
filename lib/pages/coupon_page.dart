import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/session_store.dart';
import '../widgets/rewards_header.dart';
import 'history_page.dart';
import 'my_coupons_page.dart';

class CouponPage extends StatefulWidget {
  const CouponPage({super.key});

  @override
  State<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  final String baseUrl =
      "https://yallarewards-hfhxdxerb8caa8g9.switzerlandnorth-01.azurewebsites.net";

  List coupons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCoupons();
  }

  Future<void> redeemCoupon(String couponId, int index) async {
    try {
      final sessionId = SessionStore.current?.sessionId;

      final response = await http.post(
        Uri.parse("$baseUrl/api/Coupons/redeem"),
        headers: {
          "Content-Type": "application/json",
          "X-Session-Id": sessionId ?? "",
        },
        body: jsonEncode({"couponId": couponId}),
      );

      debugPrint("REDEEM STATUS = ${response.statusCode}");
      debugPrint("REDEEM BODY = ${response.body}");

      if (response.statusCode == 200) {
        final cost = coupons[index]['costPoint'] ?? 0;
        final old = SessionStore.current;

        if (old != null) {
          SessionStore.current = old.copyWith(
            totalPoints: (old.totalPoints - cost).toInt(),
          );
        }

        await getCoupons();

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Coupon redeemed successfully")),
        );
      } else {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      debugPrint("REDEEM ERROR = $e");
    }
  }

  Future<void> getCoupons() async {
    try {
      final sessionId = SessionStore.current?.sessionId;

      final response = await http.get(
        Uri.parse("$baseUrl/api/Coupons?isActive=true"),
        headers: {
          "Content-Type": "application/json",
          "X-Session-Id": sessionId ?? "",
        },
      );

      debugPrint("COUPONS STATUS = ${response.statusCode}");
      debugPrint("COUPONS BODY = ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (!mounted) {
          return;
        }

        setState(() {
          coupons = data is List ? data : [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("COUPONS ERROR = $e");
      setState(() => isLoading = false);
    }
  }

  void _openTab(int index) {
    if (index == 0) {
      return;
    }

    final Widget page = index == 1
        ? const MyCouponsPage()
        : const HistoryPage();

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          const RewardsHeader(),
          _CouponTabs(onTap: _openTab),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : coupons.isEmpty
                ? const Center(child: Text("No coupons available"))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    itemCount: coupons.length,
                    itemBuilder: (context, index) {
                      final item = coupons[index];

                      return _CouponCard(
                        coupon: item,
                        onRedeem: () =>
                            redeemCoupon(item['id'].toString(), index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CouponTabs extends StatelessWidget {
  const _CouponTabs({required this.onTap});

  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const tabs = ['All rewards', 'My rewards', 'History'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(tabs.length, (index) {
          final selected = index == 0;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE2E2E2) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tabs[index],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon, required this.onRedeem});

  final dynamic coupon;
  final VoidCallback onRedeem;

  static const Color teal = Color(0xFF2B6E7F);

  String get title => _stringValue(['title', 'type', 'couponType'], 'Coupon');

  String get description =>
      _stringValue(['description', 'discription', 'couponDescription'], '');

  String get storeName {
    final explicit = _stringValue(['storeName', 'name', 'brand'], '');
    if (explicit.trim().isNotEmpty) {
      return explicit;
    }

    final searchable = '$title $description'.toLowerCase();
    if (searchable.contains('subway')) {
      return 'Subway';
    }
    if (searchable.contains('max')) {
      return 'Max';
    }

    return '';
  }

  String get points => '${coupon['costPoint'] ?? coupon['points'] ?? 0} pts';

  Color get brandColor {
    final text = '$storeName $title $description'.toLowerCase();
    if (text.contains('subway')) {
      return const Color(0xFF08D060);
    }
    if (text.contains('max')) {
      return const Color(0xFFE8C468);
    }

    return teal;
  }

  String get logoAsset {
    final text = '$storeName $title $description'.toLowerCase();
    if (text.contains('subway')) {
      return 'assets/images/subway_logo.png';
    }
    if (text.contains('max')) {
      return 'assets/images/max_logo.jpeg';
    }

    return 'assets/images/logo3.png';
  }

  String _stringValue(List<String> keys, String fallback) {
    for (final key in keys) {
      final value = coupon[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  String _dateValue(List<String> keys) {
    final raw = _stringValue(keys, '');
    if (raw.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw.split('T').first;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  void _showDescription(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(
              description.trim().isEmpty
                  ? 'No description available'
                  : description,
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

  Future<void> _confirmRedeem(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const _RedeemConfirmDialog(),
    );

    if (confirm == true) {
      onRedeem();
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDate = _dateValue([
      'startDate',
      'startsAt',
      'validFrom',
      'createdAt',
    ]);
    final endDate = _dateValue([
      'endDate',
      'endsAt',
      'validTo',
      'expirationDate',
      'expiredAt',
    ]);
    final displayStartDate = startDate.isEmpty ? '1 Mar 2026' : startDate;
    final displayEndDate = endDate.isEmpty ? '20 Mar 2026' : endDate;

    return GestureDetector(
      onTap: () => _showDescription(context),
      child: Container(
        height: 186,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: 6,
              top: 6,
              right: 6,
              height: 112,
              child: Container(
                decoration: BoxDecoration(
                  color: brandColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 24,
                      right: 104,
                      top: 18,
                      bottom: 24,
                      child: Center(
                        child: Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -10,
                      bottom: -8,
                      child: Image.asset(
                        'assets/images/gift1.png',
                        width: 92,
                        height: 92,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 46,
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    logoAsset,
                    width: 46,
                    height: 46,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.store, color: teal),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 28,
              right: 112,
              bottom: 31,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              right: 13,
              bottom: 39,
              child: Text(
                points,
                style: const TextStyle(
                  color: teal,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 10,
              child: SizedBox(
                height: 24,
                child: ElevatedButton(
                  onPressed: () => _confirmRedeem(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Redeem',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 28,
              right: 112,
              bottom: 9,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      'Starts: $displayStartDate',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Text(
                      'Ends: $displayEndDate',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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
  }
}

class _RedeemConfirmDialog extends StatelessWidget {
  const _RedeemConfirmDialog();

  static const Color teal = Color(0xFF2B6E7F);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 318,
        height: 202,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: teal, width: 4),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 2,
              right: 2,
              child: IconButton(
                onPressed: () => Navigator.pop(context, false),
                icon: Icon(Icons.close, color: Colors.grey.shade700, size: 28),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 42, 24, 22),
              child: Column(
                children: [
                  const Text(
                    'Redeem this reward?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: teal,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This coupon will be added to My rewards.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: teal,
                            side: const BorderSide(color: teal, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: teal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Redeem',
                            style: TextStyle(fontWeight: FontWeight.w800),
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
      ),
    );
  }
}
