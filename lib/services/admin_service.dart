import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reward_model.dart';
import '../models/user_model.dart';
import '../models/points_ledger_model.dart';
import 'supabase_service.dart';

class AdminService {
  static final SupabaseClient _client = SupabaseService.client;

  // REWARDS MANAGEMENT
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

  static Future<RewardModel> createReward({
    required String name,
    required String description,
    required int costPoints,
    String? imageUrl,
  }) async {
    try {
      final response = await _client
          .from('rewards')
          .insert({
            'name': name,
            'description': description,
            'cost_points': costPoints,
            'image_url': imageUrl,
          })
          .select()
          .single();

      return RewardModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create reward: $e');
    }
  }

  static Future<RewardModel> updateReward({
    required int id,
    required String name,
    required String description,
    required int costPoints,
    String? imageUrl,
  }) async {
    try {
      final response = await _client
          .from('rewards')
          .update({
            'name': name,
            'description': description,
            'cost_points': costPoints,
            'image_url': imageUrl,
          })
          .eq('id', id)
          .select()
          .single();

      return RewardModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update reward: $e');
    }
  }

  static Future<bool> deleteReward(int id) async {
    try {
      await _client
          .from('rewards')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      throw Exception('Failed to delete reward: $e');
    }
  }

  // STAFF MANAGEMENT
  static Future<List<UserModel>> getAllStaff() async {
    try {
      final response = await _client
          .from('users')
          .select()
          .inFilter('role', ['staff', 'manager'])
          .order('created_at', ascending: false);

      return response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load staff: $e');
    }
  }

  static Future<UserModel> createStaffMember({
    required String name,
    required String email,
    required String role, // 'staff' or 'manager'
    int? locationId,
  }) async {
    try {
      // First, check if a user with this email already exists
      final existingUserResponse = await _client
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      UserModel user;

      if (existingUserResponse != null) {
        // User already exists, just update their role and name if needed
        user = UserModel.fromJson(existingUserResponse);
        
        // Update the existing user's role and name
        final updatedUserResponse = await _client
            .from('users')
            .update({
              'name': name,
              'role': role,
            })
            .eq('id', user.id)
            .select()
            .single();

        user = UserModel.fromJson(updatedUserResponse);
        
        // Check if staff record already exists
        final existingStaffResponse = await _client
            .from('staff')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();
            
        if (existingStaffResponse == null) {
          // Create staff record since it doesn't exist
          await _client
              .from('staff')
              .insert({
                'user_id': user.id,
                'role': role,
                'location_id': locationId,
              });
        } else {
          // Update existing staff record
          await _client
              .from('staff')
              .update({
                'role': role,
                'location_id': locationId,
              })
              .eq('user_id', user.id);
        }
      } else {
        // User doesn't exist, create new user
        final userResponse = await _client
            .from('users')
            .insert({
              'name': name,
              'email': email,
              'role': role,
            })
            .select()
            .single();

        user = UserModel.fromJson(userResponse);

        // Create staff record
        await _client
            .from('staff')
            .insert({
              'user_id': user.id,
              'role': role,
              'location_id': locationId,
            });
      }

      return user;
    } catch (e) {
      throw Exception('Failed to create staff member: $e');
    }
  }

  static Future<bool> updateStaffMember({
    required int userId,
    required String name,
    required String email,
    required String role,
    int? locationId,
  }) async {
    try {
      // Update user record
      await _client
          .from('users')
          .update({
            'name': name,
            'email': email,
            'role': role,
          })
          .eq('id', userId);

      // Update staff record
      await _client
          .from('staff')
          .update({
            'role': role,
            'location_id': locationId,
          })
          .eq('user_id', userId);

      return true;
    } catch (e) {
      throw Exception('Failed to update staff member: $e');
    }
  }

  static Future<bool> deleteStaffMember(int userId) async {
    try {
      // Delete staff record first (due to foreign key constraint)
      await _client
          .from('staff')
          .delete()
          .eq('user_id', userId);

      // Demote user to customer instead of deleting
      await _client
          .from('users')
          .update({'role': 'customer'})
          .eq('id', userId);

      // Create customer balance if it doesn't exist
      try {
        await _client
            .from('customer_balances')
            .insert({
              'user_id': userId,
              'points_balance': 0,
            });
      } catch (e) {
        // Ignore error if customer balance already exists
        if (!e.toString().contains('duplicate key value')) {
          throw e;
        }
      }

      return true;
    } catch (e) {
      throw Exception('Failed to remove staff member: $e');
    }
  }

  // ANALYTICS & REPORTS
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get total customers
      final customersResponse = await _client
          .from('users')
          .select('id')
          .eq('role', 'customer');

      // Get total points awarded (this month)
      final thisMonth = DateTime.now().subtract(const Duration(days: 30));
      final pointsResponse = await _client
          .from('points_ledger')
          .select('change')
          .eq('type', 'earn')
          .gte('created_at', thisMonth.toIso8601String());

      int totalPointsAwarded = 0;
      for (var record in pointsResponse) {
        totalPointsAwarded += record['change'] as int;
      }

      // Get total rewards redeemed (this month)
      final rewardsResponse = await _client
          .from('points_ledger')
          .select('change')
          .eq('type', 'redeem')
          .gte('created_at', thisMonth.toIso8601String());

      int totalRewardsRedeemed = rewardsResponse.length;
      int totalPointsRedeemed = 0;
      for (var record in rewardsResponse) {
        totalPointsRedeemed += (record['change'] as int).abs();
      }

      // Get active coupons
      final activeCouponsResponse = await _client
          .from('coupons')
          .select('id')
          .eq('status', 'active');

      return {
        'total_customers': customersResponse.length,
        'points_awarded_month': totalPointsAwarded,
        'points_redeemed_month': totalPointsRedeemed,
        'rewards_redeemed_month': totalRewardsRedeemed,
        'active_coupons': activeCouponsResponse.length,
      };
    } catch (e) {
      throw Exception('Failed to load dashboard stats: $e');
    }
  }

  static Future<List<PointsLedgerModel>> getRecentTransactions({int limit = 20}) async {
    try {
      final response = await _client
          .from('points_ledger')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map<PointsLedgerModel>((json) => PointsLedgerModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load recent transactions: $e');
    }
  }
}