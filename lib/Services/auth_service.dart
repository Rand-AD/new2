import 'package:dio/dio.dart';
import '../models/user_session.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          "https://yallarewards-hfhxdxerb8caa8g9.switzerlandnorth-01.azurewebsites.net",
      headers: {"Content-Type": "application/json"},
    ),
  );

  final String mallId = "c424a18c-cca0-4523-a01d-d70a87ff059f";

  // ================= LOGIN =================
  Future<UserSession> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _dio.post(
      "/api/Auth/login",
      data: {
        "phoneNumber": phoneNumber,
        "password": password,
        "mallId": mallId,
      },
    );

    final data = response.data;

    return UserSession(
      message: data['message'] ?? "",
      userId: data['userId'],
      name: data['name'],
      phoneNumber: data['phoneNumber'],
      totalPoints: data['totalPoints'] ?? 0,
      role: data['role'],
      sessionId: data['sessionId'],
    );
  }

  // ================= REGISTER =================
  Future<UserSession> register({
    required String name,
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _dio.post(
      "/api/Auth/register",
      data: {
        "name": name,
        "phoneNumber": phoneNumber,
        "password": password,
        "mallId": mallId,
        "managerId": null,
      },
    );

    final data = response.data;

    return UserSession(
      message: data['message'] ?? "",
      userId: data['userId'],
      name: data['name'],
      phoneNumber: data['phoneNumber'],
      totalPoints: data['totalPoints'] ?? 0,
      role: data['role'],
      sessionId: data['sessionId'],
    );
  }
}
