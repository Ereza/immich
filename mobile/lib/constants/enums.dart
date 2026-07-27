enum SortOrder {
  asc,
  desc;

  SortOrder reverse() {
    return this == .asc ? .desc : .asc;
  }
}

enum TextSearchType { context, filename, description, ocr }

enum ActionSource { timeline, viewer }

enum ShareAssetType { original, preview }

enum CleanupStep { selectDate, scan, delete }

enum AssetKeepType { none, photosOnly, videosOnly }

enum AssetDateAggregation { start, end }

enum SlideshowLook { contain, cover, blurredBackground }

enum SlideshowDirection { forward, backward, shuffle }

enum PartnerDirection { sharedBy, sharedWith }
