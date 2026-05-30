import 'dart:convert';
import 'package:flutter/foundation.dart';
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
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        final nested =
            data['items'] ?? data['data'] ?? data['coupons'] ?? data['results'];

        if (nested is List) {
          return nested;
        }
      }
    }

    return [];
  }

  // ================= COMMON HEADER =================
  static Map<String, String> get headers {
    final sessionId = SessionStore.current?.sessionId ?? "";

    return {"Content-Type": "application/json", "X-Session-Id": sessionId};
  }

  static Future<int> getUserPoints() async {
    final response = await http.get(
      Uri.parse("$baseUrl/userinfo/points"),
      headers: headers,
    );

    debugPrint("POINTS STATUS = ${response.statusCode}");
    debugPrint("POINTS BODY = ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);

    if (data is num || data is String) {
      return _intValue(data);
    }

    if (data is Map<String, dynamic>) {
      final value =
          data['totalPoints'] ??
          data['points'] ??
          data['balance'] ??
          data['pointBalance'] ??
          data['data'];

      if (value is Map<String, dynamic>) {
        return _intValue(
          value['totalPoints'] ??
              value['points'] ??
              value['balance'] ??
              value['pointBalance'],
        );
      }

      return _intValue(value);
    }

    return 0;
  }

  static Future<int> refreshUserPoints() async {
    final points = await getUserPoints();
    final session = SessionStore.current;

    if (session != null) {
      await SessionStore.save(session.copyWith(totalPoints: points));
    }

    return points;
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse((value ?? '0').toString()) ?? 0;
  }

  // ================= GET ANNOUNCEMENTS =================
  static Future<List<dynamic>> getAnnouncements() async {
    final response = await http.get(
      Uri.parse("$baseUrl/Announcements"),
      headers: headers,
    );

    debugPrint("ANNOUNCEMENTS STATUS = ${response.statusCode}");
    debugPrint("ANNOUNCEMENTS BODY = ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  // ================= GET NOTIFICATIONS =================
  static Future<List<dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse("$baseUrl/Notifications"),
      headers: headers,
    );

    debugPrint("NOTIFICATIONS STATUS = ${response.statusCode}");
    debugPrint("NOTIFICATIONS BODY = ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        final nested =
            data['items'] ??
            data['data'] ??
            data['notifications'] ??
            data['results'];

        if (nested is List) {
          return nested;
        }

        if (nested is Map<String, dynamic>) {
          return [nested];
        }

        final isSingleNotification = [
          'title',
          'message',
          'content',
          'body',
          'description',
          'notificationType',
          'type',
          'storeName',
          'createdAt',
          'date',
          'offer',
          'announcement',
        ].any((key) => data.containsKey(key));

        return isSingleNotification ? [data] : [];
      }

      return [];
    }

    throw Exception(response.body);
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
      debugPrint("COUPONS ERROR = $e");
      return [];
    }
  }
}
