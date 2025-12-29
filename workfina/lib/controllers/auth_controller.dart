import 'package:flutter/material.dart';
import 'package:workfina/services/api_service.dart';

class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user;
  String? _tempEmail;
  bool _isOTPVerified = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  String? get tempEmail => _tempEmail;
  bool get isOTPVerified => _isOTPVerified;

  void setTempEmail(String email) {
    _tempEmail = email;
    notifyListeners();
  }

  Future<bool> sendOTP(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.sendOTP(email);
      if (response.containsKey('message')) {
        _tempEmail = email;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = _getUserFriendlyError(response['error']);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getNetworkErrorMessage();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOTPOnly({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.verifyOTPOnly(email: email, otp: otp);

      if (response.containsKey('message')) {
        _isOTPVerified = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = _getUserFriendlyError(response['error']);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getNetworkErrorMessage();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createAccount({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.createAccount(
        email: email,
        username: username,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (response.containsKey('user')) {
        _user = response['user'];
        _user!['username'] = username;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = _getUserFriendlyError(response['error']);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getNetworkErrorMessage();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOTP({
    required String email,
    required String otp,
    required String password,
    required String username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.verifyOTP(
        email: email,
        otp: otp,
        password: password,
        username: username,
      );

      if (response.containsKey('user')) {
        _user = response['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error'] ?? 'Invalid OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);

      if (response.containsKey('user')) {
        _user = response['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = _getUserFriendlyError(response['error']);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getNetworkErrorMessage();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logoutWithToken() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final refreshToken = await ApiService.getRefreshToken();
      if (refreshToken != null) {
        await ApiService.logoutWithToken(refreshToken);
      }
      await logout();
    } catch (e) {
      _error = 'Logout failed. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserRole(String role) async {
    try {
      await ApiService.updateUserRole(role);
      if (_user != null) {
        _user!['role'] = role;
        await ApiService.saveUserData(_user!);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update role. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final refreshToken = await ApiService.getRefreshToken();
      if (refreshToken != null) {
        final accessToken = await ApiService.getAccessToken();
        if (accessToken == null) {
          await ApiService.refreshToken();
        }
        _user = await ApiService.getUserData();

        // Validate user data exists and has role
        if (_user == null || _user!['role'] == null) {
          await logout();
        }

        notifyListeners();
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    _tempEmail = null;
    _error = null;
    _isOTPVerified = false;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  String _getUserFriendlyError(String? serverError) {
    if (serverError == null) return 'Something went wrong. Please try again.';

    final error = serverError.toLowerCase();

    // Username specific errors
    if (error.contains('username') &&
        (error.contains('already') ||
            error.contains('taken') ||
            error.contains('exists'))) {
      return 'This username is already taken. Please choose a different one.';
    }

    // Email specific errors
    if (error.contains('email') &&
        error.contains('already') &&
        error.contains('exists')) {
      return 'This email is already registered. Please login instead.';
    }
    if (error.contains('email') &&
        error.contains('not') &&
        error.contains('registered')) {
      return 'This email is not registered. Please sign up first.';
    }

    // Authentication errors
    if (error.contains('invalid') && error.contains('credentials')) {
      return 'Invalid email or password. Please check and try again.';
    }
    if (error.contains('user') &&
        error.contains('not') &&
        error.contains('found')) {
      return 'Account not found. Please check your email or sign up.';
    }
    if (error.contains('password') && error.contains('incorrect')) {
      return 'Incorrect password. Please try again.';
    }

    // OTP errors
    if (error.contains('otp') && error.contains('expired')) {
      return 'OTP has expired. Please request a new one.';
    }
    if (error.contains('otp') && error.contains('invalid')) {
      return 'Invalid OTP. Please check and try again.';
    }
    if (error.contains('otp') &&
        error.contains('not') &&
        error.contains('found')) {
      return 'OTP not found. Please request a new one.';
    }

    // Password validation errors
    if (error.contains('password') && error.contains('match')) {
      return 'Passwords do not match. Please try again.';
    }

    // Server/validation errors
    if (error.contains('validation') || error.contains('required')) {
      return 'Please fill in all required fields correctly.';
    }
    if (error.contains('server') && error.contains('error')) {
      return 'Server error. Please try again later.';
    }

    // Return original error if no pattern matches
    return serverError;
  }

  String _getNetworkErrorMessage() {
    return 'Unable to connect. Please check your internet connection and try again.';
  }
}
