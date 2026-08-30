import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/security/app_lock_service.dart';
import '../../core/security/pin_store.dart';
import '../settings/settings_provider.dart';

part 'lock_state_provider.g.dart';

@Riverpod(keepAlive: true)
AppLockService appLockService(Ref ref) => AppLockService();

@Riverpod(keepAlive: true)
PinStore pinStore(Ref ref) => PinStore();

/// Whether an app PIN has been configured at all — the guaranteed unlock
/// method. Re-read after [AppLock.setPin]/[AppLock.clearPin] via
/// [Ref.invalidate].
@Riverpod(keepAlive: true)
Future<bool> hasPin(Ref ref) => ref.watch(pinStoreProvider).hasPin();

@Riverpod(keepAlive: true)
Future<bool> isBiometricAvailable(Ref ref) =>
    ref.watch(appLockServiceProvider).isBiometricAvailable();

/// Whether the app-wide lock overlay should currently be shown.
///
/// Starts locked; a successful [unlockWithPin] or [unlockWithBiometric]
/// call clears it. Getting backgrounded and resumed past the configured
/// auto-lock timeout re-locks it (see [notifyBackgrounded]/[notifyResumed],
/// driven by a `WidgetsBindingObserver` at the app root).
///
/// The PIN is always the guaranteed fallback — biometrics are only ever an
/// optional shortcut layered on top — so there is no configuration that can
/// strand a user with no way to unlock short of the explicit "reset app"
/// escape hatch in [LockScreen].
@Riverpod(keepAlive: true)
class AppLock extends _$AppLock {
  DateTime? _backgroundedAt;

  @override
  bool build() => true;

  Future<bool> unlockWithPin(String pin) async {
    final success = await ref.read(pinStoreProvider).verifyPin(pin);
    if (success) state = false;
    return success;
  }

  Future<bool> unlockWithBiometric() async {
    final success = await ref
        .read(appLockServiceProvider)
        .authenticateBiometric();
    if (success) state = false;
    return success;
  }

  Future<void> setPin(String pin) async {
    await ref.read(pinStoreProvider).setPin(pin);
    ref.invalidate(hasPinProvider);
  }

  Future<void> clearPin() async {
    await ref.read(pinStoreProvider).clear();
    ref.invalidate(hasPinProvider);
  }

  void lock() => state = true;

  void notifyBackgrounded() {
    // Showing the native biometric prompt itself briefly sends the app
    // through inactive/paused and back (Android treats that system
    // overlay as a lifecycle transition) — while already locked, that
    // blip must not overwrite the timestamp used to decide whether to
    // re-lock, or a correct-PIN/successful-biometric unlock gets
    // immediately re-locked by its own unlock attempt (most visible with
    // "Immediately", where any elapsed time at all triggers a re-lock).
    if (state) return;
    _backgroundedAt = DateTime.now();
  }

  /// Call when the app returns to the foreground. Locks again if app lock
  /// is enabled and enough time has passed while backgrounded.
  void notifyResumed() {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt == null || state) return;

    final settings = ref.read(settingsProvider);
    if (!settings.biometricLockEnabled) return;

    final elapsedSeconds = DateTime.now().difference(backgroundedAt).inSeconds;
    if (elapsedSeconds >= settings.autoLockAfterSeconds) {
      lock();
    }
  }
}
