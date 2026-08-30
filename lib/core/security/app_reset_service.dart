import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../data/cards/card_repository.dart';
import '../../data/groups/group_repository.dart';
import '../../data/settings/settings_repository.dart';

/// The last-resort escape hatch when a user is locked out with no way to
/// recover their PIN (there is no account/cloud recovery in a fully
/// offline app). Wipes every Hive box and every secure-storage entry —
/// cards, groups, settings, the Hive encryption key, the PIN, and the
/// Gemini key — equivalent to a fresh install, but without leaving the app.
///
/// The app must be relaunched after this runs; Hive boxes already open in
/// memory are bound to the now-deleted encryption key and cannot simply be
/// reopened in place.
class AppResetService {
  Future<void> resetEverything() async {
    await Hive.close();
    await Hive.deleteBoxFromDisk(CardRepository.boxName);
    await Hive.deleteBoxFromDisk(GroupRepository.boxName);
    await Hive.deleteBoxFromDisk(SettingsRepository.boxName);
    await const FlutterSecureStorage().deleteAll();
  }
}
