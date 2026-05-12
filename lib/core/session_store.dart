import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_session.dart';

class SessionStore {
  static const String _sessionKey = 'user_session';

  static UserSession? current;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);

    if (raw == null || raw.trim().isEmpty) {
      current = null;
      return;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is Map<String, dynamic>) {
        current = UserSession.fromJson(decoded);
      } else {
        current = null;
      }
    } catch (_) {
      current = null;
      await prefs.remove(_sessionKey);
    }
  }

  static Future<void> save(UserSession session) async {
    current = session;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  static Future<void> clear() async {
    current = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
