import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:immich_mobile/constants/colors.dart';
import 'package:immich_mobile/constants/enums.dart';
import 'package:immich_mobile/domain/models/config/app_config.dart';
import 'package:immich_mobile/domain/models/log.model.dart';
import 'package:immich_mobile/domain/models/settings_key.dart';
import 'package:immich_mobile/domain/models/store.model.dart';
import 'package:immich_mobile/domain/models/timeline.model.dart';
import 'package:immich_mobile/domain/services/feature_message.service.dart';
import 'package:immich_mobile/entities/store.entity.dart';
import 'package:immich_mobile/infrastructure/entities/settings.entity.drift.dart';
import 'package:immich_mobile/infrastructure/repositories/db.repository.dart';
import 'package:immich_mobile/infrastructure/repositories/network.repository.dart';
import 'package:immich_mobile/models/auth/auxilary_endpoint.model.dart';
import 'package:immich_mobile/providers/album/album_sort_by_options.provider.dart';

const int targetVersion = 26;

Future<void> migrateDatabaseIfNeeded(Drift drift) async {
  final int? storedVersion = Store.tryGet(.version);
  final version = storedVersion ?? targetVersion;

  if (version < 25) {
    await _migrateTo25();
  }

  if (version < 26) {
    await _migrateTo26(drift);
  }

  if (storedVersion == null) {
    await FeatureMessageService(.instance).markSeen();
  }

  await Store.put(StoreKey.version, targetVersion);
  return;
}

Future<void> _migrateTo25() async {
  final accessToken = Store.tryGet(.accessToken);
  if (accessToken == null || accessToken.isEmpty) {
    return;
  }

  final urls = <String>[];
  final serverEndpoint = Store.tryGet(.serverEndpoint);
  if (serverEndpoint != null && serverEndpoint.isNotEmpty) {
    urls.add(serverEndpoint);
  }
  final localEndpoint = Store.tryGet(.legacyLocalEndpoint);
  if (localEndpoint != null && localEndpoint.isNotEmpty) {
    urls.add(localEndpoint);
  }
  final externalJson = Store.tryGet(.legacyExternalEndpointList);
  if (externalJson != null) {
    final List<dynamic> list = jsonDecode(externalJson);
    for (final entry in list) {
      final url = AuxilaryEndpoint.fromJson(entry).url;
      if (url.isNotEmpty) {
        urls.add(url);
      }
    }
  }
  if (urls.isEmpty) {
    return;
  }

  final customHeadersStr = Store.get(.legacyCustomHeaders, "");
  final headers = customHeadersStr.isEmpty
      ? const <String, String>{}
      : (jsonDecode(customHeadersStr) as Map).cast<String, String>();

  await NetworkRepository.setHeaders(headers, urls, token: accessToken);
}

Future<void> _migrateTo26(Drift drift) async {
  final migrator = _StoreMigrator(drift);
  await migrator.migrateEnumIndex(.legacyLogLevel, .logLevel, LogLevel.values);
  // Theme
  await migrator.migrateEnumName(.legacyThemeMode, .themeMode, ThemeMode.values);
  await migrator.migrateEnumName(.legacyPrimaryColor, .themePrimaryColor, ImmichColorPreset.values);
  await migrator.migrateBool(.legacyDynamicTheme, .themeDynamic);
  await migrator.migrateBool(.legacyColorfulInterface, .themeColorfulInterface);
  // Cleanup
  final cleanupKeepAlbumIds = await migrator.readLegacyStoreString(StoreKey.legacyCleanupKeepAlbumIds.id);
  if (cleanupKeepAlbumIds != null) {
    final ids = cleanupKeepAlbumIds.split(',').where((id) => id.isNotEmpty).toList();
    migrator.stage(.legacyCleanupKeepAlbumIds, .cleanupKeepAlbumIds, ids);
  }
  await migrator.migrateBool(.legacyCleanupKeepFavorites, .cleanupKeepFavorites);
  await migrator.migrateEnumIndex(.legacyCleanupKeepMediaType, .cleanupKeepMediaType, AssetKeepType.values);
  await migrator.migrateInt(.legacyCleanupCutoffDaysAgo, .cleanupCutoffDaysAgo);
  await migrator.migrateBool(.legacyCleanupDefaultsInitialized, .cleanupDefaultsInitialized);
  // Map
  await migrator.migrateBool(.legacyMapShowFavoriteOnly, .mapShowFavoriteOnly);
  await migrator.migrateInt(.legacyMapRelativeDate, .mapRelativeDate);
  await migrator.migrateBool(.legacyMapIncludeArchived, .mapIncludeArchived);
  await migrator.migrateEnumIndex(.legacyMapThemeMode, .mapThemeMode, ThemeMode.values);
  await migrator.migrateBool(.legacyMapwithPartners, .mapWithPartners);
  // Timeline
  await migrator.migrateInt(.legacyTilesPerRow, .timelineTilesPerRow);
  await migrator.migrateEnumIndex(.legacyGroupAssetsBy, .timelineGroupAssetsBy, GroupAssetsBy.values);
  await migrator.migrateBool(.legacyStorageIndicator, .timelineStorageIndicator);
  // Image
  await migrator.migrateBool(.legacyPreferRemoteImage, .imagePreferRemote);
  await migrator.migrateBool(.legacyLoadOriginal, .imageLoadOriginal);
  // Viewer
  await migrator.migrateBool(.legacyLoopVideo, .viewerLoopVideo);
  await migrator.migrateBool(.legacyLoadOriginalVideo, .viewerLoadOriginalVideo);
  await migrator.migrateBool(.legacyAutoPlayVideo, .viewerAutoPlayVideo);
  await migrator.migrateBool(.legacyTapToNavigate, .viewerTapToNavigate);
  // Network
  await migrator.migrateBool(.legacyAutoEndpointSwitching, .networkAutoEndpointSwitching);
  final preferredWifiName = await migrator.readLegacyStoreString(StoreKey.legacyPreferredWifiName.id);
  migrator.stage(.legacyPreferredWifiName, .networkPreferredWifiName, preferredWifiName);
  final localEndpoint = await migrator.readLegacyStoreString(StoreKey.legacyLocalEndpoint.id);
  migrator.stage(.legacyLocalEndpoint, .networkLocalEndpoint, localEndpoint);
  await _migrateExternalEndpointList(migrator);
  await _migrateCustomHeaders(migrator);
  // Album
  await _migrateAlbumSortMode(migrator);
  await migrator.migrateBool(.legacySelectedAlbumSortReverse, .albumIsReverse);
  await migrator.migrateBool(.legacyAlbumGridView, .albumIsGrid);
  // Backup
  await migrator.migrateBool(.legacyEnableBackup, .backupEnabled);
  await migrator.migrateBool(.legacyUseWifiForUploadVideos, .backupUseCellularForVideos);
  await migrator.migrateBool(.legacyUseWifiForUploadPhotos, .backupUseCellularForPhotos);
  await migrator.migrateBool(.legacyBackupRequireCharging, .backupRequireCharging);
  await migrator.migrateInt(.legacyBackupTriggerDelay, .backupTriggerDelay);
  await migrator.migrateBool(.legacySyncAlbums, .backupSyncAlbums);
  await migrator.complete();
}

Future<void> _migrateAlbumSortMode(_StoreMigrator migrator) async {
  final raw = await migrator.readLegacyStoreInt(StoreKey.legacySelectedAlbumSortOrder.id);
  final mode = AlbumSortMode.values.firstWhereOrNull((e) => raw != null && e.storeIndex == raw);
  if (mode == null) {
    return;
  }

  migrator.stage(.legacySelectedAlbumSortOrder, .albumSortMode, mode);
}

Future<void> _migrateExternalEndpointList(_StoreMigrator migrator) async {
  final raw = await migrator.readLegacyStoreString(StoreKey.legacyExternalEndpointList.id);
  if (raw == null) {
    return;
  }

  final urls = <String>[];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      for (final entry in decoded) {
        final url = AuxilaryEndpoint.fromJson(entry).url;
        if (url.isNotEmpty) {
          urls.add(url);
        }
      }
    }
  } on FormatException {
    // ignore invalid entries
  }

  migrator.stage(.legacyExternalEndpointList, .networkExternalEndpointList, urls);
}

Future<void> _migrateCustomHeaders(_StoreMigrator migrator) async {
  final raw = await migrator.readLegacyStoreString(StoreKey.legacyCustomHeaders.id);
  if (raw == null) {
    return;
  }

  final headers = <String, String>{};
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      decoded.forEach((key, value) {
        if (key is String && value is String) {
          headers[key] = value;
        }
      });
    }
  } on FormatException {
    // ignore invalid entries
  }

  migrator.stage(.legacyCustomHeaders, .networkCustomHeaders, headers);
}

class _StoreMigrator {
  final Drift _db;
  final Map<SettingsKey, Object?> _cache = {};
  final List<int> _migratedStoreIds = [];

  _StoreMigrator(this._db);

  Future<void> migrateEnumIndex<T extends Enum>(StoreKey<int> legacyKey, SettingsKey<T> newKey, List<T> values) async {
    final index = await readLegacyStoreInt(legacyKey.id);
    if (index == null) {
      return;
    }

    final enumValue = values.elementAtOrNull(index);
    if (enumValue == null) {
      return;
    }

    _cache[newKey] = enumValue;
    _migratedStoreIds.add(legacyKey.id);
  }

  Future<void> migrateEnumName<T extends Enum>(
    StoreKey<String> legacyKey,
    SettingsKey<T> newKey,
    List<T> values,
  ) async {
    final name = await readLegacyStoreString(legacyKey.id);
    if (name == null) {
      return;
    }

    final enumValue = values.firstWhereOrNull((e) => e.name == name);
    if (enumValue == null) {
      return;
    }

    _cache[newKey] = enumValue;
    _migratedStoreIds.add(legacyKey.id);
  }

  Future<void> migrateBool(StoreKey<bool> legacyKey, SettingsKey<bool> newKey) async {
    final intValue = await readLegacyStoreInt(legacyKey.id);
    if (intValue == null) {
      return;
    }

    final boolValue = intValue != 0;
    _cache[newKey] = boolValue;
    _migratedStoreIds.add(legacyKey.id);
  }

  Future<void> migrateInt(StoreKey<int> legacyKey, SettingsKey<int> newKey) async {
    final intValue = await readLegacyStoreInt(legacyKey.id);
    if (intValue == null) {
      return;
    }

    _cache[newKey] = intValue;
    _migratedStoreIds.add(legacyKey.id);
  }

  Future<void> migrateString(StoreKey<String> legacyKey, SettingsKey<String> newKey) async {
    final value = await readLegacyStoreString(legacyKey.id);
    if (value == null) {
      return;
    }

    _cache[newKey] = value;
    _migratedStoreIds.add(legacyKey.id);
  }

  void stage<T, U extends T>(StoreKey legacyKey, SettingsKey<T> newKey, U value) {
    _cache[newKey] = value;
    _migratedStoreIds.add(legacyKey.id);
  }

  Future<void> complete() async {
    await _db.batch((batch) {
      for (final entry in _cache.entries) {
        if (entry.value == defaultConfig.read(entry.key)) {
          continue;
        }

        String? resolvedValue;
        if (entry.value != null) {
          resolvedValue = entry.key.encode(entry.value);
        }

        batch.insert(
          _db.settingsEntity,
          SettingsEntityCompanion(key: Value(entry.key.name), value: Value(resolvedValue)),
          mode: .insertOrReplace,
        );
      }
    });
    await deleteLegacyStoreRows(_migratedStoreIds);
  }

  Future<String?> readLegacyStoreString(int id) async {
    final row = await (_db.storeEntity.select()..where((t) => t.id.equals(id))).getSingleOrNull();
    return row?.stringValue;
  }

  Future<int?> readLegacyStoreInt(int id) async {
    final row = await (_db.storeEntity.select()..where((t) => t.id.equals(id))).getSingleOrNull();
    return row?.intValue;
  }

  Future<void> deleteLegacyStoreRows(List<int> ids) async {
    if (ids.isEmpty) {
      return;
    }
    await (_db.storeEntity.delete()..where((t) => t.id.isIn(ids))).go();
  }
}
