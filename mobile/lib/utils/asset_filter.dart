import 'package:immich_mobile/domain/models/asset/base_asset.model.dart';

extension type const AssetFilter<T extends BaseAsset>(Iterable<T> assets) implements Iterable<T> {
  AssetFilter<T> where(bool Function(T asset) test) => .new(assets.where(test));
  AssetFilter<T> whereNot(bool Function(T asset) test) => .new(assets.where((asset) => !test(asset)));

  AssetFilter<T> type(AssetType type) => where((asset) => asset.type == type);
  AssetFilter<T> favorite({bool isFavorite = true}) => where((asset) => asset.isFavorite == isFavorite);

  AssetFilter<RemoteAsset> remote() => .new(assets.whereType<RemoteAsset>());
  AssetFilter<RemoteAsset> owned(String ownerId) => remote().where((asset) => asset.ownerId == ownerId);
  AssetFilter<RemoteAsset> visibility(AssetVisibility visibility) =>
      remote().where((asset) => asset.visibility == visibility);
  AssetFilter<RemoteAsset> notVisibility(AssetVisibility visibility) =>
      remote().where((asset) => asset.visibility != visibility);
  AssetFilter<RemoteAsset> archived({bool isArchived = true}) =>
      remote().where((asset) => asset.isArchived == isArchived);
  AssetFilter<RemoteAsset> stacked({bool isStacked = true}) => remote().where((asset) => asset.isStacked == isStacked);

  AssetFilter<LocalAsset> local() => .new(assets.whereType<LocalAsset>());
  AssetFilter<LocalAsset> backedUp() => local().where((asset) => asset.remoteAssetId != null);
}
