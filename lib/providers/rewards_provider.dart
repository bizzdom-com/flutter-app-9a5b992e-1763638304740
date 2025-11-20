import 'package:flutter/material.dart';
import '../models/reward_model.dart';
import '../models/coupon_model.dart';
import '../models/points_ledger_model.dart';
import '../services/rewards_service.dart';

class RewardsProvider extends ChangeNotifier {
  List<RewardModel> _rewards = [];
  List<CouponModel> _userCoupons = [];
  List<PointsLedgerModel> _userHistory = [];
  bool _isLoading = false;
  String? _error;

  List<RewardModel> get rewards => _rewards;
  List<CouponModel> get userCoupons => _userCoupons;
  List<PointsLedgerModel> get userHistory => _userHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRewards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rewards = await RewardsService.getAllRewards();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserCoupons(int userId) async {
    try {
      _userCoupons = await RewardsService.getUserCoupons(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUserHistory(int userId) async {
    try {
      _userHistory = await RewardsService.getUserHistory(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> redeemReward({
    required int userId,
    required int rewardId,
    required int costPoints,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final coupon = await RewardsService.redeemReward(
        userId: userId,
        rewardId: rewardId,
        costPoints: costPoints,
      );

      if (coupon != null) {
        await loadUserCoupons(userId);
        await loadUserHistory(userId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
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

  List<CouponModel> get activeCoupons => 
      _userCoupons.where((coupon) => coupon.isActive).toList();
  
  List<CouponModel> get usedCoupons => 
      _userCoupons.where((coupon) => coupon.isUsed).toList();
  
  List<CouponModel> get expiredCoupons => 
      _userCoupons.where((coupon) => coupon.isExpired).toList();
}