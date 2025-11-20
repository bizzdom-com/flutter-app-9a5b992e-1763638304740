import 'package:flutter/material.dart';
import '../models/reward_model.dart';
import '../models/user_model.dart';
import '../models/points_ledger_model.dart';
import '../services/admin_service.dart';
import '../utils/error_handler.dart';

class AdminProvider extends ChangeNotifier {
  List<RewardModel> _rewards = [];
  List<UserModel> _staff = [];
  List<PointsLedgerModel> _recentTransactions = [];
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = false;
  String? _error;

  List<RewardModel> get rewards => _rewards;
  List<UserModel> get staff => _staff;
  List<PointsLedgerModel> get recentTransactions => _recentTransactions;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // REWARDS MANAGEMENT
  Future<void> loadRewards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rewards = await AdminService.getAllRewards();
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReward({
    required String name,
    required String description,
    required int costPoints,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AdminService.createReward(
        name: name,
        description: description,
        costPoints: costPoints,
        imageUrl: imageUrl,
      );
      
      // Reload rewards list
      await loadRewards();
      return true;
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReward({
    required int id,
    required String name,
    required String description,
    required int costPoints,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AdminService.updateReward(
        id: id,
        name: name,
        description: description,
        costPoints: costPoints,
        imageUrl: imageUrl,
      );
      
      // Reload rewards list
      await loadRewards();
      return true;
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReward(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AdminService.deleteReward(id);
      
      // Reload rewards list
      await loadRewards();
      return true;
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // STAFF MANAGEMENT
  Future<void> loadStaff() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _staff = await AdminService.getAllStaff();
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createStaffMember({
    required String name,
    required String email,
    required String role,
    int? locationId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AdminService.createStaffMember(
        name: name,
        email: email,
        role: role,
        locationId: locationId,
      );
      
      // Reload staff list
      await loadStaff();
      return true;
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStaffMember({
    required int userId,
    required String name,
    required String email,
    required String role,
    int? locationId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AdminService.updateStaffMember(
        userId: userId,
        name: name,
        email: email,
        role: role,
        locationId: locationId,
      );
      
      // Reload staff list
      await loadStaff();
      return true;
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStaffMember(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AdminService.deleteStaffMember(userId);
      
      // Reload staff list
      await loadStaff();
      return true;
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // DASHBOARD & ANALYTICS
  Future<void> loadDashboardStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardStats = await AdminService.getDashboardStats();
      _recentTransactions = await AdminService.getRecentTransactions(limit: 10);
    } catch (e) {
      _error = ErrorHandler.getHumanReadableError(e.toString());
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