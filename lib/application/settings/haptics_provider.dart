import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/haptics/haptics_service.dart';
import 'settings_provider.dart';

part 'haptics_provider.g.dart';

/// The single haptics entry point every gesture handler in the app should
/// call through, so the Settings → Haptics on/off + strength controls
/// actually take effect everywhere.
@riverpod
HapticsService hapticsService(Ref ref) {
  final settings = ref.watch(settingsProvider);
  return HapticsService(
    enabled: settings.hapticsEnabled,
    strength: settings.hapticsStrength,
  );
}
