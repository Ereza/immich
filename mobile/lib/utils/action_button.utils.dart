import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:immich_mobile/constants/enums.dart';
import 'package:immich_mobile/domain/models/album/album.model.dart';
import 'package:immich_mobile/domain/models/asset/base_asset.model.dart';
import 'package:immich_mobile/domain/models/events.model.dart';
import 'package:immich_mobile/domain/services/timeline.service.dart';
import 'package:immich_mobile/domain/utils/event_stream.dart';
import 'package:immich_mobile/presentation/actions/action.widget.dart';
import 'package:immich_mobile/presentation/actions/asset_debug.action.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/archive_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/base_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/cast_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/delete_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/delete_local_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/delete_permanent_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/download_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/like_activity_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/move_to_lock_folder_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/open_in_browser_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/remove_from_album_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/remove_from_lock_folder_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/restore_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/set_album_cover.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/set_profile_picture_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/share_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/share_link_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/similar_photos_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/slideshow_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/trash_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/unarchive_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/unstack_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/upload_action_button.widget.dart';
import 'package:immich_mobile/routing/router.dart';

class ActionButtonContext {
  final BaseAsset asset;
  final bool isOwner;
  final bool isArchived;
  final bool isTrashEnabled;
  final bool isInLockedView;
  final bool isStacked;
  final RemoteAlbum? currentAlbum;
  final bool advancedTroubleshooting;
  final ActionSource source;
  final bool isCasting;
  final TimelineOrigin timelineOrigin;
  final int selectedCount;

  const ActionButtonContext({
    required this.asset,
    required this.isOwner,
    required this.isArchived,
    required this.isTrashEnabled,
    required this.isStacked,
    required this.isInLockedView,
    required this.currentAlbum,
    required this.advancedTroubleshooting,
    required this.source,
    this.isCasting = false,
    this.timelineOrigin = TimelineOrigin.main,
    this.selectedCount = 1,
  });
}

enum ActionButtonType {
  openInfo,
  likeActivity,
  share,
  shareLink,
  cast,
  setAlbumCover,
  similarPhotos,
  setProfilePicture,
  viewInTimeline,
  slideshow,
  download,
  upload,
  openInBrowser,
  unstack,
  archive,
  unarchive,
  moveToLockFolder,
  removeFromLockFolder,
  removeFromAlbum,
  restoreTrash,
  trash,
  deleteLocal,
  deletePermanent,
  delete,
  advancedInfo;

  bool shouldShow(ActionButtonContext context) {
    return switch (this) {
      .advancedInfo => context.advancedTroubleshooting,
      .share => true,
      .shareLink =>
        !context.isInLockedView && //
            context.asset.hasRemote,
      .archive =>
        context.isOwner && //
            !context.isInLockedView && //
            context.asset.hasRemote && //
            !context.isArchived,
      .unarchive =>
        context.isOwner && //
            !context.isInLockedView && //
            context.asset.hasRemote && //
            context.isArchived,
      .download =>
        !context.isInLockedView && //
            context.asset.hasRemote && //
            !context.asset.hasLocal,
      .trash =>
        context.isOwner && //
            !context.isInLockedView && //
            context.asset.hasRemote && //
            context.isTrashEnabled && //
            context.timelineOrigin != .trash,
      .restoreTrash =>
        context.isOwner && //
            !context.isInLockedView && //
            context.asset.hasRemote && //
            context.timelineOrigin == .trash,
      .deletePermanent =>
        context.isOwner && //
            context.asset.hasRemote && //
            (!context.isTrashEnabled || context.timelineOrigin == .trash || context.isInLockedView),
      .delete =>
        context.isOwner && //
            !context.isInLockedView && //
            context.asset.hasRemote,
      .moveToLockFolder =>
        context.isOwner && //
            !context.isInLockedView && //
            context.asset.hasRemote,
      .removeFromLockFolder =>
        context.isOwner && //
            context.isInLockedView && //
            context.asset.hasRemote,
      .deleteLocal =>
        !context.isInLockedView && //
            context.asset.hasLocal,
      .upload =>
        !context.isInLockedView && //
            context.asset.storage == .local,
      .removeFromAlbum =>
        context.isOwner && //
            !context.isInLockedView && //
            context.currentAlbum != null,
      .setAlbumCover =>
        !context.isInLockedView && //
            context.currentAlbum != null && //
            context.selectedCount == 1,
      .unstack =>
        context.isOwner && //
            context.timelineOrigin != .trash &&
            !context.isInLockedView && //
            context.isStacked,
      .openInBrowser => context.asset.hasRemote && !context.isInLockedView,
      .likeActivity =>
        !context.isInLockedView &&
            context.currentAlbum != null &&
            context.currentAlbum!.isActivityEnabled &&
            context.currentAlbum!.isShared,
      .similarPhotos =>
        !context.isInLockedView && //
            context.asset is RemoteAsset,
      .setProfilePicture =>
        !context.isInLockedView && //
            context.asset is RemoteAsset && //
            context.isOwner,
      .openInfo => true,
      .viewInTimeline =>
        context.timelineOrigin != .main &&
            context.timelineOrigin != .deepLink &&
            context.timelineOrigin != .trash &&
            context.timelineOrigin != .lockedFolder &&
            context.timelineOrigin != .archive &&
            context.timelineOrigin != .localAlbum &&
            context.isOwner,
      .cast => context.isCasting || context.asset.hasRemote,
      .slideshow => true,
    };
  }

  Widget buildButton(
    ActionButtonContext context, [
    BuildContext? buildContext,
    bool iconOnly = false,
    bool menuItem = false,
  ]) {
    return switch (this) {
      .advancedInfo => ActionMenuItemWidget(action: AssetDebugAction(assets: [context.asset])),
      .share => ShareActionButton(source: context.source, iconOnly: iconOnly, menuItem: menuItem),
      .shareLink => ShareLinkActionButton(source: context.source, iconOnly: iconOnly, menuItem: menuItem),
      .slideshow => SlideshowActionButton(iconOnly: iconOnly, menuItem: menuItem),
      .archive => ArchiveActionButton(source: context.source, iconOnly: iconOnly, menuItem: menuItem),
      .unarchive => UnArchiveActionButton(source: context.source, iconOnly: iconOnly, menuItem: menuItem),
      .download => DownloadActionButton(source: context.source, iconOnly: iconOnly, menuItem: menuItem),
      .trash => TrashActionButton(source: context.source, iconOnly: iconOnly, menuItem: menuItem),
      .restoreTrash => RestoreActionButton(source: context.source, iconOnly: iconOnly, menuItem: menuItem),
      .deletePermanent => DeletePermanentActionButton(source: context.source, iconOnly: iconOnly, menuItem: menuItem),
      .delete => DeleteActionButton(source: context.source, iconOnly: iconOnly, menuItem: menuItem),
      .moveToLockFolder => MoveToLockFolderActionButton(source: context.source, iconOnly: iconOnly, menuItem: menuItem),
      .removeFromLockFolder => RemoveFromLockFolderActionButton(
        source: context.source,
        iconOnly: iconOnly,
        menuItem: menuItem,
      ),
      .deleteLocal => DeleteLocalActionButton(source: context.source, iconOnly: iconOnly, menuItem: menuItem),
      .upload => UploadActionButton(source: context.source, iconOnly: iconOnly, menuItem: menuItem),
      .removeFromAlbum => RemoveFromAlbumActionButton(
        albumId: context.currentAlbum!.id,
        source: context.source,
        iconOnly: iconOnly,
        menuItem: menuItem,
      ),
      .setAlbumCover => SetAlbumCoverActionButton(
        albumId: context.currentAlbum!.id,
        source: context.source,
        iconOnly: iconOnly,
        menuItem: menuItem,
      ),
      .likeActivity => LikeActivityActionButton(iconOnly: iconOnly, menuItem: menuItem),
      .unstack => UnStackActionButton(source: context.source, iconOnly: iconOnly, menuItem: menuItem),
      .openInBrowser => OpenInBrowserActionButton(
        remoteId: context.asset.remoteId!,
        origin: context.timelineOrigin,
        iconOnly: iconOnly,
        menuItem: menuItem,
      ),
      .similarPhotos => SimilarPhotosActionButton(
        assetId: (context.asset as RemoteAsset).id,
        iconOnly: iconOnly,
        menuItem: menuItem,
      ),
      .setProfilePicture => SetProfilePictureActionButton(asset: context.asset, iconOnly: iconOnly, menuItem: menuItem),
      .openInfo => BaseActionButton(
        label: 'info'.tr(),
        iconData: Icons.info_outline,
        menuItem: true,
        onPressed: () => EventStream.shared.emit(const ViewerShowDetailsEvent()),
      ),
      .viewInTimeline => BaseActionButton(
        label: 'view_in_timeline'.tr(),
        iconData: Icons.image_search,
        iconOnly: iconOnly,
        menuItem: menuItem,
        onPressed: buildContext == null
            ? null
            : () async {
                await buildContext.router.navigate(const TabShellRoute(children: [MainTimelineRoute()]));
                EventStream.shared.emit(ScrollToDateEvent(context.asset.createdAt));
              },
      ),
      .cast => CastActionButton(iconOnly: iconOnly, menuItem: menuItem),
    };
  }

  /// Defines which group each button belongs to for kebab menu.
  /// Buttons in the same group will be displayed together,
  /// with dividers separating different groups.
  int get kebabMenuGroup => switch (this) {
    // 0: info
    .openInfo => 0,
    // 10: move, remove, and delete
    .trash => 10,
    .deletePermanent => 10,
    .removeFromLockFolder => 10,
    .removeFromAlbum => 10,
    .unstack => 10,
    .archive => 10,
    .unarchive => 10,
    .moveToLockFolder => 10,
    .deleteLocal => 10,
    .delete => 10,
    .restoreTrash => 10,
    // 90: advancedInfo
    .advancedInfo => 90,
    // 1: others
    _ => 1,
  };
}

class ActionButtonBuilder {
  static const List<ActionButtonType> _actionTypes = ActionButtonType.values;
  static const List<ActionButtonType> defaultViewerKebabMenuOrder = _actionTypes;
  static const Set<ActionButtonType> defaultViewerBottomBarButtons = {
    ActionButtonType.share,
    ActionButtonType.moveToLockFolder,
    ActionButtonType.upload,
    ActionButtonType.delete,
    ActionButtonType.archive,
    ActionButtonType.unarchive,
    ActionButtonType.restoreTrash,
    ActionButtonType.deletePermanent,
  };

  static List<Widget> build(ActionButtonContext context) {
    return _actionTypes.where((type) => type.shouldShow(context)).map((type) => type.buildButton(context)).toList();
  }

  static List<Widget> buildViewerKebabMenu(ActionButtonContext context, BuildContext buildContext) {
    final visibleButtons = defaultViewerKebabMenuOrder
        .where((type) => !defaultViewerBottomBarButtons.contains(type) && type.shouldShow(context))
        .toList();

    if (visibleButtons.isEmpty) {
      return [];
    }

    final List<Widget> result = [];
    int? lastGroup;

    for (final type in visibleButtons) {
      if (lastGroup != null && type.kebabMenuGroup != lastGroup) {
        result.add(const Divider(height: 1));
      }
      result.add(type.buildButton(context, buildContext, false, true));
      lastGroup = type.kebabMenuGroup;
    }

    return result;
  }
}
