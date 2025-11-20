import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/reward_model.dart';
import '../models/coupon_model.dart';
import '../models/points_ledger_model.dart';
import 'supabase_service.dart';

class RewardsService {
  static final SupabaseClient _client = SupabaseService.client;
  static const _uuid = Uuid();

  static Future<List<RewardModel>> getAllRewards() async {
    try {
      final response = await _client
          .from('rewards')
          .select()
          .order('cost_points', ascending: true);

      return response
          .map<RewardModel>((json) => RewardModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load rewards: $e');
    }
  }

  static Future<List<CouponModel>> getUserCoupons(int userId) async {
    try {
      final response = await _client
          .from('coupons')
          .select('''
            id, user_id, reward_id, code, status, created_at, redeemed_at,
            reward:rewards (
              id, name, description, image_url, cost_points, created_at, updated_at
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<CouponModel>((json) => CouponModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load coupons: $e');
    }
  }

  static Future<CouponModel?> redeemReward({
    required int userId,
    required int rewardId,
    required int costPoints,
  }) async {
    try {
      final currentBalance = await _client
          .from('customer_balances')
          .select('points_balance')
          .eq('user_id', userId)
          .single();

      final balance = currentBalance['points_balance'] as int;
      
      if (balance < costPoints) {
        throw Exception('Insufficient points. You have $balance points but need $costPoints.');
      }

      final couponCode = _generateCouponCode();

      final couponResponse = await _client
          .from('coupons')
          .insert({
            'user_id': userId,
            'reward_id': rewardId,
            'code': couponCode,
            'status': 'active',
          })
          .select()
          .single();

      final coupon = CouponModel.fromJson(couponResponse);

      await _client
          .from('customer_balances')
          .update({'points_balance': balance - costPoints})
          .eq('user_id', userId);

      await _client
          .from('points_ledger')
          .insert({
            'user_id': userId,
            'coupon_id': coupon.id,
            'change': -costPoints,
            'type': 'redeem',
            'note': 'Redeemed reward: $couponCode',
          });

      return coupon;
    } catch (e) {
      throw Exception('Failed to redeem reward: $e');
    }
  }

  static Future<bool> useCoupon(String couponCode, int staffId) async {
    try {
      final couponResponse = await _client
          .from('coupons')
          .select()
          .eq('code', couponCode)
          .single();

      final coupon = CouponModel.fromJson(couponResponse);

      if (coupon.status != 'active') {
        throw Exception('Coupon is ${coupon.status}');
      }

      await _client
          .from('coupons')
          .update({
            'status': 'used',
            'redeemed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', coupon.id);

      return true;
    } catch (e) {
      throw Exception('Failed to use coupon: $e');
    }
  }

  static Future<List<PointsLedgerModel>> getUserHistory(int userId) async {
    try {
      final response = await _client
          .from('points_ledger')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return response
          .map<PointsLedgerModel>((json) => PointsLedgerModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load history: $e');
    }
  }

  static String _generateCouponCode() {
    return _uuid.v4().substring(0, 8).toUpperCase();
  }
}