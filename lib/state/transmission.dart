import 'package:hooks_riverpod/hooks_riverpod.dart';
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
