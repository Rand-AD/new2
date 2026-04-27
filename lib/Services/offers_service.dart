import 'package:dio/dio.dart';

class OffersService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          "https://yallarewards-hfhxdxerb8caa8g9.switzerlandnorth-01.azurewebsites.net",
      headers: {
        "Content-Type": "application/json",
        "accept": "*/*",
      },
    ),
  );

  static Future<List<dynamic>> getOffers(String sessionId) async {
    print("SESSION SENT = $sessionId");

    final response = await _dio.get(
      "/api/Offers",
      options: Options(
        headers: {
          "session-id": sessionId, // 🔥 THIS IS THE CORRECT ONE
        },
      ),
    );

    print("RESPONSE = ${response.data}");

    if (response.statusCode == 200) {
      final data = response.data;

      // handle different formats
      if (data is Map && data.containsKey("data")) {
        return data["data"];
      }

      return data;
    } else {
      throw Exception("Failed: ${response.data}");
    }
  }
}