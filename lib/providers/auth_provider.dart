import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/customer_balance_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../utils/error_handler.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  CustomerBalanceModel? _customerBalance;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  CustomerBalanceModel? get customerBalance => _customerBalance;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (SupabaseService.isLoggedIn) {
        _user = await AuthService.getCurrentUser();
        if (_user != null && _user!.isCustomer) {
          _customerBalance = await AuthService.getCustomerBalance(_user!.id);
        }
      }
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.register(
        email: email,
        password: password,
        name: name,
      );
      
      if (_user != null) {
        _customerBalance = await AuthService.getCustomerBalance(_user!.id);
        return true;
      }
      return false;
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.login(
        email: email,
        password: password,
      );
      
      if (_user != null && _user!.isCustomer) {
        _customerBalance = await AuthService.getCustomerBalance(_user!.id);
      }
      return _user != null;
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _customerBalance = null;
    _error = null;
    notifyListeners();
  }

  Future<void> refreshBalance() async {
    if (_user != null && _user!.isCustomer) {
      try {
        _customerBalance = await AuthService.getCustomerBalance(_user!.id);
        notifyListeners();
      } catch (e) {
        _error = ErrorHandler.getHumanReadableError(e.toString());
        notifyListeners();
      }
    }
  }

  Future<bool> sendPasswordResetEmail({
    required String email,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword({
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.updatePassword(newPassword: newPassword);
      return true;
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}