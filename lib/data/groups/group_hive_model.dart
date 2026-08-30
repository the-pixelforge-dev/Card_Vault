import 'package:hive_ce/hive.dart';

part 'group_hive_model.g.dart';

@HiveType(typeId: 1)
class GroupHiveModel extends HiveObject {
  GroupHiveModel({
    required this.id,
    required this.name,
    this.colorArgb,
    required this.sortOrder,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int? colorArgb;

  @HiveField(3)
  int sortOrder;
}
