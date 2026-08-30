import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/security/lock_state_provider.dart';
import '../../application/settings/settings_provider.dart';
import 'lock_screen.dart';

/// Sits at the app root. When biometric lock is disabled in settings, the
/// app content is always shown. Otherwise it watches app lifecycle
/// transitions and overlays [LockScreen] whenever the app is locked, so no
/// screen's content (including whatever is mid-navigation) is reachable.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = ref.read(appLockProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        notifier.notifyBackgrounded();
      case AppLifecycleState.resumed:
        notifier.notifyResumed();
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometricLockEnabled = ref.watch(
      settingsProvider.select((s) => s.biometricLockEnabled),
    );
    final isLocked = ref.watch(appLockProvider);

    return Stack(
      children: [
        widget.child,
        if (biometricLockEnabled && isLocked)
          const Positioned.fill(child: LockScreen()),
      ],
    );
  }
}
