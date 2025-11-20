import 'reward_model.dart';

class CouponModel {
  final int id;
  final int userId;
  final int rewardId;
  final String code;
  final String status;
  final DateTime createdAt;
  final DateTime? redeemedAt;
  final RewardModel? reward;

  CouponModel({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.code,
    required this.status,
    required this.createdAt,
    this.redeemedAt,
    this.reward,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      rewardId: json['reward_id'] as int,
      code: json['code'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
      redeemedAt: json['redeemed_at'] != null 
          ? DateTime.parse(json['redeemed_at'])
          : null,
      reward: json['reward'] != null 
          ? RewardModel.fromJson(json['reward'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reward_id': rewardId,
      'code': code,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'redeemed_at': redeemedAt?.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isUsed => status == 'used';
  bool get isExpired => status == 'expired';
}