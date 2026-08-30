import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/security/lock_state_provider.dart';
import '../../application/settings/haptics_provider.dart';
import 'reset_app_screen.dart';
import 'widgets/pin_dots.dart';
import 'widgets/pin_keypad.dart';

const _pinLength = 6;

/// A re-authentication checkpoint for sensitive Settings actions —
/// changing the PIN, turning App Lock off, or flipping the biometric
/// shortcut on/off. Without this, anyone holding an already-unlocked phone
/// could silently disable or take over the app's security, which defeats
/// the point of having a PIN at all.
///
/// Pops `true` once the current PIN is verified; `false`/null if the user
/// backs out. Carries the same "Forgot PIN?" reset escape hatch as the
/// main lock screen so a legitimate owner is never stuck.
class VerifyPinScreen extends ConsumerStatefulWidget {
  const VerifyPinScreen({super.key, this.reason});

  /// Optional context shown above the PIN pad (e.g. "to change your PIN").
  final String? reason;

  @override
  ConsumerState<VerifyPinScreen> createState() => _VerifyPinScreenState();
}

class _VerifyPinScreenState extends ConsumerState<VerifyPinScreen> {
  String _entry = '';
  String? _error;

  void _onDigit(String digit) {
    if (_entry.length >= _pinLength) return;
    setState(() {
      _entry += digit;
      _error = null;
    });
    if (_entry.length == _pinLength) {
      _submit();
    }
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _submit() async {
    final pin = _entry;
    final success = await ref.read(pinStoreProvider).verifyPin(pin);
    if (!mounted) return;

    if (success) {
      ref.read(hapticsServiceProvider).mediumImpact();
      Navigator.of(context).pop(true);
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

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm PIN')),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Enter your current PIN'
              '${widget.reason != null ? ' ${widget.reason}' : ''}',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 20,
              child: Text(
                _error ?? ' ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: 24),
            PinDots(length: _pinLength, filled: _entry.length),
            const SizedBox(height: 32),
            PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
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
