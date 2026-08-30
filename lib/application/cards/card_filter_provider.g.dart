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

String _$activeCardFilterHash() => r'38265b92427808dea3268f828f28da6d0b1e5dc6';

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

String _$filteredCardListHash() => r'11568081f70b838500f26b95baf3a14bbb1055c6';
