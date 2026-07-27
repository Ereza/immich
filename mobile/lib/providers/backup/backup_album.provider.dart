import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/domain/models/album/local_album.model.dart';
import 'package:immich_mobile/domain/services/local_album.service.dart';
import 'package:immich_mobile/providers/infrastructure/album.provider.dart';

final backupAlbumProvider = StateNotifierProvider<BackupAlbumNotifier, List<LocalAlbum>>(
  (ref) => BackupAlbumNotifier(ref.watch(localAlbumServiceProvider)),
);

class BackupAlbumNotifier extends StateNotifier<List<LocalAlbum>> {
  BackupAlbumNotifier(this._localAlbumService) : super([]) {
    getAll();
  }

  final LocalAlbumService _localAlbumService;

  Future<void> getAll() async {
    state = await _localAlbumService.getAll(sortBy: {.assetCount});
  }

  Future<void> selectAlbum(LocalAlbum album) async {
    album = album.copyWith(backupSelection: .selected);
    await _localAlbumService.update(album);

    state = state
        .map(
          (currentAlbum) =>
              currentAlbum.id == album.id ? currentAlbum.copyWith(backupSelection: .selected) : currentAlbum,
        )
        .toList();
  }

  Future<void> deselectAlbum(LocalAlbum album) async {
    album = album.copyWith(backupSelection: .none);
    await _localAlbumService.update(album);

    state = state
        .map(
          (currentAlbum) => currentAlbum.id == album.id ? currentAlbum.copyWith(backupSelection: .none) : currentAlbum,
        )
        .toList();
  }

  Future<void> excludeAlbum(LocalAlbum album) async {
    album = album.copyWith(backupSelection: .excluded);
    await _localAlbumService.update(album);

    state = state
        .map(
          (currentAlbum) =>
              currentAlbum.id == album.id ? currentAlbum.copyWith(backupSelection: .excluded) : currentAlbum,
        )
        .toList();
  }
}
