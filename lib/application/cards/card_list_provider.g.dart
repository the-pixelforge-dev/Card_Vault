// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CardList)
const cardListProvider = CardListProvider._();

final class CardListProvider
    extends $NotifierProvider<CardList, List<CardEntity>> {
  const CardListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardListHash();

  @$internal
  @override
  CardList create() => CardList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CardEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CardEntity>>(value),
    );
  }
}

String _$cardListHash() => r'ed256829e9e1632cacb4d5980eab4798190b755e';

abstract class _$CardList extends $Notifier<List<CardEntity>> {
  List<CardEntity> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<CardEntity>, List<CardEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<CardEntity>, List<CardEntity>>,
              List<CardEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
