import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/card/card_entity.dart';
import '../../domain/card/card_validator.dart';
import '../core_providers.dart';

part 'card_list_provider.g.dart';

@Riverpod(keepAlive: true)
class CardList extends _$CardList {
  @override
  List<CardEntity> build() {
    return ref.watch(cardRepositoryProvider).getAll();
  }

  /// Throws [CardValidationException] if [card] is missing a required
  /// field — the one place every save (the form, and encrypted import) is
  /// forced through, so an incomplete card can never reach storage.
  Future<void> upsert(CardEntity card) async {
    CardValidator.ensureValid(card);
    await ref.read(cardRepositoryProvider).save(card);
    _reload();
  }

  Future<void> remove(String id) async {
    await ref.read(cardRepositoryProvider).delete(id);
    _reload();
  }

  /// Persists a full new ordering (e.g. after a drag-to-reorder gesture).
  Future<void> reorder(List<String> orderedIds) async {
    await ref.read(cardRepositoryProvider).reorder(orderedIds);
    _reload();
  }

  void _reload() {
    state = ref.read(cardRepositoryProvider).getAll();
  }
}
