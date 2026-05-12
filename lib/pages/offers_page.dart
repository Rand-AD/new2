import 'package:flutter/material.dart';

import '../Services/api_service.dart';
import '../Services/offers_service.dart';
import '../core/session_store.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  static const Color pageBg = Color(0xFFF6F6F6);
  static const Color teal = Color(0xFF5FA9BB);

  List<_OfferAnnouncementItem> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final sessionId = SessionStore.current?.sessionId ?? '';
      final results = await Future.wait([
        OffersService.getOffers(sessionId),
        ApiService.getAnnouncements(),
      ]);

      final offers = results[0].whereType<Map>().map(
        (item) => _OfferAnnouncementItem.fromOffer(item),
      );
      final announcements = results[1].whereType<Map>().map(
        (item) => _OfferAnnouncementItem.fromAnnouncement(item),
      );

      setState(() {
        items = [...offers, ...announcements];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('OFFERS PAGE ERROR = $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: Column(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: teal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(56),
                bottomRight: Radius.circular(56),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    left: 18,
                    top: 16,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: Text(
                        'Offers & Announcement',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
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
                ? const Center(child: Text('No offers or announcements'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _OfferAnnouncementCard(item: items[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _OfferAnnouncementCard extends StatelessWidget {
  const _OfferAnnouncementCard({required this.item});

  final _OfferAnnouncementItem item;

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.08),
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 266,
              constraints: const BoxConstraints(minHeight: 173),
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFF1D5D6D), width: 2.4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.content,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.16,
                          ),
                        ),
                        if (item.date.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            item.date,
                            style: const TextStyle(
                              color: Color(0xFF2B6E7F),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    right: -8,
                    top: -10,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      iconSize: 22,
                      color: Color(0xFF777777),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: 'Close',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        constraints: const BoxConstraints(minHeight: 118),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 54,
              height: 44,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF2B6E7F),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6A8D95),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.18,
                    ),
                  ),
                  if (item.date.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        item.date,
                        style: const TextStyle(
                          color: Color(0xFF6A8D95),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferAnnouncementItem {
  const _OfferAnnouncementItem({
    required this.title,
    required this.content,
    required this.date,
  });

  factory _OfferAnnouncementItem.fromOffer(Map<dynamic, dynamic> json) {
    return _OfferAnnouncementItem(
      title: _stringValue(json, ['title', 'name'], 'Offer'),
      content: _stringValue(json, [
        'description',
        'content',
        'message',
        'body',
      ], 'No details available'),
      date: _dateValue(json, ['startAt', 'start_at', 'madeAt', 'made_at']),
    );
  }

  factory _OfferAnnouncementItem.fromAnnouncement(Map<dynamic, dynamic> json) {
    return _OfferAnnouncementItem(
      title: _stringValue(json, ['title', 'name'], 'Announcement'),
      content: _stringValue(json, [
        'content',
        'description',
        'message',
        'body',
      ], 'No details available'),
      date: _dateValue(json, ['createdAt', 'created_at', 'date', 'madeAt']),
    );
  }

  final String title;
  final String content;
  final String date;

  static String _stringValue(
    Map<dynamic, dynamic> json,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  static String _dateValue(Map<dynamic, dynamic> json, List<String> keys) {
    final raw = _stringValue(json, keys, '');
    if (raw.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return '${parsed.year}/${parsed.month}/${parsed.day}';
    }

    if (raw.length >= 10) {
      return raw.substring(0, 10).replaceAll('-', '/');
    }

    return raw;
  }
}
