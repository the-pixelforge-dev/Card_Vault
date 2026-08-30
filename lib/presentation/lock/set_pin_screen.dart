import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/security/lock_state_provider.dart';
import 'widgets/pin_dots.dart';
import 'widgets/pin_keypad.dart';

const _pinLength = 6;

/// Two-step create/confirm flow for the app PIN. Pops `true` once the PIN
/// is saved, `false`/null if the user backs out.
class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key});

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  String _firstEntry = '';
  String _currentEntry = '';
  bool _confirming = false;
  String? _error;

  void _onDigit(String digit) {
    if (_currentEntry.length >= _pinLength) return;
    setState(() {
      _currentEntry += digit;
      _error = null;
    });
    if (_currentEntry.length == _pinLength) {
      _onEntryComplete();
    }
  }

  void _onBackspace() {
    if (_currentEntry.isEmpty) return;
    setState(() => _currentEntry = _currentEntry.substring(
      0,
      _currentEntry.length - 1,
    ));
  }

  Future<void> _onEntryComplete() async {
    if (!_confirming) {
      setState(() {
        _firstEntry = _currentEntry;
        _currentEntry = '';
        _confirming = true;
      });
      return;
    }

    if (_currentEntry == _firstEntry) {
      HapticFeedback.mediumImpact();
      await ref.read(appLockProvider.notifier).setPin(_currentEntry);
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _error = "PINs didn't match. Start again.";
      _firstEntry = '';
      _currentEntry = '';
      _confirming = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Set App PIN')),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _confirming ? 'Confirm your PIN' : 'Create a $_pinLength-digit PIN',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'This unlocks Card Vault even without biometrics.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _error != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            PinDots(length: _pinLength, filled: _currentEntry.length),
            const SizedBox(height: 40),
            PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
          ],
        ),
      ),
    );
  }
}
