import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/session_store.dart';
import 'coupon_page.dart';
import 'history_page.dart';

class MyCouponsPage extends StatefulWidget {
  const MyCouponsPage({super.key});

  @override
  State<MyCouponsPage> createState() => _MyCouponsPageState();
}

class _MyCouponsPageState extends State<MyCouponsPage> {
  final String baseUrl =
      "https://yallarewards-hfhxdxerb8caa8g9.switzerlandnorth-01.azurewebsites.net";

  List myCoupons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getMyCoupons();
  }

  Future<void> getMyCoupons() async {
    final sessionId = SessionStore.current?.sessionId;

    final response = await http.get(
      Uri.parse("$baseUrl/api/Coupons/user"),
      headers: {"X-Session-Id": sessionId ?? ""},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      final seen = <String>{};
      final uniqueCoupons = data.where((coupon) {
        final id = coupon['couponId']?.toString() ?? '';
        if (seen.contains(id)) return false;
        seen.add(id);
        return true;
      }).toList();
      setState(() {
        myCoupons = uniqueCoupons;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> redeemCoupon(Map<String, dynamic> coupon) async {
    final sessionId = SessionStore.current?.sessionId;
    final couponId = coupon['couponId']?.toString() ?? '';

    final response = await http.post(
      Uri.parse("$baseUrl/api/Coupons/redeem"),
      headers: {
        "Content-Type": "application/json",
        "X-Session-Id": sessionId ?? "",
      },
      body: jsonEncode({"couponId": couponId}),
    );

    if (response.statusCode == 200) {
      var serialNumber = _serialNumberFromApiResponse(response.body);
      if (serialNumber.isEmpty) {
        serialNumber = _findSerialNumber(coupon);
      }

      await getMyCoupons();
      if (!mounted) return;

      _showSerialNumberDialog(serialNumber);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
    }
  }

  void _onTabTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CouponPage()),
      );
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HistoryPage()),
      );
    }
  }

  void _showSerialNumberDialog(String serialNumber) {
    showDialog(
      context: context,
      builder: (context) => _SerialNumberDialog(serialNumber: serialNumber),
    );
  }

  String _serialNumberFromApiResponse(String responseBody) {
    final trimmedBody = responseBody.trim();
    if (trimmedBody.isEmpty) {
      return '';
    }

    try {
      final decoded = json.decode(trimmedBody);
      final serialNumber = _findSerialNumber(decoded);
      if (serialNumber.isNotEmpty) {
        return serialNumber;
      }

      if (decoded is String) {
        return decoded.trim();
      }
    } catch (_) {
      return trimmedBody;
    }

    return '';
  }

  String _findSerialNumber(dynamic value) {
    const serialKeys = {
      'serialnumber',
      'serial',
      'serialno',
      'serialnum',
      'code',
      'couponcode',
      'redemptioncode',
    };

    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString().toLowerCase();
        final entryValue = entry.value;

        if (serialKeys.contains(key) &&
            entryValue != null &&
            entryValue.toString().trim().isNotEmpty) {
          return entryValue.toString().trim();
        }
      }

      for (final entry in value.entries) {
        final serialNumber = _findSerialNumber(entry.value);
        if (serialNumber.isNotEmpty) {
          return serialNumber;
        }
      }
    }

    if (value is List) {
      for (final item in value) {
        final serialNumber = _findSerialNumber(item);
        if (serialNumber.isNotEmpty) {
          return serialNumber;
        }
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF51A2B4),
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
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 24,
                    child: Center(
                      child: Text(
                        'Offers & Announcements',
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TabItem(
                  label: 'Get rewards',
                  onTap: () => _onTabTap(0),
                  selected: false,
                ),
                _TabItem(label: 'My rewards', onTap: () {}, selected: true),
                _TabItem(
                  label: 'History',
                  onTap: () => _onTabTap(2),
                  selected: false,
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : myCoupons.isEmpty
                ? const Center(child: Text('No coupons yet'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    itemCount: myCoupons.length,
                    itemBuilder: (context, index) {
                      final item = myCoupons[index] as Map<String, dynamic>;
                      final isRedeemed = item['isRedeemed'] == true;
                      final isExpired = _isExpired(item);
                      final isFaded = isRedeemed || isExpired;

                      return _MyCouponCard(
                        coupon: item,
                        isFaded: isFaded,
                        statusLabel: isRedeemed
                            ? 'Used'
                            : isExpired
                            ? 'Expired'
                            : 'Active',
                        onUsePressed: () => redeemCoupon(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _isExpired(Map<String, dynamic> coupon) {
    final rawDate = _stringValue(coupon, [
      'endDate',
      'endsAt',
      'validTo',
      'expirationDate',
      'expiredAt',
    ]);
    if (rawDate.isEmpty) {
      return false;
    }

    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return false;
    }

    return parsed.isBefore(DateTime.now());
  }

  String _stringValue(Map<String, dynamic> coupon, List<String> keys) {
    for (final key in keys) {
      final value = coupon[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.onTap,
    required this.selected,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE2E2E2)
                : const Color.fromRGBO(255, 255, 255, 0.35),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SerialNumberDialog extends StatelessWidget {
  const _SerialNumberDialog({required this.serialNumber});

  final String serialNumber;

  @override
  Widget build(BuildContext context) {
    final hasSerialNumber = serialNumber.trim().isNotEmpty;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 266,
        height: 176,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF1F6673), width: 4),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 2,
              right: 2,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: Colors.grey.shade700,
                  size: 28,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 44, 18, 24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasSerialNumber
                          ? 'your serial number : ${serialNumber.trim()}'
                          : 'serial number unavailable',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      hasSerialNumber
                          ? 'give it to the cashier to use it'
                          : 'please try again',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
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

class _MyCouponCard extends StatelessWidget {
  const _MyCouponCard({
    required this.coupon,
    required this.isFaded,
    required this.statusLabel,
    required this.onUsePressed,
  });

  final Map<String, dynamic> coupon;
  final bool isFaded;
  final String statusLabel;
  final VoidCallback onUsePressed;

  String get title => _stringValue(['couponType', 'type', 'title'], 'Coupon');
  String get description =>
      _stringValue(['couponDescription', 'description'], '');
  String get startDate =>
      _dateValue(['startDate', 'startsAt', 'validFrom', 'createdAt']);
  String get endDate => _dateValue([
    'endDate',
    'endsAt',
    'validTo',
    'expirationDate',
    'expiredAt',
  ]);

  @override
  Widget build(BuildContext context) {
    final displayStart = startDate.isEmpty ? '1 Mar 2026' : startDate;
    final displayEnd = endDate.isEmpty ? '20 Mar 2026' : endDate;
    final cardColor = isFaded ? Colors.grey.shade200 : Colors.white;
    final topColor = isFaded ? Colors.grey.shade400 : const Color(0xFF2B6E7F);

    return Opacity(
      opacity: isFaded ? 0.55 : 1,
      child: Container(
        height: 210,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 98,
              width: double.infinity,
              decoration: BoxDecoration(
                color: topColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 18,
                    right: 112,
                    top: 18,
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/gift1.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Starts: $displayStart',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ends: $displayEnd',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isFaded && statusLabel == 'Active')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isFaded
                                  ? Colors.grey.shade300
                                  : const Color(0xFFE6F2F5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: isFaded
                                    ? Colors.grey.shade700
                                    : const Color(0xFF2B6E7F),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (!isFaded)
                          GestureDetector(
                            onTap: onUsePressed,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2B6E7F),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'Use It',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                      ],
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

  String _dateValue(List<String> keys) {
    final raw = _stringValue(keys);
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

  String _stringValue(List<String> keys, [String fallback = '']) {
    for (final key in keys) {
      final value = coupon[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }
}
