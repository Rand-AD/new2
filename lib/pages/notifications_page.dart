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

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final data = await ApiService.getNotifications();

      setState(() {
        items = data
            .whereType<Map>()
            .map((item) => _NotificationItem.fromJson(item))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('NOTIFICATIONS ERROR = $e');
      setState(() => isLoading = false);
    }
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
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                ? const Center(
                    child: Text(
                      'No notifications',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 24, 12, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _NotificationCard(item: items[index]);
                    },
                  ),
          ),
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
    return SizedBox(
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(70, 11, 12, 7),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
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
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 6,
            child: Container(
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
                      Icons.shopping_bag,
                      color: NotificationsPage.tealDark,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({required this.title, required this.date});

  factory _NotificationItem.fromJson(Map<dynamic, dynamic> json) {
    final title = _stringValue(json, [
      'title',
      'message',
      'content',
      'body',
      'description',
      'text',
    ]);
    final storeName = _stringValue(json, ['storeName', 'store_name', 'name']);

    return _NotificationItem(
      title: title.isNotEmpty
          ? title
          : storeName.isNotEmpty
          ? '$storeName has an offer'
          : 'Notification',
      date: _formatDate(
        _stringValue(json, [
          'date',
          'createdAt',
          'created_at',
          'sentAt',
          'sent_at',
          'madeAt',
          'made_at',
          'updatedAt',
          'startAt',
        ]),
      ),
    );
  }

  final String title;
  final String date;

  static String _stringValue(Map<dynamic, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
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
