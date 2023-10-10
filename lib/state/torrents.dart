import 'dart:async';

import 'package:flarrent/models/torrent.dart';
import 'package:flarrent/state/config.dart';
import 'package:flarrent/state/transmission.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:transmission_rpc/transmission_rpc.dart';

final torrentsProvider = StateNotifierProvider<Torrents, TorrentsState>((ref) {
  var connection = ref.watch(configProvider.select((c) => c.valueOrNull?.connection)) ?? '';

  var idx = connection.indexOf(':');
  if (idx == -1) {
    connection = defaultConfig.connection!;
    idx = connection.indexOf(':');
  }

  final connectionType = connection.substring(0, idx);
  final data = connection.substring(idx + 1);

  switch (connectionType) {
    case 'transmission':
      return TransmissionTorrents(ref, transmission: Transmission(url: Uri.parse(data)));
    default:
      throw Exception('Unknown connection type: $connectionType');
  }
});

abstract class Torrents extends StateNotifier<TorrentsState> {
  Torrents(this.ref, TorrentsState state) : super(state);

  final StateNotifierProviderRef<Torrents, TorrentsState> ref;

  Future<void> pause(List<int> ids);

  Future<void> addTorrentMagnet(String magnet);

  Future<void> addTorrentBase64(String base64);

  Future<void> resume(List<int> ids);

  Future<void> deleteTorrent(List<int> ids, {required bool deleteData});

  Future<void> changePriority(List<int> ids, TorrentPriority newPriority);

  Future<void> changeFilePriority(int torrentId, List<int> files, TorrentPriority newPriority);

  Future<void> setAlternativeLimits({required bool enabled});

  Future<void> setTorrentsLimit(List<int> ids, int? downloadBytesLimit, int? uploadBytesLimit);

  Future<void> pauseFiles(int torrentId, List<int> files);

  Future<void> resumeFiles(int torrentId, List<int> files);

  Future<void> setMainTorrents(List<int> torrentIds);
}
