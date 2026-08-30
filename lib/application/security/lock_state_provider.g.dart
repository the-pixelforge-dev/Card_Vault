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

/// Whether the app-wide lock overlay should currently be shown.
///
/// Starts locked; the first successful [unlock] call clears it. Getting
/// backgrounded and resumed past the configured auto-lock timeout re-locks
/// it (see [notifyBackgrounded]/[notifyResumed], driven by a
/// `WidgetsBindingObserver` at the app root).

@ProviderFor(AppLock)
const appLockProvider = AppLockProvider._();

/// Whether the app-wide lock overlay should currently be shown.
///
/// Starts locked; the first successful [unlock] call clears it. Getting
/// backgrounded and resumed past the configured auto-lock timeout re-locks
/// it (see [notifyBackgrounded]/[notifyResumed], driven by a
/// `WidgetsBindingObserver` at the app root).
final class AppLockProvider extends $NotifierProvider<AppLock, bool> {
  /// Whether the app-wide lock overlay should currently be shown.
  ///
  /// Starts locked; the first successful [unlock] call clears it. Getting
  /// backgrounded and resumed past the configured auto-lock timeout re-locks
  /// it (see [notifyBackgrounded]/[notifyResumed], driven by a
  /// `WidgetsBindingObserver` at the app root).
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

String _$appLockHash() => r'f31cf61b49b623d548b215f17626e7dd11594665';

/// Whether the app-wide lock overlay should currently be shown.
///
/// Starts locked; the first successful [unlock] call clears it. Getting
/// backgrounded and resumed past the configured auto-lock timeout re-locks
/// it (see [notifyBackgrounded]/[notifyResumed], driven by a
/// `WidgetsBindingObserver` at the app root).

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
