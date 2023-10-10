import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flarrent/models/torrent.dart';
import 'package:flarrent/state/torrents.dart';
import 'package:flarrent/utils/timer_stream.dart';
import 'package:transmission_rpc/transmission_rpc.dart';

class TransmissionTorrents extends Torrents {
  TransmissionTorrents(
    StateNotifierProviderRef<Torrents, TorrentsState> ref, {
    required this.transmission,
  }) : super(
          ref,
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
              connectionString: 'Transmission',
            ),
          ),
        ) {
    _streams = [
      timerStream(const Duration(milliseconds: 500)).listen((_) => _getTransmissionMainTorrents()),
      timerStream(const Duration(milliseconds: 500)).listen((_) => _getTransmissionQuickTorrents()),
      timerStream(const Duration(seconds: 2)).listen((_) => _getTransmissionSession()),
      timerStream(const Duration(seconds: 2)).listen((_) async {
        if (_lastSession?.downloadDir == null) return;

        final freeSpace = await transmission.freeSpace(_lastSession!.downloadDir!);

        state = state.copyWith(
          client: state.client.copyWith(
            freeSpaceBytes: freeSpace.sizeBytes,
          ),
        );
      }),
    ];
  }

  final Transmission transmission;
  List<int> _mainTorrentIds = [];
  late final List<StreamSubscription<void>> _streams;
  TransmissionSession? _lastSession;

  @override
  Future<void> pause(List<int> ids) async {
    if (ids.isEmpty) return;
    await transmission.stopTorrent(ids: ids);
  }

  @override
  Future<void> addTorrentMagnet(String magnet) async {
    await transmission.addTorrent(filename: magnet);
    unawaited(_getTransmissionQuickTorrents());
  }

  @override
  Future<void> addTorrentBase64(String base64) async {
    await transmission.addTorrent(metainfo: base64);
    unawaited(_getTransmissionQuickTorrents());
  }

  @override
  Future<void> resume(List<int> ids) async {
    if (ids.isEmpty) return;
    await transmission.startTorrent(ids: ids);
    unawaited(_getTransmissionQuickTorrents());
    unawaited(_getTransmissionMainTorrents());
  }

  @override
  Future<void> deleteTorrent(List<int> ids, {required bool deleteData}) async {
    if (ids.isEmpty) return;
    await transmission.removeTorrent(ids: ids, deleteLocalData: deleteData);
    unawaited(_getTransmissionQuickTorrents());
    unawaited(_getTransmissionMainTorrents());
  }

  @override
  Future<void> changePriority(List<int> ids, TorrentPriority newPriority) async {
    if (ids.isEmpty) return;
    await transmission.setTorrents(ids: ids, bandwidthPriority: _priorityToTransPriority(newPriority));
    unawaited(_getTransmissionQuickTorrents());
    unawaited(_getTransmissionMainTorrents());
  }

  @override
  Future<void> changeFilePriority(int torrentId, List<int> files, TorrentPriority newPriority) async {
    if (files.isEmpty) return;
    switch (newPriority) {
      case TorrentPriority.low:
        await transmission.setTorrents(
          ids: [torrentId],
          priorityLow: files,
        );
        break;
      case TorrentPriority.normal:
        await transmission.setTorrents(
          ids: [torrentId],
          priorityNormal: files,
        );
        break;
      case TorrentPriority.high:
        await transmission.setTorrents(
          ids: [torrentId],
          priorityHigh: files,
        );
        break;
    }
    unawaited(_getTransmissionQuickTorrents());
    unawaited(_getTransmissionMainTorrents());
  }

  @override
  Future<void> setAlternativeLimits({required bool enabled}) async {
    await transmission.setSession(altSpeedEnabled: enabled);

    unawaited(_getTransmissionSession());
  }

  @override
  Future<void> setTorrentsLimit(List<int> ids, int? downloadBytesLimit, int? uploadBytesLimit) async {
    if (ids.isEmpty) return;
    await transmission.setTorrents(
      ids: ids,
      downloadLimit: downloadBytesLimit != null ? downloadBytesLimit ~/ 1024 : null,
      uploadLimit: uploadBytesLimit != null ? uploadBytesLimit ~/ 1024 : null,
      downloadLimited: downloadBytesLimit != null,
      uploadLimited: uploadBytesLimit != null,
    );
    unawaited(_getTransmissionQuickTorrents());
    unawaited(_getTransmissionMainTorrents());
  }

  @override
  Future<void> pauseFiles(int torrentId, List<int> files) async {
    if (files.isEmpty) return;
    await transmission.setTorrents(ids: [torrentId], filesUnwanted: files);
    unawaited(_getTransmissionQuickTorrents());
    unawaited(_getTransmissionMainTorrents());
  }

  @override
  Future<void> resumeFiles(int torrentId, List<int> files) async {
    if (files.isEmpty) return;
    await transmission.setTorrents(ids: [torrentId], filesWanted: files);
    unawaited(_getTransmissionQuickTorrents());
    unawaited(_getTransmissionMainTorrents());
  }

  @override
  Future<void> setMainTorrents(List<int> torrentIds) async {
    _mainTorrentIds = torrentIds;
    await _getTransmissionMainTorrents();
  }

  @override
  void dispose() {
    for (final stream in _streams) {
      stream.cancel();
    }
    super.dispose();
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

  Future<void> _getTransmissionSession() async {
    final res = await Future.wait([transmission.getSession(), transmission.getSessionStats()]);
    final session = res[0] as TransmissionSession;
    final stats = res[1] as TransmissionSessionStats;
    _lastSession = session;

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
      client: state.client.copyWith(
        downloadSpeedBytesPerSecond: stats.downloadSpeed,
        uploadSpeedBytesPerSecond: stats.uploadSpeed,
        downloadLimitBytesPerSecond: downLimit,
        uploadLimitBytesPerSecond: upLimit,
        alternativeSpeedLimitsEnabled: session.altSpeedEnabled!,
        connectionString: 'Transmission ${session.version}',
      ),
    );
  }

  Future<void> _getTransmissionQuickTorrents() async {
    final torrents = await transmission.getTorrents(
      fields: {
        TransmissionTorrentGetFields.id,
        TransmissionTorrentGetFields.name,
        TransmissionTorrentGetFields.sizeWhenDone,
        TransmissionTorrentGetFields.percentDone,
        TransmissionTorrentGetFields.totalSize,
        TransmissionTorrentGetFields.eta,
        TransmissionTorrentGetFields.rateDownload,
        TransmissionTorrentGetFields.downloadLimited,
        TransmissionTorrentGetFields.rateUpload,
        TransmissionTorrentGetFields.uploadLimited,
        TransmissionTorrentGetFields.status,
        TransmissionTorrentGetFields.error,
        TransmissionTorrentGetFields.bandwidthPriority,
        TransmissionTorrentGetFields.addedDate,
        TransmissionTorrentGetFields.doneDate,
      },
    );

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
    );
  }

  Future<void> _getTransmissionMainTorrents() async {
    final torrents = await transmission.getTorrents(
      ids: _mainTorrentIds,
      fields: {
        TransmissionTorrentGetFields.id,
        TransmissionTorrentGetFields.name,
        TransmissionTorrentGetFields.sizeWhenDone,
        TransmissionTorrentGetFields.percentDone,
        TransmissionTorrentGetFields.totalSize,
        TransmissionTorrentGetFields.eta,
        TransmissionTorrentGetFields.rateDownload,
        TransmissionTorrentGetFields.downloadLimited,
        TransmissionTorrentGetFields.rateUpload,
        TransmissionTorrentGetFields.uploadLimited,
        TransmissionTorrentGetFields.status,
        TransmissionTorrentGetFields.error,
        TransmissionTorrentGetFields.bandwidthPriority,
        TransmissionTorrentGetFields.addedDate,
        TransmissionTorrentGetFields.doneDate,
        TransmissionTorrentGetFields.magnetLink,
        TransmissionTorrentGetFields.torrentFile,
        TransmissionTorrentGetFields.downloadLimit,
        TransmissionTorrentGetFields.uploadLimit,
        TransmissionTorrentGetFields.uploadedEver,
        TransmissionTorrentGetFields.downloadedEver,
        TransmissionTorrentGetFields.uploadRatio,
        TransmissionTorrentGetFields.files,
        TransmissionTorrentGetFields.fileStats,
        TransmissionTorrentGetFields.priorities,
        TransmissionTorrentGetFields.downloadDir,
        TransmissionTorrentGetFields.activityDate,
        TransmissionTorrentGetFields.secondsSeeding,
        TransmissionTorrentGetFields.secondsDownloading,
      },
    );

    state = state.copyWith(
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
            timeDownloading:
                (torrent.secondsDownloading ?? 0) > 0 ? Duration(seconds: torrent.secondsDownloading!) : null,
            timeSeeding: (torrent.secondsSeeding ?? 0) > 0 ? Duration(seconds: torrent.secondsSeeding!) : null,
          );
        },
      ).toList(),
    );
  }
}
