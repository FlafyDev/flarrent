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
  normal,
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
    required bool downloadLimited,
    required int uploadBytesPerSecond,
    required bool uploadLimited,
    required TorrentState state,
    required TorrentPriority priority,
    DateTime? addedOn,
    DateTime? completedOn,
  }) = _TorrentQuickData;

  factory TorrentQuickData.fromJson(Map<String, Object?> json) => _$TorrentQuickDataFromJson(json);
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
    required bool downloadLimited,
    required bool uploadLimited,
    required int downloadLimitBytesPerSecond,
    required int uploadLimitBytesPerSecond,
    required TorrentPriority priority,
    DateTime? addedOn,
    DateTime? completedOn,
    DateTime? lastActivity,
    String? location,
    String? magnet,
    String? torrentFileLocation,
    required double ratio,
    int? uploadedEverBytes,
    int? downloadedEverBytes,
    Duration? timeDownloading,
    Duration? timeSeeding,
    required List<TorrentFileData> files,
    required List<String> peers,
    required List<String> trackers,
  }) = _TorrentData;

  factory TorrentData.fromJson(Map<String, Object?> json) => _$TorrentDataFromJson(json);
}

@freezed
class TorrentFileData with _$TorrentFileData {
  const factory TorrentFileData({
    required String name,
    required int downloadedBytes,
    required int sizeBytes,
    required TorrentPriority priority,
    required TorrentState state,
  }) = _TorrentFileData;

  factory TorrentFileData.fromJson(Map<String, Object?> json) => _$TorrentFileDataFromJson(json);
}

@freezed
class TorrentsState with _$TorrentsState {
  const factory TorrentsState({
    required ClientState client,
    required Map<int, List<int>> downloadSpeeds,
    required Map<int, List<int>> uploadSpeeds,
    required List<TorrentQuickData> quickTorrents,
    required List<TorrentData> torrents,
  }) = _TorrentsState;

  factory TorrentsState.fromJson(Map<String, Object?> json) => _$TorrentsStateFromJson(json);
}

@freezed
class ClientState with _$ClientState {
  const factory ClientState({
    required int downloadSpeedBytesPerSecond,
    required int uploadSpeedBytesPerSecond,
    required int? downloadLimitBytesPerSecond,
    required int? uploadLimitBytesPerSecond,
    required bool alternativeSpeedLimitsEnabled,
    required int freeSpaceBytes,
  }) = _ClientState;

  factory ClientState.fromJson(Map<String, Object?> json) => _$ClientStateFromJson(json);
}
