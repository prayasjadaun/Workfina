import 'package:flutter/material.dart';
import 'package:workfina/services/api_service.dart';

class WalletController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _wallet;
  List<dynamic> _transactions = [];
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get wallet => _wallet;
  List<dynamic> get transactions => _transactions;

  int get balance => _wallet?['balance'] ?? 0;
  String get walletId => _wallet?['id']?.toString() ?? '';

  Future<bool> loadWalletBalance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getWalletBalance();

      if (response.containsKey('error')) {
        _error = response['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        _wallet = response['wallet'];
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rechargeWallet({
    required int credits,
    String? paymentReference,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.rechargeWallet(
        credits: credits,
        paymentReference: paymentReference,
      );

      if (response.containsKey('error')) {
        _error = response['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        await loadWalletBalance(); // Refresh wallet data
        return true;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getWalletTransactions();

      if (response.containsKey('error')) {
        _error = response['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        _transactions = response['transactions'];
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deductCredits(int credits, String action) async {
    if (balance < credits) {
      _error = 'Insufficient credits. Please recharge your wallet.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // This will be handled by unlock candidate API which deducts credits
      // This method is for UI validation
      _wallet!['balance'] = balance - credits;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to process transaction.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool canUnlockCandidate({int requiredCredits = 10}) {
    return balance >= requiredCredits;
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _wallet = null;
    _transactions = [];
    notifyListeners();
  }
}