import 'package:immich_mobile/constants/enums.dart';

// Store index allows us to re-arrange the values without affecting the saved prefs
enum AlbumSortMode {
  title(1, "library_page_sort_title", .asc),
  assetCount(4, "library_page_sort_asset_count", .desc),
  lastModified(3, "library_page_sort_last_modified", .desc),
  created(0, "library_page_sort_created", .desc),
  mostRecent(2, "sort_recent", .desc),
  mostOldest(5, "sort_oldest", .asc);

  final int storeIndex;
  final String label;
  final SortOrder defaultOrder;

  const AlbumSortMode(this.storeIndex, this.label, this.defaultOrder);

  SortOrder effectiveOrder(bool isReverse) => isReverse ? defaultOrder.reverse() : defaultOrder;
}
