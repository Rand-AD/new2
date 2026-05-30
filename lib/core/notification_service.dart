import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/api_service.dart';
import 'session_store.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const MethodChannel _channel = MethodChannel(
    'yalla_rewards/notifications',
  );
  static const String _seenNotificationsKey = 'seen_notification_keys';
  static const String _enabledKey = 'notifications_enabled';

  Timer? _pollTimer;
  bool _initialized = false;
  bool _isPolling = false;

  Future<void> initialize() async {
    final enabled = await isEnabled();
    if (!enabled) {
      stop();
      return;
    }

    if (!_initialized) {
      _initialized = true;
      await _invokeNative('initialize');
      await requestPermission();
    }

    startPolling();
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);

    if (enabled) {
      await initialize();
    } else {
      stop();
    }
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) {
      return false;
    }

    try {
      final granted = await _channel.invokeMethod<bool>('requestPermission');
      return granted ?? false;
    } catch (e) {
      debugPrint('NOTIFICATION PERMISSION ERROR = $e');
      return false;
    }
  }

  void startPolling() {
    if (_pollTimer != null) {
      return;
    }

    _pollNotifications(seedOnly: true);
    _pollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _pollNotifications(seedOnly: false),
    );
  }

  Future<void> checkNow() {
    return _pollNotifications(seedOnly: false);
  }

  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollNotifications({required bool seedOnly}) async {
    if (_isPolling) {
      return;
    }

    final sessionId = SessionStore.current?.sessionId.trim() ?? '';
    if (sessionId.isEmpty) {
      return;
    }

    _isPolling = true;

    try {
      final data = await ApiService.getNotifications();
      final notifications = data
          .whereType<Map>()
          .map((item) => Map<dynamic, dynamic>.from(item))
          .toList();

      if (notifications.isEmpty) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final seen = (prefs.getStringList(_seenNotificationsKey) ?? []).toSet();
      final responseKeys = <String>[];
      final newItems = <Map<dynamic, dynamic>>[];

      for (final notification in notifications) {
        final key = _notificationKey(notification);
        responseKeys.add(key);

        if (!seen.contains(key)) {
          newItems.add(notification);
        }
      }

      if (seedOnly || seen.isEmpty) {
        await prefs.setStringList(
          _seenNotificationsKey,
          responseKeys.take(100).toList(),
        );
        return;
      }

      for (final item in newItems.take(5).toList().reversed) {
        await showNotification(
          title: _notificationTitle(item),
          body: _notificationBody(item),
        );
      }

      if (newItems.isNotEmpty) {
        await prefs.setStringList(
          _seenNotificationsKey,
          {...responseKeys, ...seen}.take(100).toList(),
        );
      }
    } catch (e) {
      debugPrint('NOTIFICATION POLL ERROR = $e');
    } finally {
      _isPolling = false;
    }
  }

  Future<bool> showNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      return false;
    }

    try {
      final shown = await _channel.invokeMethod<bool>('showNotification', {
        'title': title.trim().isEmpty ? 'YallaRewards' : title.trim(),
        'body': body.trim().isEmpty
            ? 'You have a new notification'
            : body.trim(),
      });

      return shown ?? false;
    } catch (e) {
      debugPrint('SHOW NOTIFICATION ERROR = $e');
      return false;
    }
  }

  Future<dynamic> _invokeNative(String method) async {
    if (kIsWeb) {
      return null;
    }

    try {
      return _channel.invokeMethod(method);
    } catch (e) {
      debugPrint('NOTIFICATION NATIVE ERROR = $e');
      return null;
    }
  }

  String _notificationKey(Map<dynamic, dynamic> json) {
    final id = _firstNonEmpty([
      _stringValue(json, ['id']),
      _stringValue(json, ['notificationId', 'notificationID']),
      _stringValue(json, ['announcementId', 'offerId']),
    ]);

    if (id.isNotEmpty) {
      return 'id:$id';
    }

    return [
      _notificationTitle(json),
      _notificationBody(json),
      _stringValue(json, [
        'date',
        'createdAt',
        'created_at',
        'createdOn',
        'sentAt',
        'sent_at',
        'timestamp',
      ]),
    ].join('|');
  }

  String _notificationTitle(Map<dynamic, dynamic> json) {
    final title = _stringValue(json, [
      'title',
      'notificationTitle',
      'subject',
      'heading',
      'name',
    ]);

    if (title.isNotEmpty) {
      return title;
    }

    return _firstNonEmpty([
      _nestedString(json, 'offer', ['title', 'name']),
      _nestedString(json, 'announcement', ['title', 'name']),
      _stringValue(json, ['type', 'notificationType', 'category']),
      'YallaRewards',
    ]);
  }

  String _notificationBody(Map<dynamic, dynamic> json) {
    final message = _stringValue(json, [
      'message',
      'notificationMessage',
      'content',
      'body',
      'description',
      'details',
      'text',
    ]);

    if (message.isNotEmpty) {
      return message;
    }

    final storeName = _firstNonEmpty([
      _stringValue(json, ['storeName', 'store_name', 'shopName']),
      _nestedString(json, 'store', ['name', 'storeName', 'store_name']),
      _nestedString(json, 'shop', ['name', 'shopName']),
    ]);

    return _firstNonEmpty([
      _nestedString(json, 'offer', [
        'description',
        'content',
        'message',
        'body',
      ]),
      _nestedString(json, 'announcement', [
        'content',
        'description',
        'message',
        'body',
      ]),
      storeName.isEmpty ? '' : 'New update from $storeName',
      'You have a new notification',
    ]);
  }

  String _stringValue(Map<dynamic, dynamic> json, List<String> keys) {
    final normalizedKeys = keys.map(_normalizeKey).toSet();

    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    for (final entry in json.entries) {
      if (!normalizedKeys.contains(_normalizeKey(entry.key.toString()))) {
        continue;
      }

      final value = entry.value;
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  String _nestedString(
    Map<dynamic, dynamic> json,
    String parentKey,
    List<String> keys,
  ) {
    final value = json[parentKey];
    if (value is! Map) {
      return '';
    }

    return _stringValue(value, keys);
  }

  String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
  }

  String _normalizeKey(String key) {
    return key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
