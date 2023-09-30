import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/models/torrent.dart';
import 'package:torrent_frontend/state/transmission.dart';
import 'package:transmission_rpc/transmission_rpc.dart';

final torrentsProvider = StateNotifierProvider<Torrents, TorrentsState>((ref) {
  return Torrents(ref);
});

class Torrents extends StateNotifier<TorrentsState> {
  final StateNotifierProviderRef<Torrents, TorrentsState> ref;
  final Transmission transmission;
  ProviderSubscription<AsyncValue<List<TransmissionTorrent>>>? _subscription;

  Torrents(this.ref)
      : transmission = ref.watch(transmissionProvider),
        super(
          const TorrentsState(
            torrents: [],
            uploadSpeeds: {},
            downloadSpeeds: {},
            quickTorrents: [],
          ),
        ) {
    _subscription = ref.listen(transmissionTorrentsProvider, (previous, next) {
      _onTransmissionTorrents(next.valueOrNull ?? []);
    });
  }

  Future<void> pause(List<int> ids) async {
    if (ids.isEmpty) return;
    await transmission.stopTorrent(ids: ids);
  }

  Future<void> resume(List<int> ids) async {
    if (ids.isEmpty) return;
    await transmission.startTorrent(ids: ids);
  }

  TorrentState _statusToState(TransmissionTorrent torrent) {
    if (torrent.error != 0) return TorrentState.error;
    return switch (torrent.status!) {
      TransmissionTorrentStatus.downloading => TorrentState.downloading,
      TransmissionTorrentStatus.stopped =>
        torrent.percentDone == 1 ? TorrentState.completed : TorrentState.paused,
      TransmissionTorrentStatus.seeding => TorrentState.seeding,
      TransmissionTorrentStatus.verifying => TorrentState.downloading,
      TransmissionTorrentStatus.queuedToSeed => TorrentState.queued,
      TransmissionTorrentStatus.queuedToVerify => TorrentState.queued,
      TransmissionTorrentStatus.queuedToDownload => TorrentState.queued,
    };
  }

  TorrentPriority _priorityToPriority(TransmissionPriority priority) {
    return switch (priority) {
      TransmissionPriority.low => TorrentPriority.low,
      TransmissionPriority.normal => TorrentPriority.medium,
      TransmissionPriority.high => TorrentPriority.high,
    };
  }

  void _onTransmissionTorrents(List<TransmissionTorrent> torrents) {
    for (final torrent in torrents) {
      state = state.copyWith(
        downloadSpeeds: {
          ...state.downloadSpeeds,
          torrent.id!: (state.downloadSpeeds[torrent.id] ??
                  List.generate(39, (index) => 0))
              .sublist(1)
            ..add(torrent.rateDownload!),
        },
      );
    }

    state = state.copyWith(
      downloadSpeeds: torrents.fold(
        {},
        (map, torrent) {
          return {
            ...map,
            torrent.id!: (state.downloadSpeeds[torrent.id] ??
                    List.generate(39, (index) => 0))
                .sublist(1)
              ..add(torrent.rateDownload!),
          };
        },
      ),
      uploadSpeeds: torrents.fold(
        {},
        (map, torrent) {
          return {
            ...map,
            torrent.id!: (state.uploadSpeeds[torrent.id] ??
                    List.generate(39, (index) => 0))
                .sublist(1)
              ..add(torrent.rateUpload!),
          };
        },
      ),
      quickTorrents: torrents.map(
        (torrent) {
          return TorrentQuickData(
            id: torrent.id!,
            name: torrent.name!,
            downloadedBytes: torrent.downloadedEver!,
            sizeToDownloadBytes: torrent.sizeWhenDone!,
            sizeBytes: torrent.totalSize!,
            estimatedTimeLeft: torrent.eta!,
            downloadBytesPerSecond: torrent.rateDownload!,
            state: _statusToState(torrent),
            limited: torrent.downloadLimited!,
            priority: _priorityToPriority(torrent.bandwidthPriority!),
          );
        },
      ).toList(),
      torrents: torrents.map(
        (torrent) {
          return TorrentData(
            id: torrent.id!,
            name: torrent.name!,
            downloadedBytes: torrent.downloadedEver!,
            sizeToDownloadBytes: torrent.sizeWhenDone!,
            sizeBytes: torrent.totalSize!,
            estimatedTimeLeft: torrent.eta!,
            downloadBytesPerSecond: torrent.rateDownload!,
            state: _statusToState(torrent),
            limited: torrent.downloadLimited!,
            priority: _priorityToPriority(torrent.bandwidthPriority!),
            uploadedBytes: torrent.uploadedEver!,
            uploadBytesPerSecond: torrent.rateUpload!,
            ratio: torrent.uploadRatio!,
            files: torrent.files!.asMap().entries.map(
              (entry) {
                final i = entry.key;
                final file = entry.value;
                final stats = torrent.fileStats![i];
                return TorrentFileData(
                  name: file.name,
                  wanted: stats.wanted,
                  downloadedBytes: file.bytesCompleted,
                  sizeBytes: file.length,
                  priority: _priorityToPriority(torrent.priorities![i]),
                );
              },
            ).toList(),
            completedOn: torrent.doneDate,
            addedOn: torrent.addedDate!,
            peers: [''],
            origin: '',
            trackers: [''],
            location: torrent.downloadDir!,
          );
        },
      ).toList(),
    );
  }

  @override
  void dispose() {
    _subscription?.close();
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
