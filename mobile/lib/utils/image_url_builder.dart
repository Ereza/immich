import 'package:immich_mobile/entities/store.entity.dart';
import 'package:openapi/api.dart';

String getOriginalUrlForRemoteId(final String id, {bool edited = true}) {
  return '${Store.get(.serverEndpoint)}/assets/$id/original?edited=$edited';
}

String getThumbnailUrlForRemoteId(
  final String id, {
  AssetMediaSize type = .thumbnail,
  bool edited = true,
  String? thumbhash,
}) {
  final url = '${Store.get(.serverEndpoint)}/assets/$id/thumbnail?size=${type.toString()}&edited=$edited';
  return thumbhash != null ? '$url&c=${Uri.encodeComponent(thumbhash)}' : url;
}

String getPlaybackUrlForRemoteId(final String id) {
  return '${Store.get(.serverEndpoint)}/assets/$id/video/playback?';
}

String getFaceThumbnailUrl(final String personId) {
  return '${Store.get(.serverEndpoint)}/people/$personId/thumbnail';
}
