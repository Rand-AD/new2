import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/session_store.dart';

class ApiService {
  static const String baseUrl =
      "https://yallarewards-hfhxdxerb8caa8g9.switzerlandnorth-01.azurewebsites.net/api";

  static Future<List<dynamic>> getStores() async {
    final response = await http.get(
      Uri.parse("$baseUrl/Stores"),
      headers: headers, // 🔥 use your common headers
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  static Future<List<dynamic>> getUserCoupons() async {
    final sessionId = SessionStore.current?.sessionId;

    final response = await http.get(
      Uri.parse("$baseUrl/Coupons/user"),
      headers: {"X-Session-Id": sessionId ?? ""},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  }

  // ================= COMMON HEADER =================
  static Map<String, String> get headers {
    final sessionId = SessionStore.current?.sessionId ?? "";

    return {"Content-Type": "application/json", "X-Session-Id": sessionId};
  }

  // ================= GET ANNOUNCEMENTS =================
  static Future<List<dynamic>> getAnnouncements() async {
    final response = await http.get(
      Uri.parse("$baseUrl/Announcements"),
      headers: headers,
    );

    print("ANNOUNCEMENTS STATUS = ${response.statusCode}");
    print("ANNOUNCEMENTS BODY = ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  static Future<Map<String, dynamic>> getTransaction(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/Transactions/$id"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  static Future<Map<String, dynamic>> getMyReceipts() async {
    final response = await http.get(
      Uri.parse("$baseUrl/Transactions/my-receipts"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }
  // ================= GET COUPONS =================
  static Future<List<dynamic>> getCoupons() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/Coupons?isActive=true"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired");
      }

      throw Exception("Failed to load coupons");
    } catch (e) {
      print("COUPONS ERROR = $e");
      return [];
    }
  }
}
