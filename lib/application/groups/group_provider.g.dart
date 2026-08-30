// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GroupList)
const groupListProvider = GroupListProvider._();

final class GroupListProvider
    extends $NotifierProvider<GroupList, List<GroupEntity>> {
  const GroupListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupListHash();

  @$internal
  @override
  GroupList create() => GroupList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<GroupEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<GroupEntity>>(value),
    );
  }
}

String _$groupListHash() => r'c316fc9ced68d2713d08f459e5d5425d0060b18d';

abstract class _$GroupList extends $Notifier<List<GroupEntity>> {
  List<GroupEntity> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<GroupEntity>, List<GroupEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<GroupEntity>, List<GroupEntity>>,
              List<GroupEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
