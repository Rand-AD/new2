class UserSession {
  final String message;
  final String userId;
  final String phoneNumber;
  final String name;
  final int totalPoints;
  final String role;
  final String sessionId;

  UserSession({
    required this.message,
    required this.userId,
    required this.phoneNumber,
    required this.name,
    required this.totalPoints,
    required this.role,
    required this.sessionId,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      message: (json["message"] ?? "").toString(),
      userId: (json["userId"] ?? "").toString(),
      phoneNumber: (json["phoneNumber"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      totalPoints: _toInt(json["totalPoints"]),
      role: (json["role"] ?? "").toString(),
      sessionId: (json["sessionId"] ?? "").toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse((v ?? "0").toString()) ?? 0;
  }
}
