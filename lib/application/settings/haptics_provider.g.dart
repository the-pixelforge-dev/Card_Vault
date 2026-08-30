// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'haptics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single haptics entry point every gesture handler in the app should
/// call through, so the Settings → Haptics on/off + strength controls
/// actually take effect everywhere.

@ProviderFor(hapticsService)
const hapticsServiceProvider = HapticsServiceProvider._();

/// The single haptics entry point every gesture handler in the app should
/// call through, so the Settings → Haptics on/off + strength controls
/// actually take effect everywhere.

final class HapticsServiceProvider
    extends $FunctionalProvider<HapticsService, HapticsService, HapticsService>
    with $Provider<HapticsService> {
  /// The single haptics entry point every gesture handler in the app should
  /// call through, so the Settings → Haptics on/off + strength controls
  /// actually take effect everywhere.
  const HapticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hapticsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hapticsServiceHash();

  @$internal
  @override
  $ProviderElement<HapticsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HapticsService create(Ref ref) {
    return hapticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HapticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HapticsService>(value),
    );
  }
}

String _$hapticsServiceHash() => r'3f3c8f74125b9263329965b8a8718725f7274175';
