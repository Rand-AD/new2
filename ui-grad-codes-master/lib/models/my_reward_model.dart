class MyRewardModel {
  final String serialNumber;
  final String couponId;
  final String couponType;
  final String couponDescription;
  final String validFrom;
  final String validUntil;

  MyRewardModel({
    required this.serialNumber,
    required this.couponId,
    required this.couponType,
    required this.couponDescription,
    required this.validFrom,
    required this.validUntil,
  });

  factory MyRewardModel.fromJson(Map<String, dynamic> json) {
    return MyRewardModel(
      serialNumber: json['serialNumber'],
      couponId: json['couponId'],
      couponType: json['couponType'],
      couponDescription: json['couponDescription'],
      validFrom: json['validFrom'],
      validUntil: json['validUntil'],
    );
  }
}
