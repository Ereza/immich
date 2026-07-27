import 'package:drift/drift.dart';
import 'package:immich_mobile/infrastructure/entities/memory.entity.dart';
import 'package:immich_mobile/infrastructure/entities/remote_asset.entity.dart';
import 'package:immich_mobile/infrastructure/utils/drift_default.mixin.dart';

class MemoryAssetEntity extends Table with DriftDefaultsMixin {
  const MemoryAssetEntity();

  TextColumn get assetId => text().references(RemoteAssetEntity, #id, onDelete: .cascade)();

  TextColumn get memoryId => text().references(MemoryEntity, #id, onDelete: .cascade)();

  @override
  Set<Column> get primaryKey => {assetId, memoryId};
}
