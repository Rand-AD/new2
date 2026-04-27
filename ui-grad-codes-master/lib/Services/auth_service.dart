import 'dart:convert';
import 'package:dio/dio.dart';
import '../Network/api_client.dart';
import '../core/constants.dart';
import '../models/user_session.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  static const String authPath = "/api/Auth/login-or-register";

  Future<UserSession> loginOrRegister({
    required String phoneNumber,
    required String password,
    required String name,
  }) async {
    final res = await _dio.post(
      authPath,
      data: {
        "phoneNumber": phoneNumber,
        "password": password,
        "name": name,
        "mallID": AppConstants.mallId,
      },
      options: Options(responseType: ResponseType.plain),
    );

    final status = res.statusCode ?? 0;

    if (status == 200 || status == 201) {
      final data = res.data;

      if (data is Map) {
        return UserSession.fromJson(Map<String, dynamic>.from(data));
      }

      if (data is String) {
        final s = data.trim();

        if (s.isEmpty) {
          throw DioException(
            requestOptions: res.requestOptions,
            response: res,
            message: "Success but empty response from server.",
          );
        }

        try {
          final decoded = jsonDecode(s);
          if (decoded is Map<String, dynamic>) {
            return UserSession.fromJson(decoded);
          }
        } catch (_) {}

        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          message: s,
        );
      }

      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: "Success but unexpected response format: ${data.runtimeType}",
      );
    }

    final d = res.data;
    final msg = (d is String && d.trim().isNotEmpty)
        ? d.trim()
        : "Request failed (status $status).";

    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      message: msg,
    );
  }
}
