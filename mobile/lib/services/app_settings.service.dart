import 'package:immich_mobile/domain/models/store.model.dart';
import 'package:immich_mobile/entities/store.entity.dart';

enum AppSettingsEnum<T> {
  advancedTroubleshooting<bool>(.advancedTroubleshooting, null, false),
  manageLocalMediaAndroid<bool>(.manageLocalMediaAndroid, null, false),
  enableHapticFeedback<bool>(.enableHapticFeedback, null, true),
  readonlyModeEnabled<bool>(.readonlyModeEnabled, "readonlyModeEnabled", false);

  const AppSettingsEnum(this.storeKey, this.hiveKey, this.defaultValue);

  final StoreKey<T> storeKey;
  final String? hiveKey;
  final T defaultValue;
}

class AppSettingsService {
  const AppSettingsService();
  T getSetting<T>(AppSettingsEnum<T> setting) {
    return Store.get(setting.storeKey, setting.defaultValue);
  }

  Future<void> setSetting<T>(AppSettingsEnum<T> setting, T value) {
    return Store.put(setting.storeKey, value);
  }
}
