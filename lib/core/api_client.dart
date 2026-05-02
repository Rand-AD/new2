import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl:
          "https://yallarewards-hfhxdxerb8caa8g9.switzerlandnorth-01.azurewebsites.net",
      headers: {"Content-Type": "application/json", "accept": "*/*"},
    ),
  )..interceptors.add(CookieManager(CookieJar()));
}
