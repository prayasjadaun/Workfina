import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:workfina/models/app_version_model.dart';
import 'package:workfina/services/api_service.dart';

class AppVersionController extends ChangeNotifier {
  AppVersionModel? _versionInfo;
  bool _isLoading = false;
  bool _hasChecked = false;
  String? _error;

  AppVersionModel? get versionInfo => _versionInfo;
  bool get isLoading => _isLoading;
  bool get hasChecked => _hasChecked;
  String? get error => _error;

  /// Check if update is available
  bool get hasUpdate => _versionInfo?.updateAvailable ?? false;

  /// Check if update is mandatory (user cannot skip)
  bool get isMandatory => _versionInfo?.isMandatory ?? false;

  /// Check if it's a force update
  bool get isForceUpdate => _versionInfo?.forceUpdate ?? false;

  /// Check if user can dismiss the update dialog
  bool get canDismiss => _versionInfo?.canDismiss ?? true;

  /// Get current platform string
  String get _platform {
    if (Platform.isAndroid) return 'ANDROID';
    if (Platform.isIOS) return 'IOS';
    return 'UNKNOWN';
  }

  /// Check app version against server
  Future<void> checkAppVersion() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (kDebugMode) {
        print('[DEBUG] Current App Version: $currentVersion');
        print('[DEBUG] Platform: $_platform');
      }

      // Call API to check version
      final result = await ApiService.checkAppVersion(
        currentVersion: currentVersion,
        platform: _platform,
      );

      _versionInfo = result;
      _hasChecked = true;

      if (kDebugMode) {
        print('[DEBUG] Version Info: ${result?.toJson()}');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('[DEBUG] Version Check Error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset version check state
  void reset() {
    _versionInfo = null;
    _hasChecked = false;
    _error = null;
    notifyListeners();
  }
}
