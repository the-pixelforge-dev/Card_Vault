// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lock_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appLockService)
const appLockServiceProvider = AppLockServiceProvider._();

final class AppLockServiceProvider
    extends $FunctionalProvider<AppLockService, AppLockService, AppLockService>
    with $Provider<AppLockService> {
  const AppLockServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockServiceHash();

  @$internal
  @override
  $ProviderElement<AppLockService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLockService create(Ref ref) {
    return appLockService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLockService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLockService>(value),
    );
  }
}

String _$appLockServiceHash() => r'd74e3760feb1c7c27e37182fdef2f3579f671876';

@ProviderFor(pinStore)
const pinStoreProvider = PinStoreProvider._();

final class PinStoreProvider
    extends $FunctionalProvider<PinStore, PinStore, PinStore>
    with $Provider<PinStore> {
  const PinStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinStoreHash();

  @$internal
  @override
  $ProviderElement<PinStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PinStore create(Ref ref) {
    return pinStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PinStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PinStore>(value),
    );
  }
}

String _$pinStoreHash() => r'603313e04f1703a98d22d4c770d07a073a59fbbc';

/// Whether an app PIN has been configured at all — the guaranteed unlock
/// method. Re-read after [AppLock.setPin]/[AppLock.clearPin] via
/// [Ref.invalidate].

@ProviderFor(hasPin)
const hasPinProvider = HasPinProvider._();

/// Whether an app PIN has been configured at all — the guaranteed unlock
/// method. Re-read after [AppLock.setPin]/[AppLock.clearPin] via
/// [Ref.invalidate].

final class HasPinProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether an app PIN has been configured at all — the guaranteed unlock
  /// method. Re-read after [AppLock.setPin]/[AppLock.clearPin] via
  /// [Ref.invalidate].
  const HasPinProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasPinProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasPinHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return hasPin(ref);
  }
}

String _$hasPinHash() => r'd79573e5fc15b4cd3a294da7a923ce5bc43d92f9';

@ProviderFor(isBiometricAvailable)
const isBiometricAvailableProvider = IsBiometricAvailableProvider._();

final class IsBiometricAvailableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const IsBiometricAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isBiometricAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isBiometricAvailableHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isBiometricAvailable(ref);
  }
}

String _$isBiometricAvailableHash() =>
    r'5bf94618d1835c58e11709117a6993562d5ff7d2';

/// Whether the app-wide lock overlay should currently be shown.
///
/// Starts locked; a successful [unlockWithPin] or [unlockWithBiometric]
/// call clears it. Getting backgrounded and resumed past the configured
/// auto-lock timeout re-locks it (see [notifyBackgrounded]/[notifyResumed],
/// driven by a `WidgetsBindingObserver` at the app root).
///
/// The PIN is always the guaranteed fallback — biometrics are only ever an
/// optional shortcut layered on top — so there is no configuration that can
/// strand a user with no way to unlock short of the explicit "reset app"
/// escape hatch in [LockScreen].

@ProviderFor(AppLock)
const appLockProvider = AppLockProvider._();

/// Whether the app-wide lock overlay should currently be shown.
///
/// Starts locked; a successful [unlockWithPin] or [unlockWithBiometric]
/// call clears it. Getting backgrounded and resumed past the configured
/// auto-lock timeout re-locks it (see [notifyBackgrounded]/[notifyResumed],
/// driven by a `WidgetsBindingObserver` at the app root).
///
/// The PIN is always the guaranteed fallback — biometrics are only ever an
/// optional shortcut layered on top — so there is no configuration that can
/// strand a user with no way to unlock short of the explicit "reset app"
/// escape hatch in [LockScreen].
final class AppLockProvider extends $NotifierProvider<AppLock, bool> {
  /// Whether the app-wide lock overlay should currently be shown.
  ///
  /// Starts locked; a successful [unlockWithPin] or [unlockWithBiometric]
  /// call clears it. Getting backgrounded and resumed past the configured
  /// auto-lock timeout re-locks it (see [notifyBackgrounded]/[notifyResumed],
  /// driven by a `WidgetsBindingObserver` at the app root).
  ///
  /// The PIN is always the guaranteed fallback — biometrics are only ever an
  /// optional shortcut layered on top — so there is no configuration that can
  /// strand a user with no way to unlock short of the explicit "reset app"
  /// escape hatch in [LockScreen].
  const AppLockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockHash();

  @$internal
  @override
  AppLock create() => AppLock();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$appLockHash() => r'e3a22991abf2866ffc5650a6da04f0ce9daad0e2';

/// Whether the app-wide lock overlay should currently be shown.
///
/// Starts locked; a successful [unlockWithPin] or [unlockWithBiometric]
/// call clears it. Getting backgrounded and resumed past the configured
/// auto-lock timeout re-locks it (see [notifyBackgrounded]/[notifyResumed],
/// driven by a `WidgetsBindingObserver` at the app root).
///
/// The PIN is always the guaranteed fallback — biometrics are only ever an
/// optional shortcut layered on top — so there is no configuration that can
/// strand a user with no way to unlock short of the explicit "reset app"
/// escape hatch in [LockScreen].

abstract class _$AppLock extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
