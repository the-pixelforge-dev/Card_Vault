import 'package:flutter/widgets.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'core/fonts/dynamic_font_loader.dart';
import 'core/security/key_manager.dart';
import 'data/cards/card_hive_model.dart';
import 'data/cards/card_repository.dart';
import 'data/groups/group_hive_model.dart';
import 'data/groups/group_repository.dart';
import 'data/settings/settings_hive_model.dart';
import 'data/settings/settings_repository.dart';
import 'hive_registrar.g.dart';

/// Everything the app needs to start, assembled before `runApp()`.
class AppDependencies {
  const AppDependencies({
    required this.cardRepository,
    required this.groupRepository,
    required this.settingsRepository,
  });

  final CardRepository cardRepository;
  final GroupRepository groupRepository;
  final SettingsRepository settingsRepository;
}

/// Sequencing matters: the Hive encryption key must be ready before any box
/// opens, and every imported font must finish registering before the first
/// frame builds (otherwise text using that family briefly falls back).
Future<AppDependencies> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyManager = KeyManager();
  final cipher = await keyManager.getOrCreateHiveCipher();

  await Hive.initFlutter();
  Hive.registerAdapters();

  final cardBox = await Hive.openBox<CardHiveModel>(
    CardRepository.boxName,
    encryptionCipher: cipher,
  );
  final groupBox = await Hive.openBox<GroupHiveModel>(
    GroupRepository.boxName,
    encryptionCipher: cipher,
  );
  final settingsBox = await Hive.openBox<AppSettingsHiveModel>(
    SettingsRepository.boxName,
    encryptionCipher: cipher,
  );

  final settingsRepository = SettingsRepository(settingsBox);
  await DynamicFontLoader.registerAll(
    settingsRepository.get().importedFonts,
  );

  return AppDependencies(
    cardRepository: CardRepository(cardBox),
    groupRepository: GroupRepository(groupBox),
    settingsRepository: settingsRepository,
  );
}
