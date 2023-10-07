import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/models/torrent.dart';
import 'package:torrent_frontend/state/transmission.dart';
import 'package:transmission_rpc/transmission_rpc.dart';

final torrentsProvider = StateNotifierProvider<Torrents, TorrentsState>((ref) {
  return Torrents(ref);
});

class Torrents extends StateNotifier<TorrentsState> {
  Torrents(this.ref)
      : transmission = ref.watch(transmissionProvider),
        super(
          const TorrentsState(
            torrents: [],
            uploadSpeeds: {},
            downloadSpeeds: {},
            quickTorrents: [],
            client: ClientState(
              downloadSpeedBytesPerSecond: 0,
              uploadSpeedBytesPerSecond: 0,
              downloadLimitBytesPerSecond: null,
              uploadLimitBytesPerSecond: null,
              alternativeSpeedLimitsEnabled: false,
              freeSpaceBytes: 0,
            ),
          ),
        ) {
    _subscription = ref.listen(transmissionTorrentsProvider, (previous, next) {
      if (next.valueOrNull == null) return;
      _onTransmissionTorrents(next.valueOrNull!);
    });
    _subscription2 = ref.listen(transmissionSessionProvider, (previous, next) {
      if (next.valueOrNull == null) return;
      _onTransmissionSession(next.valueOrNull!);
    });
  }

  final StateNotifierProviderRef<Torrents, TorrentsState> ref;
  final Transmission transmission;
  ProviderSubscription<AsyncValue<List<TransmissionTorrent>>>? _subscription;
  ProviderSubscription<AsyncValue<TransmissionSession>>? _subscription2;

  Future<void> pause(List<int> ids) async {
    if (ids.isEmpty) return;
    await transmission.stopTorrent(ids: ids);
  }

  Future<void> resume(List<int> ids) async {
    if (ids.isEmpty) return;
    await transmission.startTorrent(ids: ids);
    ref.invalidate(transmissionTorrentsProvider);
  }

  Future<void> deleteTorrent(List<int> ids, {required bool deleteData}) async {
    if (ids.isEmpty) return;
    await transmission.removeTorrent(ids: ids, deleteLocalData: deleteData);
    ref.invalidate(transmissionTorrentsProvider);
  }

  Future<void> changePriority(List<int> ids, TorrentPriority newPriority) async {
    if (ids.isEmpty) return;
    await transmission.setTorrents(ids: ids, bandwidthPriority: _priorityToTransPriority(newPriority));
    ref.invalidate(transmissionTorrentsProvider);
  }

  Future<void> setAlternativeLimits({required bool enabled}) async {
    await transmission.setSession(altSpeedEnabled: enabled);
    ref.invalidate(transmissionSessionProvider);
  }

  Future<void> setTorrentsLimit(List<int> ids, int? downloadBytesLimit, int? uploadBytesLimit) async {
    if (ids.isEmpty) return;
    await transmission.setTorrents(
      ids: ids,
      downloadLimit: downloadBytesLimit != null ? downloadBytesLimit ~/ 1024 : null,
      uploadLimit: uploadBytesLimit != null ? uploadBytesLimit ~/ 1024 : null,
      downloadLimited: downloadBytesLimit != null,
      uploadLimited: uploadBytesLimit != null,
    );
    ref.invalidate(transmissionTorrentsProvider);
  }

  Future<void> pauseFiles(int torrentId, List<int> files) async {
    if (files.isEmpty) return;
    await transmission.setTorrents(ids: [torrentId], filesUnwanted: files);
    ref.invalidate(transmissionTorrentsProvider);
  }

  Future<void> resumeFiles(int torrentId, List<int> files) async {
    if (files.isEmpty) return;
    await transmission.setTorrents(ids: [torrentId], filesWanted: files);
    ref.invalidate(transmissionTorrentsProvider);
  }

  TorrentState _transStatusToState(TransmissionTorrent torrent) {
    if (torrent.error != 0) return TorrentState.error;
    return switch (torrent.status!) {
      TransmissionTorrentStatus.downloading => TorrentState.downloading,
      TransmissionTorrentStatus.stopped => torrent.percentDone == 1 ? TorrentState.completed : TorrentState.paused,
      TransmissionTorrentStatus.seeding => TorrentState.seeding,
      TransmissionTorrentStatus.verifying => TorrentState.downloading,
      TransmissionTorrentStatus.queuedToSeed => TorrentState.queued,
      TransmissionTorrentStatus.queuedToVerify => TorrentState.queued,
      TransmissionTorrentStatus.queuedToDownload => TorrentState.queued,
    };
  }

  TorrentPriority _transPriorityToPriority(TransmissionPriority priority) {
    return switch (priority) {
      TransmissionPriority.low => TorrentPriority.low,
      TransmissionPriority.normal => TorrentPriority.normal,
      TransmissionPriority.high => TorrentPriority.high,
    };
  }

  TransmissionPriority _priorityToTransPriority(TorrentPriority priority) {
    return switch (priority) {
      TorrentPriority.low => TransmissionPriority.low,
      TorrentPriority.normal => TransmissionPriority.normal,
      TorrentPriority.high => TransmissionPriority.high,
    };
  }

  void _onTransmissionSession(TransmissionSession session) {
    int? downLimit;
    int? upLimit;

    if (session.altSpeedEnabled!) {
      downLimit = session.altSpeedDown! * 1024;
      upLimit = session.altSpeedUp! * 1024;
    } else {
      downLimit = session.speedLimitDownEnabled! ? session.speedLimitDown! * 1024 : null;
      upLimit = session.speedLimitUpEnabled! ? session.speedLimitUp! * 1024 : null;
    }
    state = state.copyWith(
      client: ClientState(
        downloadSpeedBytesPerSecond: 0, // TODO
        uploadSpeedBytesPerSecond: 0, // TODO
        downloadLimitBytesPerSecond: downLimit,
        uploadLimitBytesPerSecond: upLimit,
        alternativeSpeedLimitsEnabled: session.altSpeedEnabled!,
        freeSpaceBytes: 0, // TODO
      ),
    );
  }

  void _onTransmissionTorrents(List<TransmissionTorrent> torrents) {
    state = state.copyWith(
      downloadSpeeds: torrents.fold(
        {},
        (map, torrent) {
          return {
            ...map,
            torrent.id!: (state.downloadSpeeds[torrent.id] ?? List.generate(39, (index) => 0)).sublist(1)
              ..add(torrent.rateDownload!),
          };
        },
      ),
      uploadSpeeds: torrents.fold(
        {},
        (map, torrent) {
          return {
            ...map,
            torrent.id!: (state.uploadSpeeds[torrent.id] ?? List.generate(39, (index) => 0)).sublist(1)
              ..add(torrent.rateUpload!),
          };
        },
      ),
      quickTorrents: torrents.map(
        (torrent) {
          return TorrentQuickData(
            id: torrent.id!,
            name: torrent.name!,
            downloadedBytes: (torrent.sizeWhenDone! * (torrent.percentDone!)).floor(),
            sizeToDownloadBytes: torrent.sizeWhenDone!,
            sizeBytes: torrent.totalSize!,
            estimatedTimeLeft: torrent.eta!,
            downloadBytesPerSecond: torrent.rateDownload!,
            downloadLimited: torrent.downloadLimited!,
            uploadBytesPerSecond: torrent.rateUpload!,
            uploadLimited: torrent.uploadLimited!,
            state: _transStatusToState(torrent),
            priority: _transPriorityToPriority(torrent.bandwidthPriority!),
            addedOn: torrent.addedDate,
            completedOn: torrent.doneDate,
          );
        },
      ).toList(),
      torrents: torrents.map(
        (torrent) {
          return TorrentData(
            id: torrent.id!,
            name: torrent.name!,
            downloadedBytes: (torrent.sizeWhenDone! * (torrent.percentDone!)).floor(),
            sizeToDownloadBytes: torrent.sizeWhenDone!,
            sizeBytes: torrent.totalSize!,
            estimatedTimeLeft: torrent.eta!,
            downloadBytesPerSecond: torrent.rateDownload!,
            state: _transStatusToState(torrent),
            downloadLimited: torrent.downloadLimited!,
            uploadLimited: torrent.uploadLimited!,
            magnet: torrent.magnetLink,
            torrentFileLocation: torrent.torrentFile,
            downloadLimitBytesPerSecond: torrent.downloadLimit! * 1024,
            uploadLimitBytesPerSecond: torrent.uploadLimit! * 1024,
            priority: _transPriorityToPriority(torrent.bandwidthPriority!),
            uploadedEverBytes: torrent.uploadedEver,
            downloadedEverBytes: torrent.downloadedEver,
            uploadBytesPerSecond: torrent.rateUpload!,
            ratio: torrent.uploadRatio!,
            files: torrent.files!.asMap().entries.map(
              (entry) {
                final i = entry.key;
                final file = entry.value;
                final stats = torrent.fileStats![i];
                return TorrentFileData(
                  name: file.name,
                  downloadedBytes: file.bytesCompleted,
                  sizeBytes: file.length,
                  priority: _transPriorityToPriority(torrent.priorities![i]),
                  state: stats.wanted
                      ? file.bytesCompleted == file.length
                          ? TorrentState.completed
                          : TorrentState.downloading
                      : TorrentState.paused,
                );
              },
            ).toList(),
            completedOn: torrent.doneDate,
            addedOn: torrent.addedDate,
            peers: [''],
            trackers: [''],
            location: torrent.downloadDir,
            lastActivity: torrent.activityDate,
            timeDownloading: (torrent.secondsSeeding ?? 0) > 0 ? Duration(seconds: torrent.secondsDownloading!) : null,
            timeSeeding: (torrent.secondsSeeding ?? 0) > 0 ? Duration(seconds: torrent.secondsSeeding!) : null,
          );
        },
      ).toList(),
    );
  }

  @override
  void dispose() {
    _subscription?.close();
    _subscription2?.close();
    super.dispose();
  }
}

// final torrentDownloadSpeedProvider =
//     StateProvider.family<List<int>, int>((ref, id) {
//   return List.generate(19, (index) => 0);
// });
//
// final torrentUploadSpeedProvider =
//     StateProvider.family<List<int>, int>((ref, id) {
//   return List.generate(19, (index) => 0);
// });
//
// final quickTorrentsProvider = StateProvider<List<TorrentQuickData>>(
//   (ref) {
//     final transmissionTorrents =
//         ref.watch(transmissionTorrentsProvider).valueOrNull ?? [];
//     return transmissionTorrents.map(
//       (torrent) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ref
//               .read(torrentDownloadSpeedProvider(torrent.id!).notifier)
//               .update((s) => s.sublist(1)..add(torrent.rateDownload!));
//         });
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ref
//               .read(torrentUploadSpeedProvider(torrent.id!).notifier)
//               .update((s) => s.sublist(1)..add(torrent.rateUpload!));
//         });
//         return TorrentQuickData(
//           id: torrent.id!,
//           name: torrent.name!,
//           downloadedBytes: torrent.downloadedEver!,
//           sizeToDownloadBytes: torrent.totalSize!,
//           estimatedTimeLeft: torrent.eta!,
//           downloadBytesPerSecond: torrent.rateDownload!,
//           state: TorrentState.downloading,
//           limited: torrent.downloadLimited!,
//           priority: TorrentPriority.high,
//         );
//       },
//     ).toList();
//   },
// );
//
// // final quickTorrentsProvider = StateProvider<List<TorrentQuickData>>(
// //   (ref) => [
// //     const TorrentQuickData(
// //       id: 1,
// //       name: 'Ubuntu',
// //       downloadedBytes: 100000000,
// //       sizeToDownloadBytes: 1000000000,
// //       estimatedTimeLeft: Duration(minutes: 10),
// //       downloadBytesPerSecond: 1000000,
// //       state: TorrentState.downloading,
// //       limited: false,
// //       priority: TorrentPriority.high,
// //     ),
// //   ],
// // );
//
// final torrentsProvider = StateProvider<List<TorrentData>>(
//   (ref) {
//     final transmissionTorrents =
//         ref.watch(transmissionTorrentsProvider).valueOrNull ?? [];
//     return transmissionTorrents
//         .map(
//           (torrent) => TorrentData(
//             id: torrent.id!,
//             name: torrent.name!,
//             downloadedBytes: torrent.downloadedEver!,
//             sizeToDownloadBytes: torrent.totalSize!,
//             sizeBytes: torrent.totalSize!,
//             estimatedTimeLeft: torrent.eta!,
//             downloadBytesPerSecond: torrent.rateDownload!,
//             state: TorrentState.downloading,
//             limited: torrent.downloadLimited!,
//             priority: TorrentPriority.high, // TODO
//             uploadedBytes: torrent.uploadedEver!,
//             uploadBytesPerSecond: torrent.rateUpload!,
//             ratio: torrent.uploadRatio!,
//             files: torrent.files!.asMap().entries.map(
//               (entry) {
//                 final i = entry.key;
//                 final file = entry.value;
//                 final stats = torrent.fileStats![i];
//                 return TorrentFileData(
//                   name: file.name,
//                   wanted: stats.wanted,
//                   downloadedBytes: file.bytesCompleted,
//                   sizeBytes: file.length,
//                   priority: TorrentPriority.high, // TODO
//                 );
//               },
//             ).toList(),
//             completedOn: torrent.doneDate,
//             addedOn: torrent.addedDate!,
//             peers: [''],
//             origin: '',
//             trackers: [''],
//             location: torrent.downloadDir!,
//           ),
//         )
//         .toList();
//   },
// );
//
// // final torrentsProvider = StateProvider<List<TorrentData>>(
// //   (ref) => [
// //     TorrentData(
// //       id: 0,
// //       name: 'Ubuntu',
// //       downloadedBytes: 100000000,
// //       sizeToDownloadBytes: 1000000000,
// //       sizeBytes: 1000000000,
// //       estimatedTimeLeft: const Duration(minutes: 10),
// //       downloadBytesPerSecond: 1000000,
// //       state: TorrentState.downloading,
// //       limited: false,
// //       priority: TorrentPriority.high,
// //       uploadedBytes: 100000000,
// //       uploadBytesPerSecond: 1000000,
// //       ratio: 1,
// //       files: [
// //         const TorrentFileData(
// //           name: 'ubuntu.iso',
// //           wanted: true,
// //           downloadedBytes: 100000000,
// //           sizeBytes: 1000000000,
// //           priority: TorrentPriority.high,
// //         ),
// //       ],
// //       completedOn: DateTime.now(),
// //       addedOn: DateTime.now(),
// //       peers: [''],
// //       origin: '',
// //       trackers: [''],
// //       location: '/sdf/sdf',
// //     ),
// //   ],
// // );
