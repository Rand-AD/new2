class CouponData {
  final String id;
  final String title;
  final String subtitle;
  final String points;
  final String start;
  final String end;

  CouponData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.start,
    required this.end,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) {
    return CouponData(
      id: json['id'],
      title: json['type'] ?? '',
      subtitle: json['discription'] ?? '',
      points: json['costPoint'].toString(),
      start: json['startAt']?.toString().substring(0, 10) ?? '',
      end: json['endAt']?.toString().substring(0, 10) ?? '',
    );
  }
}
