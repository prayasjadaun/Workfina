import 'package:flutter/material.dart';
import 'package:workfina/services/api_service.dart';
import 'dart:io';

class CandidateController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _candidateProfile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get candidateProfile => _candidateProfile;

  Future<bool> registerCandidate({
    required String fullName,
    required String phone,
    required int age,
    required String role,
    required int experienceYears,
    double? currentCtc,
    double? expectedCtc,
    String? religion,
    String country = 'India',
    required String state,
    required String city,
    required String education,
    required String skills,
    File? resumeFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.registerCandidate(
        fullName: fullName,
        phone: phone,
        age: age,
        role: role,
        experienceYears: experienceYears,
        currentCtc: currentCtc,
        expectedCtc: expectedCtc,
        religion: religion,
        country: country,
        state: state,
        city: city,
        education: education,
        skills: skills,
        resumeFile: resumeFile,
      );

      if (response.containsKey('error')) {
        _error = response['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        _candidateProfile = response;
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

  Future<bool> checkProfileExists() async {
    try {
      final response = await ApiService.getCandidateProfile();

      if (response.containsKey('error')) {
        return false;
      }

      _candidateProfile = response;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
