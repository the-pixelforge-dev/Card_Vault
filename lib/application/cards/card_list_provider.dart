import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/card/card_entity.dart';
import '../core_providers.dart';

part 'card_list_provider.g.dart';

@Riverpod(keepAlive: true)
class CardList extends _$CardList {
  @override
  List<CardEntity> build() {
    return ref.watch(cardRepositoryProvider).getAll();
  }

  Future<void> upsert(CardEntity card) async {
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
