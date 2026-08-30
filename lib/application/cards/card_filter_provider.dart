import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/card/card_entity.dart';
import 'card_list_provider.dart';

part 'card_filter_provider.g.dart';

enum GroupingMode { all, issuer, network, color, custom }

class CardFilter {
  const CardFilter({this.mode = GroupingMode.all, this.value});

  /// For [GroupingMode.issuer]/[GroupingMode.network]/[GroupingMode.color],
  /// the matching field value; for [GroupingMode.custom], a group id.
  final GroupingMode mode;
  final String? value;

  bool matches(CardEntity card) {
    switch (mode) {
      case GroupingMode.all:
        return true;
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
}

@riverpod
class ActiveCardFilter extends _$ActiveCardFilter {
  @override
  CardFilter build() => const CardFilter();

  void set(CardFilter filter) => state = filter;

  void clear() => state = const CardFilter();
}

@riverpod
List<CardEntity> filteredCardList(Ref ref) {
  final filter = ref.watch(activeCardFilterProvider);
  final cards = ref.watch(cardListProvider);
  if (filter.mode == GroupingMode.all) return cards;
  return cards.where(filter.matches).toList();
}
