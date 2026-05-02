import 'package:dio/dio.dart';
import '../core/api_client.dart';

class OffersService {
  static final Dio _dio = ApiClient.dio;

  static Future<List<dynamic>> getOffers(String sessionId) async {
    final response = await _dio.get(
      "/api/offers",
      options: Options(
        headers: {
          "X-Session-Id": sessionId, // ✅ THIS IS THE FIX
        },
      ),
    );
    print("RESPONSE = ${response.data}");
    if (response.statusCode == 200) {
      final data = response.data;

      if (data is Map && data.containsKey("data")) {
        return data["data"];
      }

      return data;
    } else {
      throw Exception("Failed: ${response.data}");
    }
  }
}
