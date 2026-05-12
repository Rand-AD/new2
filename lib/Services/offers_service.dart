import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/api_client.dart';

class OffersService {
  static final Dio _dio = ApiClient.dio;

  static Future<List<dynamic>> getOffers(String sessionId) async {
    final response = await _dio.get(
      "/api/offers",
      options: Options(headers: {"X-Session-Id": sessionId}),
    );

    debugPrint("OFFERS RESPONSE = ${response.data}");

    if (response.statusCode == 200) {
      final data = response.data;

      if (data is List) {
        return data;
      }

      if (data is Map) {
        final nested =
            data["data"] ?? data["items"] ?? data["offers"] ?? data["results"];

        if (nested is List) {
          return nested;
        }
      }

      return [];
    }

    throw Exception("Failed: ${response.data}");
  }
}
