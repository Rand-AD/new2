import 'package:flutter/material.dart';

import '../Services/api_service.dart';
import 'home_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  static const Color pageBg = Color(0xFFE7E7E7);
  static const Color teal = Color(0xFF4FA4B8);
  static const Color tealDark = Color(0xFF0D6678);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<_NotificationItem> items = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final data = await ApiService.getNotifications();

      if (!mounted) {
        return;
      }

      setState(() {
        items = data
            .whereType<Map>()
            .map((item) => _NotificationItem.fromJson(item))
            .toList();
        isLoading = false;
        errorMessage = '';
      });
    } catch (e) {
      debugPrint('NOTIFICATIONS ERROR = $e');
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load notifications';
      });
    }
  }

  Widget _buildNotificationsBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(errorMessage, style: const TextStyle(fontSize: 16)),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text('No notifications', style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 24, 12, 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _NotificationCard(item: items[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotificationsPage.pageBg,
      body: Column(
        children: [
          Container(
            height: 125,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: NotificationsPage.teal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(42),
                bottomRight: Radius.circular(42),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomePage(initialIndex: 0),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 30,
                      ),
                      tooltip: 'Back',
                    ),
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _buildNotificationsBody()),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      decoration: BoxDecoration(
        color: NotificationsPage.teal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo3.png',
                  width: 42,
                  height: 42,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.notifications_none,
                    color: NotificationsPage.tealDark,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (!item.isRead) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.message.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.18,
                    ),
                  ),
                ],
                if (item.date.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.date,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
  });

  factory _NotificationItem.fromJson(Map<dynamic, dynamic> json) {
    var title = _stringValue(json, [
      'title',
      'notificationTitle',
      'subject',
      'heading',
      'name',
    ]);

    var message = _stringValue(json, [
      'message',
      'notificationMessage',
      'content',
      'body',
      'description',
      'details',
      'text',
    ]);

    final type = _stringValue(json, [
      'type',
      'notificationType',
      'category',
      'eventType',
    ]);
    final storeName = _firstNonEmpty([
      _stringValue(json, ['storeName', 'store_name', 'shopName']),
      _nestedString(json, 'store', ['name', 'storeName', 'store_name']),
      _nestedString(json, 'shop', ['name', 'shopName']),
    ]);
    final offerTitle = _nestedString(json, 'offer', ['title', 'name']);
    final announcementTitle = _nestedString(json, 'announcement', [
      'title',
      'name',
    ]);

    if (title.isEmpty) {
      if (offerTitle.isNotEmpty) {
        title = offerTitle;
      } else if (announcementTitle.isNotEmpty) {
        title = announcementTitle;
      } else if (type.isNotEmpty) {
        title = _titleCase(type);
      } else if (storeName.isNotEmpty) {
        title = '$storeName has an update';
      } else {
        title = 'Notification';
      }
    }

    if (message.isEmpty) {
      message = _firstNonEmpty([
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
      ]);
    }

    if (message.isEmpty && storeName.isNotEmpty) {
      message = type.toLowerCase().contains('offer')
          ? '$storeName has an offer'
          : 'New update from $storeName';
    }

    return _NotificationItem(
      title: title,
      message: message,
      date: _formatDate(
        _stringValue(json, [
          'date',
          'createdAt',
          'created_at',
          'createdOn',
          'sentAt',
          'sent_at',
          'madeAt',
          'made_at',
          'updatedAt',
          'timestamp',
          'startAt',
        ]),
      ),
      isRead: _boolValue(json, ['isRead', 'read', 'seen', 'viewed']),
    );
  }

  final String title;
  final String message;
  final String date;
  final bool isRead;

  static String _stringValue(Map<dynamic, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  static String _nestedString(
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

  static String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
  }

  static bool _boolValue(Map<dynamic, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) {
        return value;
      }

      if (value is num) {
        return value != 0;
      }

      final text = value?.toString().trim().toLowerCase();
      if (text == 'true' || text == 'yes' || text == '1') {
        return true;
      }

      if (text == 'false' || text == 'no' || text == '0') {
        return false;
      }
    }

    return true;
  }

  static String _titleCase(String value) {
    return value
        .replaceAll('_', ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) {
            return word;
          }

          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  static String _formatDate(String value) {
    if (value.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(value);

    if (parsed != null) {
      return '${parsed.year}/${parsed.month}/${parsed.day}';
    }

    if (value.length >= 10) {
      return value.substring(0, 10).replaceAll('-', '/');
    }

    return value;
  }
}
