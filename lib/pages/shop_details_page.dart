import 'dart:convert';

import 'package:flutter/material.dart';

class ShopDetailsPage extends StatelessWidget {
  const ShopDetailsPage({super.key, required this.store});

  final Map<String, dynamic> store;

  String get _name => _titleCase(_read(['name', 'storeName', 'store_name']));

  String get _operatingHours =>
      _read(['operatingHours', 'operating_hours', 'hours']);

  String get _description => _read(['description']);

  String get _floor => _floorLabel(
    _read([
      'floorNumber',
      'floor_number',
      'floorName',
      'floor',
      'storeFloor',
      'level',
    ]),
  );

  String get _phoneNumber => _read(['phoneNumber', 'phone_number', 'phone']);

  String get _email => _read(['email']);

  String get _facebook => _socialValue('facebook');

  String get _instagram => _socialValue('instagram');

  String _read(List<String> keys) {
    for (final key in keys) {
      final value = store[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '-';
  }

  String _titleCase(String value) {
    if (value == '-') {
      return value;
    }

    return value
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) {
            return word;
          }

          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }

  String _floorLabel(String value) {
    if (value == '-') {
      return value;
    }

    final floorNumber = int.tryParse(value);

    if (floorNumber != null) {
      const floors = [
        'Ground Floor',
        'First Floor',
        'Second Floor',
        'Third Floor',
      ];

      if (floorNumber >= 0 && floorNumber < floors.length) {
        return floors[floorNumber];
      }
    }

    if (value.toLowerCase().contains('ground')) {
      return 'Ground Floor';
    }

    return _titleCase(value);
  }

  String _socialValue(String key) {
    final socialMedia = _socialMediaLinks();

    if (socialMedia != null) {
      final value = socialMedia[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    final directValue = store[key] ?? store['${key}Url'];
    if (directValue != null && directValue.toString().trim().isNotEmpty) {
      return directValue.toString().trim();
    }

    return '-';
  }

  Map<String, dynamic>? _socialMediaLinks() {
    final value =
        store['socialMediaLinks'] ??
        store['social_media_links'] ??
        store['socialLinks'];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight > 24
                          ? constraints.maxHeight - 24
                          : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.chevron_left),
                            iconSize: 32,
                            color: const Color(0xFF0D6678),
                            tooltip: 'Back',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ),
                        Text(
                          _name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF183A63),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _operatingHours,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 26),
                        _ShopInfoCard(text: _description),
                        _ShopInfoCard(text: _floor),
                        _ShopInfoCard(text: _phoneNumber),
                        _ShopInfoCard(text: _email),
                        _ShopInfoCard(text: 'facebook : "$_facebook"'),
                        _ShopInfoCard(text: 'instagram :"$_instagram"'),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShopInfoCard extends StatelessWidget {
  const _ShopInfoCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 60),
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 7,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}
