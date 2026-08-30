import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/security/clipboard_guard.dart';

part 'clipboard_guard_provider.g.dart';

/// A single shared [ClipboardGuard] so its generation counter correctly
/// invalidates an older copy's clear-timer no matter which screen or field
/// triggered the newer copy.
@Riverpod(keepAlive: true)
ClipboardGuard clipboardGuard(Ref ref) {
  final guard = ClipboardGuard();
  ref.onDispose(guard.dispose);
  return guard;
}
