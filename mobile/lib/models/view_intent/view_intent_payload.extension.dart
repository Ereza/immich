import 'package:immich_mobile/domain/models/asset/base_asset.model.dart';
import 'package:immich_mobile/platform/view_intent_api.g.dart';
import 'package:path/path.dart';

extension ViewIntentPayloadX on ViewIntentPayload {
  String get fileName {
    final resolvedPath = path;
    if (resolvedPath != null && resolvedPath.isNotEmpty) {
      return basename(resolvedPath);
    }
    return localAssetId ?? 'view_intent_asset';
  }

  bool get isImage => mimeType.toLowerCase().startsWith('image/');

  bool get isVideo => mimeType.toLowerCase().startsWith('video/');

  AssetPlaybackStyle get playbackStyle {
    if (isVideo) {
      return .video;
    }

    final normalizedMimeType = mimeType.toLowerCase();
    if (normalizedMimeType == 'image/gif' || normalizedMimeType == 'image/webp') {
      return .imageAnimated;
    }

    final normalizedPath = path?.toLowerCase();
    if (normalizedPath != null && (normalizedPath.endsWith('.gif') || normalizedPath.endsWith('.webp'))) {
      return .imageAnimated;
    }

    return .image;
  }
}
