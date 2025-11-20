class PointsLedgerModel {
  final int id;
  final int userId;
  final int? staffId;
  final int? locationId;
  final int? couponId;
  final int change;
  final String type;
  final String? note;
  final DateTime createdAt;

  PointsLedgerModel({
    required this.id,
    required this.userId,
    this.staffId,
    this.locationId,
    this.couponId,
    required this.change,
    required this.type,
    this.note,
    required this.createdAt,
  });

  factory PointsLedgerModel.fromJson(Map<String, dynamic> json) {
    return PointsLedgerModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      staffId: json['staff_id'] as int?,
      locationId: json['location_id'] as int?,
      couponId: json['coupon_id'] as int?,
      change: json['change'] as int,
      type: json['type'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'staff_id': staffId,
      'location_id': locationId,
      'coupon_id': couponId,
      'change': change,
      'type': type,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isEarn => type == 'earn';
  bool get isRedeem => type == 'redeem';
}