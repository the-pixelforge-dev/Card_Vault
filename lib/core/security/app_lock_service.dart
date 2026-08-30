import 'package:local_auth/local_auth.dart';

/// Thin wrapper over `local_auth`, used strictly for the optional biometric
/// convenience layer — the app's own PIN (see `pin_store.dart`) is always
/// the guaranteed unlock method, so this never needs to fall back to the
/// device's OS-level credential UI.
class AppLockService {
  AppLockService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  /// True only if the device has biometric hardware AND at least one
  /// biometric is actually enrolled — offering a biometric toggle when
  /// neither is true just leads to a confusing dead end.
  Future<bool> isBiometricAvailable() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } on Exception {
      return false;
    }
  }

  Future<bool> authenticateBiometric({
    String reason = 'Unlock Card Vault',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
    } on Exception {
      return false;
    }
  }
}
