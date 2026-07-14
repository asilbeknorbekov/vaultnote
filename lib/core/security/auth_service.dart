import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AuthService {
  final LocalAuthentication _localAuth;
  final SharedPreferences _prefs;

  static const String _authTimeoutKey = 'vaultnote_auth_timeout_mins';
  static const String _lastBackgroundTimeKey = 'vaultnote_last_bg_time';
  
  // Default to locking immediately (0 minutes)
  int get authTimeoutMinutes => _prefs.getInt(_authTimeoutKey) ?? 0;

  AuthService(this._localAuth, this._prefs);

  Future<void> setAuthTimeout(int minutes) async {
    await _prefs.setInt(_authTimeoutKey, minutes);
  }

  void recordBackgroundTime() {
    _prefs.setInt(_lastBackgroundTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  bool shouldRequestAuth() {
    final lastTimeMs = _prefs.getInt(_lastBackgroundTimeKey);
    if (lastTimeMs == null) return true; // First launch

    final lastTime = DateTime.fromMillisecondsSinceEpoch(lastTimeMs);
    final difference = DateTime.now().difference(lastTime).inMinutes;

    return difference >= authTimeoutMinutes;
  }

  Future<bool> authenticate() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!isAvailable) {
        // If device has no security, we can't lock it securely, but we return true to let them in
        return true;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Unlock VaultNote to access your second brain',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/Pattern fallback
        ),
      );
    } on PlatformException catch (e) {
      // Handle errors like no hardware, or user canceled
      return false;
    }
  }
}
