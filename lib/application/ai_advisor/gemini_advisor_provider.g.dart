// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemini_advisor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(geminiKeyStore)
const geminiKeyStoreProvider = GeminiKeyStoreProvider._();

final class GeminiKeyStoreProvider
    extends $FunctionalProvider<GeminiKeyStore, GeminiKeyStore, GeminiKeyStore>
    with $Provider<GeminiKeyStore> {
  const GeminiKeyStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geminiKeyStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geminiKeyStoreHash();

  @$internal
  @override
  $ProviderElement<GeminiKeyStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeminiKeyStore create(Ref ref) {
    return geminiKeyStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeminiKeyStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeminiKeyStore>(value),
    );
  }
}

String _$geminiKeyStoreHash() => r'09e0c2c9590e2daf55d9629efc115ed777dc25eb';

@ProviderFor(geminiClient)
const geminiClientProvider = GeminiClientProvider._();

final class GeminiClientProvider
    extends $FunctionalProvider<GeminiClient, GeminiClient, GeminiClient>
    with $Provider<GeminiClient> {
  const GeminiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geminiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geminiClientHash();

  @$internal
  @override
  $ProviderElement<GeminiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeminiClient create(Ref ref) {
    return geminiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeminiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeminiClient>(value),
    );
  }
}

String _$geminiClientHash() => r'a2768a46d2377a794c3ba75a691dad98396602d9';

/// Whether the advisor feature should be shown at all — purely a function
/// of whether the user has supplied their own key, refreshed after
/// [GeminiApiKey.set]/[GeminiApiKey.clear].

@ProviderFor(GeminiApiKey)
const geminiApiKeyProvider = GeminiApiKeyProvider._();

/// Whether the advisor feature should be shown at all — purely a function
/// of whether the user has supplied their own key, refreshed after
/// [GeminiApiKey.set]/[GeminiApiKey.clear].
final class GeminiApiKeyProvider
    extends $AsyncNotifierProvider<GeminiApiKey, String?> {
  /// Whether the advisor feature should be shown at all — purely a function
  /// of whether the user has supplied their own key, refreshed after
  /// [GeminiApiKey.set]/[GeminiApiKey.clear].
  const GeminiApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geminiApiKeyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geminiApiKeyHash();

  @$internal
  @override
  GeminiApiKey create() => GeminiApiKey();
}

String _$geminiApiKeyHash() => r'fc8efd8ce981ed490d1451375b7e304a284743e4';

/// Whether the advisor feature should be shown at all — purely a function
/// of whether the user has supplied their own key, refreshed after
/// [GeminiApiKey.set]/[GeminiApiKey.clear].

abstract class _$GeminiApiKey extends $AsyncNotifier<String?> {
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
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  const PurchaseAdviceProvider._({
    required PurchaseAdviceFamily super.from,
    required ({String purchaseDescription, double? purchaseAmount})
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
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument =
        this.argument as ({String purchaseDescription, double? purchaseAmount});
    return purchaseAdvice(
      ref,
      purchaseDescription: argument.purchaseDescription,
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

String _$purchaseAdviceHash() => r'd537066e583ba7103eebb4c93047865412eaa8c0';

final class PurchaseAdviceFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<String>,
          ({String purchaseDescription, double? purchaseAmount})
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
    double? purchaseAmount,
  }) => PurchaseAdviceProvider._(
    argument: (
      purchaseDescription: purchaseDescription,
      purchaseAmount: purchaseAmount,
    ),
    from: this,
  );

  @override
  String toString() => r'purchaseAdviceProvider';
}
