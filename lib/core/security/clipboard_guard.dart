import 'dart:async';

import 'package:flutter/services.dart';

/// Copies a value to the clipboard and clears it again after [autoClearAfter]
/// — but only if the clipboard still holds exactly what we put there.
///
/// Two safeguards keep this from misbehaving:
/// - A generation counter: if a second sensitive field is copied before the
///   first one's timer fires, the first timer is a no-op — it can't clobber
///   the second, still-valid copy.
/// - A read-before-clear check: if the user has since copied something else
///   (switched apps and copied their own text), we leave it alone instead of
///   blowing it away.
class ClipboardGuard {
  ClipboardGuard({this.autoClearAfter = const Duration(seconds: 15)});

  final Duration autoClearAfter;

  Timer? _timer;
  String? _lastCopiedValue;
  int _copyGeneration = 0;

  Future<void> copyWithAutoClear(String value) async {
    final myGeneration = ++_copyGeneration;
    _lastCopiedValue = value;
    await Clipboard.setData(ClipboardData(text: value));

    _timer?.cancel();
    _timer = Timer(autoClearAfter, () => _maybeClear(myGeneration));
  }

  Future<void> _maybeClear(int myGeneration) async {
    if (myGeneration != _copyGeneration) return;

    final current = await Clipboard.getData(Clipboard.kTextPlain);
    if (current?.text == _lastCopiedValue) {
      await Clipboard.setData(const ClipboardData(text: ''));
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
