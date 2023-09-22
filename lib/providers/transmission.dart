import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:transmission/transmission.dart';

final transmissionProvider = Provider(
  (ref) => Transmission(
    baseUrl: 'http://127.0.0.1:9091/transmission/rpc',
    enableLog: false,
  ),
);

final transmissionRefreshDelayProvider =
    Provider((ref) => const Duration(seconds: 1));

final transmissionTorrentsProvider = StreamProvider(
  (ref) async* {
    final transmission = ref.watch(transmissionProvider);
    final refreshDelay = ref.watch(transmissionRefreshDelayProvider);

    await for (final _ in Stream<Duration>.periodic(refreshDelay)) {
      yield await transmission.getTorrents();
    }
  },
);

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
