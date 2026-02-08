import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static final SecurityService instance = SecurityService._init();
  
  // Use encrypted secure storage with enhanced options for Android
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,  // Use encrypted shared preferences
      sharedPreferencesName: 'mindnote_secure_prefs',  // Custom name for isolation
      preferencesKeyPrefix: 'mindnote_',  // Prefix for additional isolation
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,  // Device-only access
    ),
  );
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  static const String _pinKey = 'user_pin_hash';
  static const String _biometricsEnabledKey = 'biometrics_enabled';
  static const String _encryptionKeyKey = 'encryption_key';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _apiKeyKey = 'longcat_api_key';

  SecurityService._init();

  // ============ PIN MANAGEMENT ============

  Future<bool> isPinSet() async {
    final pin = await _secureStorage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await _secureStorage.write(key: _pinKey, value: hash);
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secureStorage.read(key: _pinKey);
    if (storedHash == null) return false;
    
    final inputHash = _hashPin(pin);
    return storedHash == inputHash;
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    if (await verifyPin(oldPin)) {
      await setPin(newPin);
      return true;
    }
    return false;
  }

  Future<void> removePin() async {
    await _secureStorage.delete(key: _pinKey);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ============ BIOMETRICS ============

  Future<bool> isBiometricsAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> isBiometricsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricsEnabledKey) ?? false;
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricsEnabledKey, enabled);
  }

  Future<bool> authenticateWithBiometrics({bool skipEnabledCheck = false}) async {
    try {
      if (!skipEnabledCheck) {
        final biometricsEnabled = await isBiometricsEnabled();
        if (!biometricsEnabled) return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Susu',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // ============ ENCRYPTION KEY ============

  Future<String> getEncryptionKey() async {
    String? key = await _secureStorage.read(key: _encryptionKeyKey);
    
    if (key == null) {
      // Generate a new encryption key
      key = _generateEncryptionKey();
      await _secureStorage.write(key: _encryptionKeyKey, value: key);
    }
    
    return key;
  }

  String _generateEncryptionKey() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    final combined = '$timestamp-$random';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ============ FIRST LAUNCH ============

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLaunchKey, false);
  }

  // ============ API KEY MANAGEMENT ============

  Future<void> saveApiKey(String apiKey) async {
    await _secureStorage.write(key: _apiKeyKey, value: apiKey);
  }

  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: _apiKeyKey);
  }

  Future<void> removeApiKey() async {
    await _secureStorage.delete(key: _apiKeyKey);
  }

  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  // ============ CLEAR ALL DATA ============

  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll();
  }
}

// Authentication states
enum AuthState {
  unauthenticated,
  authenticated,
  locked,
}
