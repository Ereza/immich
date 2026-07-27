import 'package:easy_localization/easy_localization.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  error;

  localized() {
    return switch (this) {
      .idle => "idle".tr(),
      .syncing => "running".tr(),
      .success => "success".tr(),
      .error => "error".tr(),
    };
  }
}

class SyncStatusState {
  final SyncStatus remoteSyncStatus;
  final SyncStatus localSyncStatus;
  final SyncStatus hashJobStatus;
  final SyncStatus cloudIdSyncStatus;

  final String? errorMessage;

  const SyncStatusState({
    this.remoteSyncStatus = SyncStatus.idle,
    this.localSyncStatus = SyncStatus.idle,
    this.hashJobStatus = SyncStatus.idle,
    this.cloudIdSyncStatus = SyncStatus.idle,
    this.errorMessage,
  });

  SyncStatusState copyWith({
    SyncStatus? remoteSyncStatus,
    SyncStatus? localSyncStatus,
    SyncStatus? hashJobStatus,
    SyncStatus? cloudIdSyncStatus,
    String? errorMessage,
  }) {
    return SyncStatusState(
      remoteSyncStatus: remoteSyncStatus ?? this.remoteSyncStatus,
      localSyncStatus: localSyncStatus ?? this.localSyncStatus,
      hashJobStatus: hashJobStatus ?? this.hashJobStatus,
      cloudIdSyncStatus: cloudIdSyncStatus ?? this.cloudIdSyncStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isRemoteSyncing => remoteSyncStatus == .syncing;
  bool get isLocalSyncing => localSyncStatus == .syncing;
  bool get isHashing => hashJobStatus == .syncing;
  bool get isCloudIdSyncing => cloudIdSyncStatus == .syncing;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is SyncStatusState &&
        other.remoteSyncStatus == remoteSyncStatus &&
        other.localSyncStatus == localSyncStatus &&
        other.hashJobStatus == hashJobStatus &&
        other.cloudIdSyncStatus == cloudIdSyncStatus &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(remoteSyncStatus, localSyncStatus, hashJobStatus, cloudIdSyncStatus, errorMessage);
}

class SyncStatusNotifier extends Notifier<SyncStatusState> {
  @override
  SyncStatusState build() {
    return const SyncStatusState(
      errorMessage: null,
      remoteSyncStatus: .idle,
      localSyncStatus: .idle,
      hashJobStatus: .idle,
      cloudIdSyncStatus: .idle,
    );
  }

  ///
  /// Remote Sync
  ///

  void setRemoteSyncStatus(SyncStatus status, [String? errorMessage]) {
    state = state.copyWith(remoteSyncStatus: status, errorMessage: status == .error ? errorMessage : null);
  }

  void startRemoteSync() => setRemoteSyncStatus(.syncing);
  void completeRemoteSync() => setRemoteSyncStatus(.success);
  void errorRemoteSync(String error) => setRemoteSyncStatus(.error, error);

  ///
  /// Local Sync
  ///

  void setLocalSyncStatus(SyncStatus status, [String? errorMessage]) {
    state = state.copyWith(localSyncStatus: status, errorMessage: status == .error ? errorMessage : null);
  }

  void startLocalSync() => setLocalSyncStatus(.syncing);
  void completeLocalSync() => setLocalSyncStatus(.success);
  void errorLocalSync(String error) => setLocalSyncStatus(.error, error);

  ///
  /// Hash Job
  ///

  void setHashJobStatus(SyncStatus status, [String? errorMessage]) {
    state = state.copyWith(hashJobStatus: status, errorMessage: status == .error ? errorMessage : null);
  }

  void startHashJob() => setHashJobStatus(.syncing);
  void completeHashJob() => setHashJobStatus(.success);
  void errorHashJob(String error) => setHashJobStatus(.error, error);

  ///
  /// Cloud ID Sync Job
  ///

  void setCloudIdSyncStatus(SyncStatus status, [String? errorMessage]) {
    state = state.copyWith(cloudIdSyncStatus: status, errorMessage: status == .error ? errorMessage : null);
  }

  void startCloudIdSync() => setCloudIdSyncStatus(.syncing);
  void completeCloudIdSync() => setCloudIdSyncStatus(.success);
  void errorCloudIdSync(String error) => setCloudIdSyncStatus(.error, error);
}

final syncStatusProvider = NotifierProvider<SyncStatusNotifier, SyncStatusState>(SyncStatusNotifier.new);
