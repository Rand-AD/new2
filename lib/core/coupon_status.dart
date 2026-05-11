class CouponStatus {
  const CouponStatus._();

  static List<Map<String, dynamic>> uniqueInstances(Iterable<dynamic> data) {
    final seen = <String>{};
    final coupons = <Map<String, dynamic>>[];
    var index = 0;

    for (final item in data) {
      if (item is! Map) {
        continue;
      }

      final coupon = Map<String, dynamic>.from(item);
      final key = instanceKey(coupon, index);
      if (seen.add(key)) {
        coupons.add(coupon);
      }
      index++;
    }

    return coupons;
  }

  static String instanceKey(Map<String, dynamic> coupon, int index) {
    final serial = serialNumber(coupon);
    if (serial.isNotEmpty) {
      return 'serial:$serial';
    }

    final instanceId = stringValue(coupon, [
      'userCouponId',
      'couponUserId',
      'userRewardId',
      'rewardUserId',
      'redeemedCouponId',
      'ownedCouponId',
    ]);
    if (instanceId.isNotEmpty) {
      return 'instance:$instanceId';
    }

    final id = stringValue(coupon, ['id']);
    if (id.isNotEmpty) {
      return 'id:$id';
    }

    final couponId = stringValue(coupon, ['couponId', 'couponID']);
    if (couponId.isNotEmpty) {
      return 'coupon:$couponId';
    }

    return 'row:$index';
  }

  static bool isActive(Map<String, dynamic> coupon) {
    return !isUsed(coupon) && !isExpired(coupon);
  }

  static bool belongsInHistory(Map<String, dynamic> coupon) {
    return isUsed(coupon) || isExpired(coupon);
  }

  static bool isUsed(Map<String, dynamic> coupon) {
    const boolKeys = [
      'isRedeemed',
      'redeemed',
      'isUsed',
      'used',
      'usedByCashier',
      'isUsedByCashier',
      'cashierRedeemed',
      'isCashierRedeemed',
    ];

    for (final key in boolKeys) {
      if (_truthy(coupon[key])) {
        return true;
      }
    }

    final status = stringValue(coupon, [
      'status',
      'couponStatus',
      'state',
    ]).toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');

    if (status.contains('used') ||
        status.contains('consumed') ||
        status.contains('cashier')) {
      return true;
    }

    const usedDateKeys = [
      'usedAt',
      'usedDate',
      'cashierUsedAt',
      'cashierRedeemedAt',
      'cashierRedeemedDate',
    ];

    return stringValue(coupon, usedDateKeys).isNotEmpty;
  }

  static bool isExpired(Map<String, dynamic> coupon) {
    final status = stringValue(coupon, [
      'status',
      'couponStatus',
      'state',
    ]).toLowerCase();
    if (status.contains('expired')) {
      return true;
    }

    final rawDate = stringValue(coupon, [
      'endDate',
      'endsAt',
      'validTo',
      'expirationDate',
      'expiredAt',
      'expiryDate',
    ]);

    if (rawDate.isEmpty) {
      return false;
    }

    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return false;
    }

    final expiresAt = rawDate.contains('T')
        ? parsed
        : DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59);

    return expiresAt.isBefore(DateTime.now());
  }

  static String statusLabel(Map<String, dynamic> coupon) {
    if (isUsed(coupon)) {
      return 'Used';
    }

    if (isExpired(coupon)) {
      return 'Expired';
    }

    return 'Active';
  }

  static String stringValue(
    Map<String, dynamic> coupon,
    List<String> keys, [
    String fallback = '',
  ]) {
    for (final key in keys) {
      final value = coupon[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  static String dateValue(Map<String, dynamic> coupon, List<String> keys) {
    final raw = stringValue(coupon, keys);
    if (raw.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw.split('T').first;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  static String serialNumber(dynamic value) {
    const serialKeys = {
      'serialnumber',
      'serial',
      'serialno',
      'serialnum',
      'serialcode',
      'code',
      'couponcode',
      'couponserial',
      'couponserialnumber',
      'redemptioncode',
      'redemptionserial',
      'redemptionserialnumber',
    };

    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString().toLowerCase();
        final entryValue = entry.value;

        if (serialKeys.contains(key) &&
            entryValue != null &&
            entryValue.toString().trim().isNotEmpty) {
          return entryValue.toString().trim();
        }
      }

      for (final entry in value.entries) {
        final serial = serialNumber(entry.value);
        if (serial.isNotEmpty) {
          return serial;
        }
      }
    }

    if (value is List) {
      for (final item in value) {
        final serial = serialNumber(item);
        if (serial.isNotEmpty) {
          return serial;
        }
      }
    }

    return '';
  }

  static bool _truthy(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value == 1;
    }

    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes' ||
          normalized == 'used';
    }

    return false;
  }
}
