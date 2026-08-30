import 'package:hive_ce/hive.dart';

import '../../domain/group/group_entity.dart';
import 'group_hive_model.dart';

class GroupRepository {
  GroupRepository(this._box);

  static const boxName = 'groups';

  final Box<GroupHiveModel> _box;

  List<GroupEntity> getAll() {
    final entities = _box.values.map(_toEntity).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return entities;
  }

  Future<void> save(GroupEntity group) async {
    await _box.put(
      group.id,
      GroupHiveModel(
        id: group.id,
        name: group.name,
        colorArgb: group.colorArgb,
        sortOrder: group.sortOrder,
      ),
    );
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  GroupEntity _toEntity(GroupHiveModel m) => GroupEntity(
    id: m.id,
    name: m.name,
    colorArgb: m.colorArgb,
    sortOrder: m.sortOrder,
  );
}
