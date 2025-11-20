class CustomerBalanceModel {
  final int id;
  final int userId;
  final int pointsBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerBalanceModel({
    required this.id,
    required this.userId,
    required this.pointsBalance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerBalanceModel.fromJson(Map<String, dynamic> json) {
    return CustomerBalanceModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      pointsBalance: json['points_balance'] as int,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'points_balance': pointsBalance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}