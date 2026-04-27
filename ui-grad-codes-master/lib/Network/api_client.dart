import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl:
          "https://yallarewards-hfhxdxerb8caa8g9.switzerlandnorth-01.azurewebsites.net",
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    ),
  );
}
