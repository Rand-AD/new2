import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/my_reward_model.dart';

class MyRewardsService {
  static const String _baseUrl =
      'https://yallarewards-hfhxdxerb8caa8g9.switzerlandnorth-01.azurewebsites.net/api';

  static Future<List<MyRewardModel>> fetchMyRewards(String userId) async {
    final url = Uri.parse('$_baseUrl/Coupons/user/$userId');
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to load rewards');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => MyRewardModel.fromJson(e)).toList();
  }
}
