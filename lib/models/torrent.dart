import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'torrent.freezed.dart';
part 'torrent.g.dart';

enum TorrentState {
  downloading,
  seeding,
  paused,
  queued,
  completed,
  error,
}

enum TorrentPriority {
  low,
  medium,
  high,
}

@freezed
class TorrentQuickData with _$TorrentQuickData {
  const factory TorrentQuickData({
    required int id,
    required String name,
    required int downloadedBytes,
    required int sizeToDownloadBytes,
    required int sizeBytes,
    required Duration estimatedTimeLeft,
    required int downloadBytesPerSecond,
    required TorrentState state,
    required bool limited,
    required TorrentPriority priority,
  }) = _TorrentQuickData;

  factory TorrentQuickData.fromJson(Map<String, Object?> json)
      => _$TorrentQuickDataFromJson(json);
}

@freezed
class TorrentData with _$TorrentData {
  const factory TorrentData({
    required int id,
    required String name,
    required int downloadedBytes,
    required int sizeToDownloadBytes,
    required int sizeBytes,
    required Duration estimatedTimeLeft,
    required int downloadBytesPerSecond,
    required int uploadBytesPerSecond,
    required TorrentState state,
    required bool limited,
    required TorrentPriority priority,
    required DateTime addedOn,
    required DateTime? completedOn,
    required String location,
    required double ratio,
    required int uploadedBytes,
    required String origin,
    required List<TorrentFileData> files,
    required List<String> peers,
    required List<String> trackers,
  }) = _TorrentData;

  factory TorrentData.fromJson(Map<String, Object?> json)
      => _$TorrentDataFromJson(json);
}

@freezed
class TorrentFileData with _$TorrentFileData {
  const factory TorrentFileData({
    required String name,
    required bool wanted,
    required int downloadedBytes,
    required int sizeBytes,
    required TorrentPriority priority,
  }) = _TorrentFileData;

  factory TorrentFileData.fromJson(Map<String, Object?> json)
      => _$TorrentFileDataFromJson(json);
}


@freezed
class TorrentsState with _$TorrentsState {
  const factory TorrentsState({
    required Map<int, List<int>> downloadSpeeds,
    required Map<int, List<int>> uploadSpeeds,
    required List<TorrentQuickData> quickTorrents,
    required List<TorrentData> torrents,
  }) = _TorrentsState;

  factory TorrentsState.fromJson(Map<String, Object?> json)
      => _$TorrentsStateFromJson(json);
}
