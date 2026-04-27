import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coupon_data.dart';

class GetRewardsServices {
  static const String _baseUrl =
      'https://yallarewards-hfhxdxerb8caa8g9.switzerlandnorth-01.azurewebsites.net/api';

  static Future<List<CouponData>> fetchActiveCoupons() async {
    final url = Uri.parse('$_baseUrl/Coupons');
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to load coupons');
    }

    final decoded = jsonDecode(res.body);

    // 🔴 IMPORTANT: لو الـ API يرجّع List مباشرة
    final List list = decoded is List ? decoded : (decoded['data'] ?? []);

    return list
        .where((e) => e['isActive'] == true)
        .map<CouponData>((e) => CouponData.fromJson(e))
        .toList();
  }
}
