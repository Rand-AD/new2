import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/session_store.dart';

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
      headers: {
        "X-Session-Id": sessionId ?? "",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        myCoupons = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Coupons")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : myCoupons.isEmpty
          ? const Center(child: Text("No coupons yet"))
          : ListView.builder(
              itemCount: myCoupons.length,
              itemBuilder: (context, index) {
                final item = myCoupons[index];

                return ListTile(
                  title: Text(item['couponType'] ?? ''),
                  subtitle: Text(item['couponDescription'] ?? ''),
                  trailing: Text(
                    item['isRedeemed'] ? "Used" : "Active",
                    style: TextStyle(
                      color: item['isRedeemed']
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                );
              },
            ),
    );
  }
}