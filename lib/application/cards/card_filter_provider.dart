import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/card/card_entity.dart';
import 'card_list_provider.dart';

part 'card_filter_provider.g.dart';

enum GroupingMode { all, cardType, issuer, network, color, custom }

class CardFilter {
  const CardFilter({this.mode = GroupingMode.all, this.value, this.searchQuery});

  /// For [GroupingMode.issuer]/[GroupingMode.network]/[GroupingMode.color],
  /// the matching field value; for [GroupingMode.cardType], a [CardType]
  /// name; for [GroupingMode.custom], a group id.
  final GroupingMode mode;
  final String? value;

  /// Free-text search over the card nickname, applied on top of [mode].
  final String? searchQuery;

  bool matches(CardEntity card) {
    if (searchQuery != null && searchQuery!.trim().isNotEmpty) {
      final query = searchQuery!.trim().toLowerCase();
      if (!card.nickname.toLowerCase().contains(query)) return false;
    }

    switch (mode) {
      case GroupingMode.all:
        return true;
      case GroupingMode.cardType:
        return card.cardType.name == value;
      case GroupingMode.issuer:
        return card.issuerName == value;
      case GroupingMode.network:
        return card.network.name == value;
      case GroupingMode.color:
        return card.colorArgb.toString() == value;
      case GroupingMode.custom:
        return card.groupIds.contains(value);
    }
  }

  CardFilter copyWith({
    GroupingMode? mode,
    String? Function()? value,
    String? Function()? searchQuery,
  }) {
    return CardFilter(
      mode: mode ?? this.mode,
      value: value != null ? value() : this.value,
      searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
    );
  }
}

@riverpod
class ActiveCardFilter extends _$ActiveCardFilter {
  @override
  CardFilter build() => const CardFilter();

  void set(CardFilter filter) =>
      state = filter.copyWith(searchQuery: () => state.searchQuery);

  void clear() => state = CardFilter(searchQuery: state.searchQuery);

  void setSearchQuery(String? query) =>
      state = state.copyWith(searchQuery: () => query);
}

@riverpod
List<CardEntity> filteredCardList(Ref ref) {
  final filter = ref.watch(activeCardFilterProvider);
  final cards = ref.watch(cardListProvider);
  if (filter.mode == GroupingMode.all && (filter.searchQuery ?? '').isEmpty) {
    return cards;
  }
  return cards.where(filter.matches).toList();
}
