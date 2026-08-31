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
  /// field, or if its number matches another saved card — the one place
  /// every save (the form, and encrypted import) is forced through, so an
  /// incomplete or duplicate card can never reach storage.
  Future<void> upsert(CardEntity card) async {
    CardValidator.ensureValid(card);

    final digits = card.cardNumber.replaceAll(RegExp(r'\D'), '');
    final existing = ref.read(cardRepositoryProvider).getAll();
    final isDuplicate = existing.any(
      (c) =>
          c.id != card.id &&
          c.cardNumber.replaceAll(RegExp(r'\D'), '') == digits,
    );
    if (isDuplicate) {
      throw const CardValidationException([
        'A card with this number already exists.',
      ]);
    }

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
