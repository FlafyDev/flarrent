import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/models/torrent.dart';

final quickTorrentsProvider = StateProvider<List<TorrentQuickData>>(
  (ref) => [
    const TorrentQuickData(
      id: 1,
      name: 'Ubuntu',
      downloadedBytes: 100000000,
      sizeToDownloadBytes: 1000000000,
      estimatedTimeLeft: Duration(minutes: 10),
      downloadBytesPerSecond: 1000000,
      state: TorrentState.downloading,
      limited: false,
      priority: TorrentPriority.high,
    ),
  ],
);

final torrentsProvider = StateProvider<List<TorrentData>>(
  (ref) => [
    TorrentData(
      id: 0,
      name: 'Ubuntu',
      downloadedBytes: 100000000,
      sizeToDownloadBytes: 1000000000,
      sizeBytes: 1000000000,
      estimatedTimeLeft: const Duration(minutes: 10),
      downloadBytesPerSecond: 1000000,
      state: TorrentState.downloading,
      limited: false,
      priority: TorrentPriority.high,
      uploadedBytes: 100000000,
      uploadBytesPerSecond: 1000000,
      ratio: 1,
      files: [
        const TorrentFileData(
          name: 'ubuntu.iso',
          wanted: true,
          downloadedBytes: 100000000,
          sizeBytes: 1000000000,
          priority: TorrentPriority.high,
        ),
      ],
      completedOn: DateTime.now(),
      addedOn: DateTime.now(),
      peers: [''],
      origin: '',
      trackers: [''],
      location: '/sdf/sdf',
    ),
  ],
);
