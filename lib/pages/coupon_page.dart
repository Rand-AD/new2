import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/session_store.dart';

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

  // ================= GET COUPONS =================
  Future<void> getCoupons() async {
    try {
      print("SESSION = ${SessionStore.current?.sessionId}");
      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/Coupons?isActive=true&sessionId=${SessionStore.current?.sessionId}",
        ),
        headers: {
          "Content-Type": "application/json",
          "session-id": SessionStore.current?.sessionId ?? "",
        },
      );
      print("SESSION HEADER SENT = ${SessionStore.current?.sessionId}");
      print("SESSION = ${SessionStore.current?.sessionId}");
      print(response.body);
      print("COUPONS RESPONSE = ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          coupons = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coupons"),
        backgroundColor: const Color(0xFF5FA9BB),
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

                return Container(
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
                        item['title'] ?? "No title",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(item['description'] ?? ""),
                      const SizedBox(height: 8),
                      Text(
                        "Discount: ${item['discount'] ?? ''}",
                        style: const TextStyle(
                          color: Colors.green,
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
