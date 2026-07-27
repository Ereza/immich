import 'package:immich_mobile/domain/models/asset/base_asset.model.dart';
import 'package:immich_mobile/domain/models/exif.model.dart';
import 'package:immich_mobile/infrastructure/utils/exif.converter.dart';
import 'package:openapi/api.dart' as api;

extension DTOToAsset on api.AssetResponseDto {
  RemoteAsset toDto() {
    return RemoteAsset(
      id: id,
      name: originalFileName,
      checksum: checksum,
      createdAt: fileCreatedAt,
      updatedAt: updatedAt,
      uploadedAt: createdAt,
      ownerId: ownerId,
      visibility: visibility.toAssetVisibility(),
      durationMs: duration,
      height: height?.toInt(),
      width: width?.toInt(),
      isFavorite: isFavorite,
      livePhotoVideoId: livePhotoVideoId.orElse(null),
      thumbHash: thumbhash,
      localId: null,
      type: type.toAssetType(),
      stackId: stack.orElse(null)?.id,
      isEdited: isEdited,
    );
  }

  RemoteAssetExif toDtoWithExif() {
    return RemoteAssetExif(
      id: id,
      name: originalFileName,
      checksum: checksum,
      createdAt: fileCreatedAt,
      updatedAt: updatedAt,
      uploadedAt: createdAt,
      ownerId: ownerId,
      visibility: visibility.toAssetVisibility(),
      durationMs: duration,
      height: height?.toInt(),
      width: width?.toInt(),
      isFavorite: isFavorite,
      livePhotoVideoId: livePhotoVideoId.orElse(null),
      thumbHash: thumbhash,
      localId: null,
      type: type.toAssetType(),
      stackId: stack.orElse(null)?.id,
      isEdited: isEdited,
      exifInfo: exifInfo.orElse(null) != null ? ExifDtoConverter.fromDto(exifInfo.orElse(null)!) : const ExifInfo(),
    );
  }
}

extension on api.AssetVisibility {
  AssetVisibility toAssetVisibility() => switch (this) {
    api.AssetVisibility.timeline => .timeline,
    api.AssetVisibility.hidden => .hidden,
    api.AssetVisibility.archive => .archive,
    api.AssetVisibility.locked => .locked,
  };
}

extension on api.AssetTypeEnum {
  AssetType toAssetType() => switch (this) {
    api.AssetTypeEnum.IMAGE => .image,
    api.AssetTypeEnum.VIDEO => .video,
    api.AssetTypeEnum.AUDIO => .audio,
    api.AssetTypeEnum.OTHER => .other,
  };
}
