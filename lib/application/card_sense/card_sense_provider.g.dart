// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_sense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groqKeyStore)
const groqKeyStoreProvider = GroqKeyStoreProvider._();

final class GroqKeyStoreProvider
    extends $FunctionalProvider<GroqKeyStore, GroqKeyStore, GroqKeyStore>
    with $Provider<GroqKeyStore> {
  const GroqKeyStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groqKeyStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groqKeyStoreHash();

  @$internal
  @override
  $ProviderElement<GroqKeyStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroqKeyStore create(Ref ref) {
    return groqKeyStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroqKeyStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroqKeyStore>(value),
    );
  }
}

String _$groqKeyStoreHash() => r'3f0d2e82347adb69ee797bee978fb84b5754a29b';

@ProviderFor(groqClient)
const groqClientProvider = GroqClientProvider._();

final class GroqClientProvider
    extends $FunctionalProvider<GroqClient, GroqClient, GroqClient>
    with $Provider<GroqClient> {
  const GroqClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groqClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groqClientHash();

  @$internal
  @override
  $ProviderElement<GroqClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroqClient create(Ref ref) {
    return groqClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroqClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroqClient>(value),
    );
  }
}

String _$groqClientHash() => r'dc14b8cd6348773e4d64babda646c1a0fa10d6f5';

/// Whether Card Sense should be shown at all — purely a function of
/// whether the user has supplied their own key, refreshed after
/// [GroqApiKey.set]/[GroqApiKey.clear].

@ProviderFor(GroqApiKey)
const groqApiKeyProvider = GroqApiKeyProvider._();

/// Whether Card Sense should be shown at all — purely a function of
/// whether the user has supplied their own key, refreshed after
/// [GroqApiKey.set]/[GroqApiKey.clear].
final class GroqApiKeyProvider
    extends $AsyncNotifierProvider<GroqApiKey, String?> {
  /// Whether Card Sense should be shown at all — purely a function of
  /// whether the user has supplied their own key, refreshed after
  /// [GroqApiKey.set]/[GroqApiKey.clear].
  const GroqApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groqApiKeyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groqApiKeyHash();

  @$internal
  @override
  GroqApiKey create() => GroqApiKey();
}

String _$groqApiKeyHash() => r'56c1ad40222a2e5cc65de3c35ddb5e69e7ef3cb5';

/// Whether Card Sense should be shown at all — purely a function of
/// whether the user has supplied their own key, refreshed after
/// [GroqApiKey.set]/[GroqApiKey.clear].

abstract class _$GroqApiKey extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(purchaseAdvice)
const purchaseAdviceProvider = PurchaseAdviceFamily._();

final class PurchaseAdviceProvider
    extends
        $FunctionalProvider<
          AsyncValue<CardSenseAnswer>,
          CardSenseAnswer,
          FutureOr<CardSenseAnswer>
        >
    with $FutureModifier<CardSenseAnswer>, $FutureProvider<CardSenseAnswer> {
  const PurchaseAdviceProvider._({
    required PurchaseAdviceFamily super.from,
    required ({
      String purchaseDescription,
      bool isOnlinePurchase,
      String? onlinePlatform,
      int? purchaseAmount,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'purchaseAdviceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseAdviceHash();

  @override
  String toString() {
    return r'purchaseAdviceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<CardSenseAnswer> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CardSenseAnswer> create(Ref ref) {
    final argument =
        this.argument
            as ({
              String purchaseDescription,
              bool isOnlinePurchase,
              String? onlinePlatform,
              int? purchaseAmount,
            });
    return purchaseAdvice(
      ref,
      purchaseDescription: argument.purchaseDescription,
      isOnlinePurchase: argument.isOnlinePurchase,
      onlinePlatform: argument.onlinePlatform,
      purchaseAmount: argument.purchaseAmount,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseAdviceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseAdviceHash() => r'cbda93e24595c99cd594b87c35d1606b7dcbd8e0';

final class PurchaseAdviceFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<CardSenseAnswer>,
          ({
            String purchaseDescription,
            bool isOnlinePurchase,
            String? onlinePlatform,
            int? purchaseAmount,
          })
        > {
  const PurchaseAdviceFamily._()
    : super(
        retry: null,
        name: r'purchaseAdviceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PurchaseAdviceProvider call({
    required String purchaseDescription,
    required bool isOnlinePurchase,
    String? onlinePlatform,
    int? purchaseAmount,
  }) => PurchaseAdviceProvider._(
    argument: (
      purchaseDescription: purchaseDescription,
      isOnlinePurchase: isOnlinePurchase,
      onlinePlatform: onlinePlatform,
      purchaseAmount: purchaseAmount,
    ),
    from: this,
  );

  @override
  String toString() => r'purchaseAdviceProvider';
}
