import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/customer_balance_model.dart';
import '../models/points_ledger_model.dart';
import '../models/coupon_model.dart';
import 'supabase_service.dart';
import '../utils/error_handler.dart';

class StaffService {
  static final SupabaseClient _client = SupabaseService.client;

  static Future<UserModel?> getCustomerByQRCode(String qrCode) async {
    try {
      // QR code format: "customer:userId"
      if (!qrCode.startsWith('customer:')) {
        throw Exception('Invalid customer QR code format');
      }
      
      final userIdString = qrCode.substring(9);
      final userId = int.tryParse(userIdString);
      
      if (userId == null) {
        throw Exception('Invalid customer ID in QR code');
      }

      final userResponse = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .eq('role', 'customer')
          .single();

      return UserModel.fromJson(userResponse);
    } catch (e) {
      throw Exception('Failed to find customer: $e');
    }
  }

  static Future<CustomerBalanceModel?> getCustomerBalance(int userId) async {
    try {
      final response = await _client
          .from('customer_balances')
          .select()
          .eq('user_id', userId)
          .single();

      return CustomerBalanceModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get customer balance: $e');
    }
  }

  static Future<int?> getStaffIdByUserId(int userId) async {
    try {
      final response = await _client
          .from('staff')
          .select('id')
          .eq('user_id', userId)
          .single();

      return response['id'] as int;
    } catch (e) {
      throw Exception('Failed to get staff record: $e');
    }
  }

  static Future<bool> awardPoints({
    required int customerId,
    required int staffId,
    required int points,
    int? locationId,
    String? note,
  }) async {
    try {
      // Get current balance
      final currentBalance = await _client
          .from('customer_balances')
          .select('points_balance')
          .eq('user_id', customerId)
          .single();

      final balance = currentBalance['points_balance'] as int;
      final newBalance = balance + points;

      // Update balance
      await _client
          .from('customer_balances')
          .update({'points_balance': newBalance})
          .eq('user_id', customerId);

      // Record in ledger
      await _client
          .from('points_ledger')
          .insert({
            'user_id': customerId,
            'staff_id': staffId,
            'location_id': locationId,
            'change': points,
            'type': 'earn',
            'note': note ?? 'Points awarded by staff',
          });

      return true;
    } catch (e) {
      throw Exception('Failed to award points: $e');
    }
  }

  static Future<CouponModel?> getCouponByCode(String couponCode) async {
    try {
      final response = await _client
          .from('coupons')
          .select('''
            id, user_id, reward_id, code, status, created_at, redeemed_at,
            reward:rewards (
              id, name, description, image_url, cost_points, created_at, updated_at
            )
          ''')
          .eq('code', couponCode)
          .single();

      return CouponModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to find coupon: $e');
    }
  }

  static Future<bool> redeemCoupon(String couponCode, int staffId) async {
    try {
      final coupon = await getCouponByCode(couponCode);
      
      if (coupon?.status != 'active') {
        throw Exception('Coupon is ${coupon?.status ?? 'not found'}');
      }

      await _client
          .from('coupons')
          .update({
            'status': 'used',
            'redeemed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', coupon!.id);

      return true;
    } catch (e) {
      throw Exception('Failed to redeem coupon: $e');
    }
  }

  static Future<List<PointsLedgerModel>> getStaffHistory(int staffId) async {
    try {
      final response = await _client
          .from('points_ledger')
          .select()
          .eq('staff_id', staffId)
          .order('created_at', ascending: false)
          .limit(50);

      return response
          .map<PointsLedgerModel>((json) => PointsLedgerModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load staff history: $e');
    }
  }
}