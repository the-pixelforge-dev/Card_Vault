import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../bootstrap.dart';
import '../data/cards/card_repository.dart';
import '../data/groups/group_repository.dart';
import '../data/settings/settings_repository.dart';

part 'core_providers.g.dart';

/// Overridden in `main.dart` with the instance produced by [bootstrap], so
/// every repository provider below can stay a plain synchronous read.
@Riverpod(keepAlive: true)
AppDependencies appDependencies(Ref ref) {
  throw UnimplementedError('appDependencies must be overridden in main.dart');
}

@Riverpod(keepAlive: true)
CardRepository cardRepository(Ref ref) {
  return ref.watch(appDependenciesProvider).cardRepository;
}

@Riverpod(keepAlive: true)
GroupRepository groupRepository(Ref ref) {
  return ref.watch(appDependenciesProvider).groupRepository;
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  return ref.watch(appDependenciesProvider).settingsRepository;
}
