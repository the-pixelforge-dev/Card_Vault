import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/group/group_entity.dart';
import '../core_providers.dart';

part 'group_provider.g.dart';

@Riverpod(keepAlive: true)
class GroupList extends _$GroupList {
  @override
  List<GroupEntity> build() {
    return ref.watch(groupRepositoryProvider).getAll();
  }

  Future<void> upsert(GroupEntity group) async {
    await ref.read(groupRepositoryProvider).save(group);
    _reload();
  }

  Future<void> remove(String id) async {
    await ref.read(groupRepositoryProvider).delete(id);
    _reload();
  }

  void _reload() {
    state = ref.read(groupRepositoryProvider).getAll();
  }
}
