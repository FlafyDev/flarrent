import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/models/torrent.dart';
import 'package:transmission_rpc/transmission_rpc.dart';

final transmissionProvider = Provider(
  (ref) => Transmission(),
);

Stream<dynamic> counterStream() async* {
  yield 0;
  yield* Stream.periodic(const Duration(milliseconds: 500), (i) => 1 + i);
}

final transmissionTorrentsProvider = StreamProvider(
  (ref) async* {
    final transmission = ref.watch(transmissionProvider);

    await for (final _ in counterStream()) {
      yield await transmission.getTorrents();
    }
  },
);

final transmissionSessionProvider = StreamProvider(
  (ref) async* {
    final transmission = ref.watch(transmissionProvider);

    await for (final _ in counterStream()) {
      yield await transmission.getSession();
    }
  },
);

// extension TransmissionConverters on TransmissionTorrent {
//   TorrentState getTorrentStatus() {
//     if (error != 0) return TorrentState.error;
//     return switch (status!) {
//       TransmissionTorrentStatus.downloading => TorrentState.downloading,
//       TransmissionTorrentStatus.stopped => percentDone == 1 ? TorrentState.completed : TorrentState.paused,
//       TransmissionTorrentStatus.seeding => TorrentState.seeding,
//       TransmissionTorrentStatus.verifying => TorrentState.downloading,
//       TransmissionTorrentStatus.queuedToSeed => TorrentState.queued,
//       TransmissionTorrentStatus.queuedToVerify => TorrentState.queued,
//       TransmissionTorrentStatus.queuedToDownload => TorrentState.queued,
//     };
//   }
//
//   TorrentPriority getTorrentPriority() {
//     return switch (bandwidthPriority!) {
//       TransmissionPriority.low => TorrentPriority.low,
//       TransmissionPriority.normal => TorrentPriority.normal,
//       TransmissionPriority.high => TorrentPriority.high,
//     };
//   }
// }

// final torrentsProvider = Provider((ref) {
//   final transmissionTorrents = ref.watch(transmissionTorrentsProvider);
//   transmissionTorrents.when(
//     data: (torrents) {
//       return torrents.map(
//         (torrent) {
//           return Torrent(
//             name: torrent.name,
//             downloadSpeed: torrent.rateDownload,
//             uploadSpeed: torrent.rateUpload,
//
//
//
//             timeLeft: DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
//           )
//         },
//       );
//     },
//   );
// });
