// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveCardFilter)
const activeCardFilterProvider = ActiveCardFilterProvider._();

final class ActiveCardFilterProvider
    extends $NotifierProvider<ActiveCardFilter, CardFilter> {
  const ActiveCardFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeCardFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeCardFilterHash();

  @$internal
  @override
  ActiveCardFilter create() => ActiveCardFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardFilter>(value),
    );
  }
}

String _$activeCardFilterHash() => r'926ef62a09f6e0a4f6d5ccb8935303e639b04a92';

abstract class _$ActiveCardFilter extends $Notifier<CardFilter> {
  CardFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CardFilter, CardFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CardFilter, CardFilter>,
              CardFilter,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(filteredCardList)
const filteredCardListProvider = FilteredCardListProvider._();

final class FilteredCardListProvider
    extends
        $FunctionalProvider<
          List<CardEntity>,
          List<CardEntity>,
          List<CardEntity>
        >
    with $Provider<List<CardEntity>> {
  const FilteredCardListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredCardListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredCardListHash();

  @$internal
  @override
  $ProviderElement<List<CardEntity>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<CardEntity> create(Ref ref) {
    return filteredCardList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CardEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CardEntity>>(value),
    );
  }
}

String _$filteredCardListHash() => r'577563941d01d6ec3902a3cee7e9d21e78cf5643';
