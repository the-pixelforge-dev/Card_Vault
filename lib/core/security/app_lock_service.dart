import 'package:local_auth/local_auth.dart';

/// Thin wrapper over `local_auth` for the app's unlock gate.
///
/// [authenticate] allows biometrics OR the device's own PIN/pattern/password
/// (`biometricOnly: false`) so a user without biometrics enrolled — or a
/// device that fails the biometric prompt — can still get in. Some Android
/// OEMs don't reliably fall back to the device credential from within the
/// plugin's own dialog, so the lock screen also exposes an explicit "Use
/// device PIN" retry that just calls [authenticate] again; this service
/// never assumes the first attempt is the only chance.
class AppLockService {
  AppLockService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  Future<bool> canCheckSupport() async {
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    final canCheckBiometrics = await _localAuth.canCheckBiometrics;
    return isDeviceSupported || canCheckBiometrics;
  }

  Future<bool> authenticate({String reason = 'Unlock Card Vault'}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on Exception {
      return false;
    }
  }
}
