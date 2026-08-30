// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clipboard_guard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A single shared [ClipboardGuard] so its generation counter correctly
/// invalidates an older copy's clear-timer no matter which screen or field
/// triggered the newer copy.

@ProviderFor(clipboardGuard)
const clipboardGuardProvider = ClipboardGuardProvider._();

/// A single shared [ClipboardGuard] so its generation counter correctly
/// invalidates an older copy's clear-timer no matter which screen or field
/// triggered the newer copy.

final class ClipboardGuardProvider
    extends $FunctionalProvider<ClipboardGuard, ClipboardGuard, ClipboardGuard>
    with $Provider<ClipboardGuard> {
  /// A single shared [ClipboardGuard] so its generation counter correctly
  /// invalidates an older copy's clear-timer no matter which screen or field
  /// triggered the newer copy.
  const ClipboardGuardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clipboardGuardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clipboardGuardHash();

  @$internal
  @override
  $ProviderElement<ClipboardGuard> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClipboardGuard create(Ref ref) {
    return clipboardGuard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClipboardGuard value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClipboardGuard>(value),
    );
  }
}

String _$clipboardGuardHash() => r'a4016a81eff3aeb8b63c27761a2a1b5f354a1d1f';
