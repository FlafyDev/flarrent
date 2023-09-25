import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/models/torrent.dart';
import 'package:torrent_frontend/state/transmission.dart';

final selectedTorrentId = StateProvider<int?>((ref) => null);

final torrentDownloadSpeedProvider =
    StateProvider.family<List<int>, int>((ref, id) {
  return List.generate(19, (index) => 0);
});

final torrentUploadSpeedProvider =
    StateProvider.family<List<int>, int>((ref, id) {
  return List.generate(19, (index) => 0);
});

final quickTorrentsProvider = StateProvider<List<TorrentQuickData>>(
  (ref) {
    final transmissionTorrents =
        ref.watch(transmissionTorrentsProvider).valueOrNull ?? [];
    return transmissionTorrents.map(
      (torrent) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(torrentDownloadSpeedProvider(torrent.id!).notifier)
              .update((s) => s.sublist(1)..add(torrent.rateDownload!));
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(torrentUploadSpeedProvider(torrent.id!).notifier)
              .update((s) => s.sublist(1)..add(torrent.rateUpload!));
        });
        return TorrentQuickData(
          id: torrent.id!,
          name: torrent.name!,
          downloadedBytes: torrent.downloadedEver!,
          sizeToDownloadBytes: torrent.totalSize!,
          estimatedTimeLeft: torrent.eta!,
          downloadBytesPerSecond: torrent.rateDownload!,
          state: TorrentState.downloading,
          limited: torrent.downloadLimited!,
          priority: TorrentPriority.high,
        );
      },
    ).toList();
  },
);

// final quickTorrentsProvider = StateProvider<List<TorrentQuickData>>(
//   (ref) => [
//     const TorrentQuickData(
//       id: 1,
//       name: 'Ubuntu',
//       downloadedBytes: 100000000,
//       sizeToDownloadBytes: 1000000000,
//       estimatedTimeLeft: Duration(minutes: 10),
//       downloadBytesPerSecond: 1000000,
//       state: TorrentState.downloading,
//       limited: false,
//       priority: TorrentPriority.high,
//     ),
//   ],
// );

final torrentsProvider = StateProvider<List<TorrentData>>(
  (ref) {
    final transmissionTorrents =
        ref.watch(transmissionTorrentsProvider).valueOrNull ?? [];
    return transmissionTorrents
        .map(
          (torrent) => TorrentData(
            id: torrent.id!,
            name: torrent.name!,
            downloadedBytes: torrent.downloadedEver!,
            sizeToDownloadBytes: torrent.totalSize!,
            sizeBytes: torrent.totalSize!,
            estimatedTimeLeft: torrent.eta!,
            downloadBytesPerSecond: torrent.rateDownload!,
            state: TorrentState.downloading,
            limited: torrent.downloadLimited!,
            priority: TorrentPriority.high,
            uploadedBytes: torrent.uploadedEver!,
            uploadBytesPerSecond: torrent.rateUpload!,
            ratio: torrent.uploadRatio!,
            files: [
              const TorrentFileData(
                name: 'ubuntu.iso',
                wanted: true,
                downloadedBytes: 100000000,
                sizeBytes: 1000000000,
                priority: TorrentPriority.high,
              ),
            ],
            completedOn: torrent.doneDate,
            addedOn: torrent.addedDate!,
            peers: [''],
            origin: '',
            trackers: [''],
            location: torrent.downloadDir!,
          ),
        )
        .toList();
  },
);

// final torrentsProvider = StateProvider<List<TorrentData>>(
//   (ref) => [
//     TorrentData(
//       id: 0,
//       name: 'Ubuntu',
//       downloadedBytes: 100000000,
//       sizeToDownloadBytes: 1000000000,
//       sizeBytes: 1000000000,
//       estimatedTimeLeft: const Duration(minutes: 10),
//       downloadBytesPerSecond: 1000000,
//       state: TorrentState.downloading,
//       limited: false,
//       priority: TorrentPriority.high,
//       uploadedBytes: 100000000,
//       uploadBytesPerSecond: 1000000,
//       ratio: 1,
//       files: [
//         const TorrentFileData(
//           name: 'ubuntu.iso',
//           wanted: true,
//           downloadedBytes: 100000000,
//           sizeBytes: 1000000000,
//           priority: TorrentPriority.high,
//         ),
//       ],
//       completedOn: DateTime.now(),
//       addedOn: DateTime.now(),
//       peers: [''],
//       origin: '',
//       trackers: [''],
//       location: '/sdf/sdf',
//     ),
//   ],
// );
