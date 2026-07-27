import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immich_mobile/domain/models/album/local_album.model.dart';
import 'package:immich_mobile/domain/models/asset/base_asset.model.dart';
import 'package:immich_mobile/domain/models/timeline.model.dart';
import 'package:immich_mobile/infrastructure/entities/local_album.entity.drift.dart';
import 'package:immich_mobile/infrastructure/entities/local_album_asset.entity.drift.dart';
import 'package:immich_mobile/infrastructure/entities/local_asset.entity.drift.dart';
import 'package:immich_mobile/infrastructure/entities/remote_asset.entity.drift.dart';
import 'package:immich_mobile/infrastructure/entities/user.entity.drift.dart';
import 'package:immich_mobile/infrastructure/repositories/db.repository.dart';

const _userId = 'user-1';
const _albumId = 'album-1';

void main() {
  late Drift db;

  setUp(() async {
    db = Drift(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    await db
        .into(db.userEntity)
        .insert(UserEntityCompanion.insert(id: _userId, email: 'user-1@test.dev', name: 'User 1'));
    await db
        .into(db.localAlbumEntity)
        .insert(
          LocalAlbumEntityCompanion.insert(id: _albumId, name: 'Camera', backupSelection: BackupSelection.selected),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertRemote(String id, {required DateTime createdAt, DateTime? localDateTime}) => db
      .into(db.remoteAssetEntity)
      .insert(
        RemoteAssetEntityCompanion.insert(
          id: id,
          name: '$id.jpg',
          type: AssetType.image,
          checksum: 'checksum-$id',
          ownerId: _userId,
          visibility: AssetVisibility.timeline,
          createdAt: Value(createdAt),
          updatedAt: Value(createdAt),
          uploadedAt: Value(createdAt),
          localDateTime: Value(localDateTime),
        ),
      );

  Future<void> insertLocal(String id, {required DateTime createdAt}) async {
    await db
        .into(db.localAssetEntity)
        .insert(
          LocalAssetEntityCompanion.insert(
            id: id,
            name: '$id.jpg',
            type: AssetType.image,
            checksum: Value('checksum-$id'),
            createdAt: Value(createdAt),
            updatedAt: Value(createdAt),
          ),
        );
    await db
        .into(db.localAlbumAssetEntity)
        .insert(LocalAlbumAssetEntityCompanion.insert(assetId: id, albumId: _albumId));
  }

  // Mirrors how the timeline pairs headers with tiles: buckets only carry a count, the assets
  // come from one flat list that is addressed by the running offset of the previous buckets.
  Future<List<(String, String)>> headerForEachAsset(GroupAssetsBy groupBy) async {
    final buckets = await db.mergedAssetDrift.mergedBucket(groupBy: groupBy.index, userIds: [_userId]).get();
    final assets = await db.mergedAssetDrift.mergedAsset(userIds: [_userId], limit: (_) => Limit(1000, 0)).get();

    final pairs = <(String, String)>[];
    var offset = 0;
    for (final bucket in buckets) {
      for (final asset in assets.skip(offset).take(bucket.assetCount)) {
        pairs.add(((asset.remoteId ?? asset.localId)!, bucket.bucketDate));
      }
      offset += bucket.assetCount;
    }
    return pairs;
  }

  test('mergedBucket falls back to createdAt when localDateTime is null', () async {
    await insertRemote('asset-1', createdAt: DateTime(2024, 1, 1, 12));

    final buckets = await db.mergedAssetDrift.mergedBucket(groupBy: GroupAssetsBy.day.index, userIds: [_userId]).get();

    expect(buckets, hasLength(1));
    expect(buckets.single.assetCount, 1);
    expect(buckets.single.bucketDate, '2024-01-01');
  });

  // Regression for #29864: buckets group by localDateTime but assets were ordered by createdAt,
  // so a header minted from one asset's localDateTime was rendered above a different asset.
  group('mergedAsset ordering matches mergedBucket grouping', () {
    Future<void> seedGhost() async {
      await insertRemote('asset-a', createdAt: DateTime(2026, 4, 26, 10));
      await insertRemote('asset-b', createdAt: DateTime(2026, 4, 26, 12));
      await insertRemote('ghost', createdAt: DateTime(2026, 4, 26, 11), localDateTime: DateTime.utc(2027, 3, 4, 12));
    }

    test('asset under each header belongs to that header date', () async {
      await seedGhost();

      expect(await headerForEachAsset(GroupAssetsBy.day), [
        ('ghost', '2027-03-04'),
        ('asset-b', '2026-04-26'),
        ('asset-a', '2026-04-26'),
      ]);
    });

    test('deleting the asset under a header removes the empty header', () async {
      await seedGhost();

      await db.remoteAssetEntity.deleteWhere((row) => row.id.equals('ghost'));

      final buckets = await db.mergedAssetDrift
          .mergedBucket(groupBy: GroupAssetsBy.day.index, userIds: [_userId])
          .get();
      expect(buckets.map((b) => b.bucketDate), ['2026-04-26']);
      expect(buckets.single.assetCount, 2);

      expect(await headerForEachAsset(GroupAssetsBy.day), [('asset-b', '2026-04-26'), ('asset-a', '2026-04-26')]);
    });

    test('orders by createdAt when localDateTime is null', () async {
      await insertRemote('asset-a', createdAt: DateTime(2026, 4, 26, 10));
      await insertRemote('asset-b', createdAt: DateTime(2026, 4, 26, 12));

      final assets = await db.mergedAssetDrift.mergedAsset(userIds: [_userId], limit: (_) => Limit(2, 0)).get();
      expect(assets.map((a) => a.remoteId), ['asset-b', 'asset-a']);
    });
  });

  test('assets taken in different timezones stay under their own day header', () async {
    // taken 2024-04-27 08:00 in UTC+9
    await insertRemote('tokyo', createdAt: DateTime.utc(2024, 4, 26, 23), localDateTime: DateTime.utc(2024, 4, 27, 8));
    // taken 2024-04-26 20:00 in UTC-5, uploaded from the same trip
    await insertRemote(
      'new-york',
      createdAt: DateTime.utc(2024, 4, 27, 1),
      localDateTime: DateTime.utc(2024, 4, 26, 20),
    );

    expect(await headerForEachAsset(GroupAssetsBy.day), [('tokyo', '2024-04-27'), ('new-york', '2024-04-26')]);
  });

  test('deleting an asset does not pull the next one under a header that is not its own', () async {
    await insertRemote('tokyo', createdAt: DateTime.utc(2024, 4, 26, 23), localDateTime: DateTime.utc(2024, 4, 27, 8));
    await insertRemote(
      'new-york-late',
      createdAt: DateTime.utc(2024, 4, 27, 1),
      localDateTime: DateTime.utc(2024, 4, 26, 20),
    );
    await insertRemote(
      'new-york-early',
      createdAt: DateTime.utc(2024, 4, 27),
      localDateTime: DateTime.utc(2024, 4, 26, 18),
    );

    await db.remoteAssetEntity.deleteWhere((row) => row.id.equals('new-york-late'));

    expect(await headerForEachAsset(GroupAssetsBy.day), [('tokyo', '2024-04-27'), ('new-york-early', '2024-04-26')]);
  });

  test('remote assets without a localDateTime keep their place among the others', () async {
    await insertRemote('newest', createdAt: DateTime.utc(2024, 4, 26, 3), localDateTime: DateTime.utc(2024, 4, 26, 10));
    await insertRemote('no-local-date', createdAt: DateTime(2024, 4, 24, 9));
    await insertRemote('oldest', createdAt: DateTime.utc(2024, 4, 20, 3), localDateTime: DateTime.utc(2024, 4, 20, 10));

    expect(await headerForEachAsset(GroupAssetsBy.day), [
      ('newest', '2024-04-26'),
      ('no-local-date', '2024-04-24'),
      ('oldest', '2024-04-20'),
    ]);
  });

  test('device only assets are interleaved with remote assets by the date shown', () async {
    await insertRemote('remote', createdAt: DateTime.utc(2024, 4, 26, 3), localDateTime: DateTime.utc(2024, 4, 26, 10));
    await insertLocal('device', createdAt: DateTime(2024, 4, 26, 14));
    await insertRemote('older', createdAt: DateTime.utc(2024, 4, 25, 3), localDateTime: DateTime.utc(2024, 4, 25, 10));

    expect(await headerForEachAsset(GroupAssetsBy.day), [
      ('device', '2024-04-26'),
      ('remote', '2024-04-26'),
      ('older', '2024-04-25'),
    ]);
  });

  test('local evening photo sorts with remote same-day rows by shown time', () async {
    // local wall time, mirrors a UTC+7 evening shot among synced rows from the same day
    await insertLocal('local-evening', createdAt: DateTime(2026, 7, 24, 23, 30));
    await insertRemote(
      'remote-evening',
      createdAt: DateTime.utc(2026, 7, 24, 15),
      localDateTime: DateTime.utc(2026, 7, 24, 22),
    );
    await insertRemote(
      'remote-morning',
      createdAt: DateTime.utc(2026, 7, 24, 2),
      localDateTime: DateTime.utc(2026, 7, 24, 9),
    );

    expect(await headerForEachAsset(GroupAssetsBy.day), [
      ('local-evening', '2026-07-24'),
      ('remote-evening', '2026-07-24'),
      ('remote-morning', '2026-07-24'),
    ]);
  });

  test('month grouping keeps every asset under its own month header', () async {
    await insertRemote('may', createdAt: DateTime.utc(2024, 4, 30, 23), localDateTime: DateTime.utc(2024, 5, 1, 8));
    await insertRemote('april', createdAt: DateTime.utc(2024, 5, 1, 1), localDateTime: DateTime.utc(2024, 4, 30, 20));

    expect(await headerForEachAsset(GroupAssetsBy.month), [('may', '2024-05'), ('april', '2024-04')]);
  });
}
