import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/coupon_status.dart';
import '../core/session_store.dart';
import '../widgets/code128_barcode.dart';
import '../widgets/reward_coupon_card.dart';
import '../widgets/rewards_header.dart';
import 'coupon_page.dart';
import 'history_page.dart';

class MyCouponsPage extends StatefulWidget {
  const MyCouponsPage({super.key});

  @override
  State<MyCouponsPage> createState() => _MyCouponsPageState();
}

class _MyCouponsPageState extends State<MyCouponsPage>
    with WidgetsBindingObserver {
  final String baseUrl =
      "https://yallarewards-hfhxdxerb8caa8g9.switzerlandnorth-01.azurewebsites.net";

  List<Map<String, dynamic>> myCoupons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getMyCoupons();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getMyCoupons();
    }
  }

  Future<void> getMyCoupons() async {
    final sessionId = SessionStore.current?.sessionId;

    final response = await http.get(
      Uri.parse("$baseUrl/api/Coupons/user"),
      headers: {"X-Session-Id": sessionId ?? ""},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      final activeCoupons = CouponStatus.uniqueInstances(
        data,
      ).where(CouponStatus.isActive).toList();

      if (!mounted) return;
      setState(() {
        myCoupons = activeCoupons;
        isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> showCouponSerial(Map<String, dynamic> coupon) async {
    await _showSerialNumberDialog(CouponStatus.serialNumber(coupon));
    if (!mounted) return;
    await getMyCoupons();
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

  Future<void> _showSerialNumberDialog(String serialNumber) {
    return showDialog(
      context: context,
      builder: (context) => _SerialNumberDialog(serialNumber: serialNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          const RewardsHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TabItem(
                  label: 'All rewards',
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
                ? const Center(child: Text('No active coupons yet'))
                : RefreshIndicator(
                    onRefresh: getMyCoupons,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                      itemCount: myCoupons.length,
                      itemBuilder: (context, index) {
                        final item = myCoupons[index];
                        return RewardCouponCard(
                          coupon: item,
                          isFaded: false,
                          statusLabel: 'Active',
                          onUsePressed: () => showCouponSerial(item),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
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
    final formattedCode = _formatCode(serialNumber);

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 292,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF1F6673), width: 4),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey.shade700,
                      size: 26,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your redemption code is :',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2B6E7F),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasSerialNumber ? formattedCode : 'Unavailable',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2B6E7F),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Show this code to the cashier to redeem your offer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF606060),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              if (hasSerialNumber) ...[
                const SizedBox(height: 16),
                _CouponBarcode(data: _barcodeValue(serialNumber)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatCode(String value) {
    final compact = value.replaceAll(RegExp(r'\s+'), '').trim();
    if (compact.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (var index = 0; index < compact.length; index++) {
      if (index > 0 && index % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(compact[index]);
    }

    return buffer.toString();
  }

  String _barcodeValue(String value) {
    return value.replaceAll(RegExp(r'\s+'), '').trim();
  }
}

class _CouponBarcode extends StatelessWidget {
  const _CouponBarcode({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return Code128Barcode(
      data: data,
      width: 220,
      height: 52,
      label: 'Coupon barcode for $data',
    );
  }
}
