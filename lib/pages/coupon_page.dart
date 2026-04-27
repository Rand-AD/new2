import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/session_store.dart';
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

      print("REDEEM STATUS = ${response.statusCode}");
      print("REDEEM BODY = ${response.body}");

      if (response.statusCode == 200) {
        final cost = coupons[index]['costPoint'] ?? 0;

        // ✅ update points
        final old = SessionStore.current!;
        SessionStore.current = old.copyWith(
          totalPoints: (old.totalPoints - cost).toInt(),
        );

        // ✅ refresh coupons from API (removes redeemed ones)
        await getCoupons();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Coupon redeemed successfully")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      print(e);
    }
  }

  // ================= GET COUPONS =================
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

      print("STATUS = ${response.statusCode}");
      print("BODY = ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final myCoupons = await getMyCouponsIds();
        setState(() {
          coupons = data.where((c) => !myCoupons.contains(c['id'])).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("ERROR = $e");
      setState(() => isLoading = false);
    }
  }

  Future<List<String>> getMyCouponsIds() async {
    final sessionId = SessionStore.current?.sessionId;

    final response = await http.get(
      Uri.parse("$baseUrl/api/Coupons/user"),
      headers: {"X-Session-Id": sessionId ?? ""},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data.map<String>((e) => e['couponId'].toString()).toList();
    }

    return [];
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coupons"),
        backgroundColor: const Color(0xFF5FA9BB),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyCouponsPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : coupons.isEmpty
          ? const Center(child: Text("No coupons available"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                final item = coupons[index];

                return GestureDetector(
                  onTap: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Redeem Coupon"),
                        content: const Text(
                          "Are you sure you want to redeem this coupon?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Redeem"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      redeemCoupon(item['id'], index);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['type'] ?? "No type",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Text(item['discription'] ?? ""),

                        const SizedBox(height: 8),

                        Text(
                          "Cost: ${item['costPoint'] ?? ''} points",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
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
