/// A user-defined group/tag (e.g. "Travel", "Dining") that cards can belong
/// to. Grouping by issuer, network, or color is computed on the fly from
/// card fields rather than stored as a [GroupEntity].
class GroupEntity {
  const GroupEntity({
    required this.id,
    required this.name,
    this.colorArgb,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final int? colorArgb;
  final int sortOrder;

  GroupEntity copyWith({String? name, int? colorArgb, int? sortOrder}) {
    return GroupEntity(
      id: id,
      name: name ?? this.name,
      colorArgb: colorArgb ?? this.colorArgb,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
