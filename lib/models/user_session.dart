class UserSession {
  final String name;
  final String phoneNumber;
  final int totalPoints;
  final String sessionId;

  final String? message;
  final String? userId;
  final String? role;

  UserSession({
    required this.name,
    required this.phoneNumber,
    required this.totalPoints,
    required this.sessionId,
    this.message,
    this.userId,
    this.role,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      name: json["name"]?.toString() ?? "",
      phoneNumber: json["phoneNumber"]?.toString() ?? "",
      totalPoints: _toInt(json["totalPoints"]),
      sessionId: json["sessionId"]?.toString() ?? "",

      // optional fields
      message: json["message"]?.toString(),
      userId: json["userId"]?.toString(),
      role: json["role"]?.toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse((v ?? "0").toString()) ?? 0;
  }
  UserSession copyWith({
  String? name,
  String? phoneNumber,
  int? totalPoints,
  String? sessionId,
  String? message,
  String? userId,
  String? role,
}) {
  return UserSession(
    name: name ?? this.name,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    totalPoints: totalPoints ?? this.totalPoints,
    sessionId: sessionId ?? this.sessionId,
    message: message ?? this.message,
    userId: userId ?? this.userId,
    role: role ?? this.role,
  );
}
}