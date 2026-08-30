import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/security/lock_state_provider.dart';
import '../../application/settings/haptics_provider.dart';
import '../../application/settings/settings_provider.dart';
import 'reset_app_screen.dart';
import 'widgets/pin_dots.dart';
import 'widgets/pin_keypad.dart';

const _pinLength = 6;

/// Always shows a PIN pad — the app's guaranteed unlock method — and, only
/// when the user opted into it in Settings and the device actually
/// supports it, offers a biometric shortcut on top. There is no
/// configuration in which a user can be shown this screen with no way
/// forward: PIN entry always works, and "Forgot PIN?" is always visible.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _entry = '';
  bool _authenticatingBiometric = false;
  String? _error;
  bool _triedAutoBiometric = false;

  Future<void> _tryBiometric() async {
    if (_authenticatingBiometric) return;
    setState(() {
      _authenticatingBiometric = true;
      _error = null;
    });

    final success = await ref.read(appLockProvider.notifier).unlockWithBiometric();

    if (!mounted) return;
    setState(() => _authenticatingBiometric = false);
    if (!success) {
      setState(() => _error = 'Biometric authentication failed.');
    }
  }

  void _onDigit(String digit) {
    if (_entry.length >= _pinLength) return;
    setState(() {
      _entry += digit;
      _error = null;
    });
    if (_entry.length == _pinLength) {
      _submitPin();
    }
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _submitPin() async {
    final pin = _entry;
    final success = await ref.read(appLockProvider.notifier).unlockWithPin(pin);
    if (!mounted) return;

    if (success) {
      ref.read(hapticsServiceProvider).mediumImpact();
      return;
    }

    ref.read(hapticsServiceProvider).heavyImpact();
    setState(() {
      _entry = '';
      _error = 'Incorrect PIN.';
    });
  }

  void _openResetFlow() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ResetAppScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final biometricUnlockEnabled = ref.watch(
      settingsProvider.select((s) => s.biometricUnlockEnabled),
    );
    final biometricAvailableAsync = ref.watch(isBiometricAvailableProvider);
    final showBiometric =
        biometricUnlockEnabled && (biometricAvailableAsync.value ?? false);

    if (showBiometric && !_triedAutoBiometric) {
      _triedAutoBiometric = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Card Vault is locked', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 20,
              child: Text(
                _error ?? 'Enter your PIN',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _error != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 28),
            PinDots(length: _pinLength, filled: _entry.length),
            const SizedBox(height: 32),
            PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
            if (showBiometric) ...[
              const SizedBox(height: 12),
              IconButton.filledTonal(
                onPressed: _authenticatingBiometric ? null : _tryBiometric,
                icon: _authenticatingBiometric
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.fingerprint),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: _openResetFlow,
              child: const Text('Forgot PIN?'),
            ),
          ],
        ),
      ),
    );
  }
}
