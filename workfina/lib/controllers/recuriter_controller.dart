import 'package:flutter/material.dart';
import 'package:workfina/services/api_service.dart';

class RecruiterController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _hrProfile;
  List<dynamic> _candidates = [];
  Map<String, dynamic>? _wallet;
  List<dynamic> _transactions = [];
  Set<int> _unlockedCandidateIds = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get hrProfile => _hrProfile;
  List<dynamic> get candidates => _candidates;
  Map<String, dynamic>? get wallet => _wallet;
  List<dynamic> get transactions => _transactions;
  Set<int> get unlockedCandidateIds => _unlockedCandidateIds;

  bool isCandidateUnlocked(int candidateId) {
    return _unlockedCandidateIds.contains(candidateId);
  }

  Future<bool> registerHR({
    required String companyName,
    required String designation,
    required String phone,
    String? companyWebsite,
    required String companySize,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.registerRecruiter(
        companyName: companyName,
        designation: designation,
        phone: phone,
        companyWebsite: companyWebsite,
        companySize: companySize,
      );

      if (response.containsKey('error')) {
        _error = response['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        _hrProfile = response;
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

  Future<bool> loadHRProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getRecruiterProfile();

      if (response.containsKey('error')) {
        _error = response['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        _hrProfile = response['profile'];
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

  Future<bool> loadCandidates({
    String? role,
    int? minExperience,
    int? maxExperience,
    String? city,
    String? state,
    String? religion,
    String? skills,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getCandidatesList(
        role: role,
        minExperience: minExperience,
        maxExperience: maxExperience,
        city: city,
        state: state,
        religion: religion,
        skills: skills,
      );

      if (response.containsKey('error')) {
        _error = response['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        _candidates = response['candidates'];
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

  Future<Map<String, dynamic>?> unlockCandidate(int candidateId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.unlockCandidate(candidateId);

      if (response.containsKey('error')) {
        _error = response['error'];
        _isLoading = false;
        notifyListeners();
        return null;
      } else {
        // Add to unlocked set
        _unlockedCandidateIds.add(candidateId);

        // Update wallet balance if provided
        if (response.containsKey('remaining_balance')) {
          if (_wallet != null) {
            _wallet!['balance'] = response['remaining_balance'];
          }
        }

        _isLoading = false;
        notifyListeners();

        return {
          'candidate': response['candidate'],
          'already_unlocked': response['already_unlocked'] ?? false,
          'credits_used': response['credits_used'],
          'message': response['message'],
        };
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

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

Future<void> loadUnlockedCandidates() async {
  try {
    final response = await ApiService.getUnlockedCandidates();
    if (!response.containsKey('error')) {
      final List<int> unlockedIds = List<int>.from(
        response['unlocked_candidate_ids'] ?? [],
      );
      _unlockedCandidateIds.addAll(unlockedIds);
      notifyListeners();
    }
  } catch (e) {
    // Handle error silently
  }
}

  int get walletBalance => _wallet?['balance'] ?? 0;

  bool canUnlockCandidate({int requiredCredits = 10}) {
    return walletBalance >= requiredCredits;
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
