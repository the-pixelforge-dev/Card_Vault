import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/settings/haptics_provider.dart';
import '../../lock/widgets/pin_dots.dart';
import '../../lock/widgets/pin_keypad.dart';

const _minPasscodeLength = 4;
const _maxPasscodeLength = 10;

enum PasscodeEntryMode {
  /// Two-step create/confirm flow, used when protecting a new export.
  create,

  /// Single entry, used when decrypting an existing export on import.
  enter,
}

/// A numeric-only passcode entry screen (4-10 digits) for the encrypted
/// export/import flow — deliberately a short numeric code rather than a
/// free-form passphrase, matching the same keypad UI as the app-lock PIN.
/// Pops the entered passcode string, or null if the user backs out.
class PasscodeEntryScreen extends ConsumerStatefulWidget {
  const PasscodeEntryScreen({super.key, required this.mode});

  final PasscodeEntryMode mode;

  @override
  ConsumerState<PasscodeEntryScreen> createState() =>
      _PasscodeEntryScreenState();
}

class _PasscodeEntryScreenState extends ConsumerState<PasscodeEntryScreen> {
  String _entry = '';
  String _firstEntry = '';
  bool _confirming = false;
  String? _error;

  bool get _isCreating => widget.mode == PasscodeEntryMode.create;
  bool get _canConfirm =>
      _entry.length >= _minPasscodeLength &&
      _entry.length <= _maxPasscodeLength;

  void _onDigit(String digit) {
    if (_entry.length >= _maxPasscodeLength) return;
    setState(() {
      _entry += digit;
      _error = null;
    });
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  void _onConfirm() {
    if (!_canConfirm) return;

    if (_isCreating && !_confirming) {
      ref.read(hapticsServiceProvider).selectionClick();
      setState(() {
        _firstEntry = _entry;
        _entry = '';
        _confirming = true;
      });
      return;
    }

    if (_isCreating && _confirming) {
      if (_entry != _firstEntry) {
        ref.read(hapticsServiceProvider).heavyImpact();
        setState(() {
          _error = "Passcodes didn't match. Start again.";
          _firstEntry = '';
          _entry = '';
          _confirming = false;
        });
        return;
      }
    }

    ref.read(hapticsServiceProvider).mediumImpact();
    Navigator.of(context).pop(_entry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String title;
    final String subtitle;
    if (!_isCreating) {
      title = 'Enter Passcode';
      subtitle = 'Enter the 4-10 digit passcode for this backup.';
    } else if (_confirming) {
      title = 'Confirm Passcode';
      subtitle = 'Enter it once more to confirm.';
    } else {
      title = 'Set Export Passcode';
      subtitle = 'Choose a 4-10 digit passcode to protect this backup.';
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isCreating ? 'Export Passcode' : 'Import')),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error ?? subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _error != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 28),
            PinDots(length: _maxPasscodeLength, filled: _entry.length),
            const SizedBox(height: 32),
            PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _canConfirm ? _onConfirm : null,
              child: Text(
                _isCreating && !_confirming ? 'Next' : 'Confirm',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
