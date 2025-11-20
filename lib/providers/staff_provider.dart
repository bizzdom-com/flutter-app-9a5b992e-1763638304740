import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/customer_balance_model.dart';
import '../models/coupon_model.dart';
import '../models/points_ledger_model.dart';
import '../services/staff_service.dart';
import '../utils/error_handler.dart';

class StaffProvider extends ChangeNotifier {
  UserModel? _scannedCustomer;
  CustomerBalanceModel? _customerBalance;
  CouponModel? _scannedCoupon;
  List<PointsLedgerModel> _staffHistory = [];
  bool _isLoading = false;
  String? _error;

  UserModel? get scannedCustomer => _scannedCustomer;
  CustomerBalanceModel? get customerBalance => _customerBalance;
  CouponModel? get scannedCoupon => _scannedCoupon;
  List<PointsLedgerModel> get staffHistory => _staffHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> scanCustomerQR(String qrCode) async {
    _isLoading = true;
    _error = null;
    _scannedCustomer = null;
    _customerBalance = null;
    notifyListeners();

    try {
      _scannedCustomer = await StaffService.getCustomerByQRCode(qrCode);
      if (_scannedCustomer != null) {
        _customerBalance = await StaffService.getCustomerBalance(_scannedCustomer!.id);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> awardPoints({
    required int staffId,
    required int points,
    int? locationId,
    String? note,
  }) async {
    if (_scannedCustomer == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await StaffService.awardPoints(
        customerId: _scannedCustomer!.id,
        staffId: staffId,
        points: points,
        locationId: locationId,
        note: note,
      );

      if (success) {
        // Refresh customer balance
        _customerBalance = await StaffService.getCustomerBalance(_scannedCustomer!.id);
      }

      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> scanCouponQR(String qrCode) async {
    _isLoading = true;
    _error = null;
    _scannedCoupon = null;
    notifyListeners();

    try {
      // For coupon QR codes, we expect the format "coupon:couponCode"
      String couponCode;
      if (qrCode.startsWith('coupon:')) {
        couponCode = qrCode.substring(7);
      } else {
        // Assume the QR code is just the coupon code
        couponCode = qrCode;
      }

      _scannedCoupon = await StaffService.getCouponByCode(couponCode);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> redeemCoupon(int staffId) async {
    if (_scannedCoupon == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await StaffService.redeemCoupon(_scannedCoupon!.code, staffId);
      if (success) {
        // Refresh coupon status
        _scannedCoupon = await StaffService.getCouponByCode(_scannedCoupon!.code);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStaffHistory(int staffId) async {
    try {
      _staffHistory = await StaffService.getStaffHistory(staffId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearScannedData() {
    _scannedCustomer = null;
    _customerBalance = null;
    _scannedCoupon = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}