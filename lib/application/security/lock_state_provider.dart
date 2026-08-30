import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/security/app_lock_service.dart';
import '../settings/settings_provider.dart';

part 'lock_state_provider.g.dart';

@Riverpod(keepAlive: true)
AppLockService appLockService(Ref ref) => AppLockService();

/// Whether the app-wide lock overlay should currently be shown.
///
/// Starts locked; the first successful [unlock] call clears it. Getting
/// backgrounded and resumed past the configured auto-lock timeout re-locks
/// it (see [notifyBackgrounded]/[notifyResumed], driven by a
/// `WidgetsBindingObserver` at the app root).
@Riverpod(keepAlive: true)
class AppLock extends _$AppLock {
  DateTime? _backgroundedAt;

  @override
  bool build() => true;

  Future<bool> unlock() async {
    final success = await ref.read(appLockServiceProvider).authenticate();
    if (success) state = false;
    return success;
  }

  void lock() => state = true;

  void notifyBackgrounded() {
    _backgroundedAt = DateTime.now();
  }

  /// Call when the app returns to the foreground. Locks again if biometric
  /// lock is enabled and enough time has passed while backgrounded.
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
