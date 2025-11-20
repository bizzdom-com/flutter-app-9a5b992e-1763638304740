import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/customer_balance_model.dart';
import 'supabase_service.dart';

class AuthService {
  static final SupabaseClient _client = SupabaseService.client;

  static Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
    String role = 'customer',
  }) async {
    try {
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        final userResponse = await _client
            .from('users')
            .insert({
              'email': email,
              'name': name,
              'role': role,
            })
            .select()
            .single();

        final user = UserModel.fromJson(userResponse);

        await _client
            .from('customer_balances')
            .insert({
              'user_id': user.id,
              'points_balance': 0,
            });

        return user;
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
    return null;
  }

  static Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userResponse = await _client
          .from('users')
          .select()
          .eq('email', email)
          .single();

      return UserModel.fromJson(userResponse);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  static Future<void> logout() async {
    await _client.auth.signOut();
  }

  static Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://bizzdom.com/auth/reset-password.html',
      );
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  static Future<void> updatePassword({
    required String newPassword,
  }) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  static Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final userResponse = await _client
          .from('users')
          .select()
          .eq('email', user.email!)
          .single();

      return UserModel.fromJson(userResponse);
    } catch (e) {
      return null;
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
      return null;
    }
  }
}