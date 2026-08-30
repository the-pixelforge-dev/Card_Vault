import 'package:hive_ce/hive.dart';

import 'settings_hive_model.dart';

/// Settings are a single record in their own box, keyed by [_singletonKey].
class SettingsRepository {
  SettingsRepository(this._box);

  static const boxName = 'settings';
  static const _singletonKey = 'app_settings';

  final Box<AppSettingsHiveModel> _box;

  AppSettingsHiveModel get() {
    return _box.get(_singletonKey) ?? AppSettingsHiveModel();
  }

  Future<void> save(AppSettingsHiveModel settings) async {
    await _box.put(_singletonKey, settings);
  }
}
