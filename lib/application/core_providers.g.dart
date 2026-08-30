// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the instance produced by [bootstrap], so
/// every repository provider below can stay a plain synchronous read.

@ProviderFor(appDependencies)
const appDependenciesProvider = AppDependenciesProvider._();

/// Overridden in `main.dart` with the instance produced by [bootstrap], so
/// every repository provider below can stay a plain synchronous read.

final class AppDependenciesProvider
    extends
        $FunctionalProvider<AppDependencies, AppDependencies, AppDependencies>
    with $Provider<AppDependencies> {
  /// Overridden in `main.dart` with the instance produced by [bootstrap], so
  /// every repository provider below can stay a plain synchronous read.
  const AppDependenciesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDependenciesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDependenciesHash();

  @$internal
  @override
  $ProviderElement<AppDependencies> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDependencies create(Ref ref) {
    return appDependencies(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDependencies value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDependencies>(value),
    );
  }
}

String _$appDependenciesHash() => r'5a2f4a38beb0f2d45bd7e755fe0c0899503258ad';

@ProviderFor(cardRepository)
const cardRepositoryProvider = CardRepositoryProvider._();

final class CardRepositoryProvider
    extends $FunctionalProvider<CardRepository, CardRepository, CardRepository>
    with $Provider<CardRepository> {
  const CardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardRepositoryHash();

  @$internal
  @override
  $ProviderElement<CardRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CardRepository create(Ref ref) {
    return cardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardRepository>(value),
    );
  }
}

String _$cardRepositoryHash() => r'bed27f6ad64e9d99d970addb8bd24e99d06508c8';

@ProviderFor(groupRepository)
const groupRepositoryProvider = GroupRepositoryProvider._();

final class GroupRepositoryProvider
    extends
        $FunctionalProvider<GroupRepository, GroupRepository, GroupRepository>
    with $Provider<GroupRepository> {
  const GroupRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupRepositoryHash();

  @$internal
  @override
  $ProviderElement<GroupRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroupRepository create(Ref ref) {
    return groupRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupRepository>(value),
    );
  }
}

String _$groupRepositoryHash() => r'19261bbcbe8a1fe22f99807c55d8b44041548407';

@ProviderFor(settingsRepository)
const settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  const SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'9b7a347c668e00fb5dc3759d99c47016fe654f53';
