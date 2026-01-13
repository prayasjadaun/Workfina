import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:workfina/services/api_service.dart';

class RecruiterController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _hrProfile;
  List<dynamic> _candidates = [];
  Map<String, dynamic>? _wallet;
  List<dynamic> _transactions = [];
  Set<String> _unlockedCandidateIds = {};
  Map<String, dynamic>? _pagination;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get hrProfile => _hrProfile;
  List<Map<String, dynamic>> get candidates =>
      _candidates.cast<Map<String, dynamic>>();
  Map<String, dynamic>? get wallet => _wallet;
  List<dynamic> get transactions => _transactions;
  Set<String> get unlockedCandidateIds => _unlockedCandidateIds;
  Map<String, dynamic>? get pagination => _pagination;
  int totalCandidatesCount = 0;
  List<Map<String, dynamic>> _unlockedCandidates = [];
  List<Map<String, dynamic>> get unlockedCandidates => _unlockedCandidates;

  bool isCandidateUnlocked(String candidateId) {
    return _unlockedCandidateIds.contains(candidateId);
  }

  Future<bool> registerHR({
    required String fullName, // Ã¢Å“â€¦ ADD THIS LINE
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
        fullName: fullName, // Ã¢Å“â€¦ ADD THIS LINE
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
        _hrProfile = response;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        _error =
            'Unable to connect to server. Please check your internet connection.';
      } else {
        _error = 'Network error. Please try again.';
      }
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    } catch (e) {
      _error = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<bool> loadCandidates({
    String? role,
    int? minExperience,
    int? maxExperience,
    String? city,
    String? state,
    String? country,
    String? religion,
    String? skills,
    String? name,
    String? education,
    int page = 1,
    int pageSize = 20,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final response = await ApiService.getFilteredCandidates(
        role: role,
        minExperience: minExperience,
        maxExperience: maxExperience,
        city: city,
        state: state,
        country: country,
        religion: religion,
        skills: skills,
        name: name,
        education: education,
        page: page,
        pageSize: pageSize,
      );

      if (response.containsKey('error')) {
        _error = response['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        if (loadMore) {
          _candidates.addAll(response['candidates']);
        } else {
          _candidates = response['candidates'];
        }
        _pagination = response['pagination'];
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

  Future<Map<String, dynamic>?> unlockCandidate(String candidateId) async {
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

        // Update wallet balance immediately
        if (response.containsKey('remaining_balance')) {
          if (_wallet != null) {
            _wallet!['balance'] = response['remaining_balance'];
          }
        }

        // Update hrProfile total_spent immediately
        if (response.containsKey('credits_used')) {
          if (_hrProfile != null) {
            final currentSpent = _hrProfile!['total_spent'] ?? 0;
            _hrProfile!['total_spent'] =
                currentSpent + response['credits_used'];
          }
        }

        // Update the candidate in the candidates list with full data
        final candidateData = response['candidate'];
        final index = _candidates.indexWhere((c) => c['id'] == candidateId);
        if (index != -1) {
          _candidates[index] = candidateData;
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
        // Update wallet balance immediately
        if (response.containsKey('new_balance')) {
          if (_wallet != null) {
            _wallet!['balance'] = response['new_balance'];
          }
        }

        // Refresh transactions to show new recharge
        await loadTransactions();

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
        final List<dynamic> data = response['unlocked_candidates'] ?? [];

        _unlockedCandidates = data.cast<Map<String, dynamic>>();

        _unlockedCandidateIds = _unlockedCandidates
            .map((c) => c['id'].toString())
            .toSet();

        notifyListeners();
      }
    } catch (e) {
      // silent fail
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
