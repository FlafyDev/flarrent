// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'torrent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_TorrentQuickData _$$_TorrentQuickDataFromJson(Map<String, dynamic> json) =>
    _$_TorrentQuickData(
      id: json['id'] as int,
      name: json['name'] as String,
      downloadedBytes: json['downloadedBytes'] as int,
      sizeToDownloadBytes: json['sizeToDownloadBytes'] as int,
      sizeBytes: json['sizeBytes'] as int,
      estimatedTimeLeft:
          Duration(microseconds: json['estimatedTimeLeft'] as int),
      downloadBytesPerSecond: json['downloadBytesPerSecond'] as int,
      downloadLimited: json['downloadLimited'] as bool,
      uploadBytesPerSecond: json['uploadBytesPerSecond'] as int,
      uploadLimited: json['uploadLimited'] as bool,
      state: $enumDecode(_$TorrentStateEnumMap, json['state']),
      priority: $enumDecode(_$TorrentPriorityEnumMap, json['priority']),
    );

Map<String, dynamic> _$$_TorrentQuickDataToJson(_$_TorrentQuickData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'downloadedBytes': instance.downloadedBytes,
      'sizeToDownloadBytes': instance.sizeToDownloadBytes,
      'sizeBytes': instance.sizeBytes,
      'estimatedTimeLeft': instance.estimatedTimeLeft.inMicroseconds,
      'downloadBytesPerSecond': instance.downloadBytesPerSecond,
      'downloadLimited': instance.downloadLimited,
      'uploadBytesPerSecond': instance.uploadBytesPerSecond,
      'uploadLimited': instance.uploadLimited,
      'state': _$TorrentStateEnumMap[instance.state]!,
      'priority': _$TorrentPriorityEnumMap[instance.priority]!,
    };

const _$TorrentStateEnumMap = {
  TorrentState.downloading: 'downloading',
  TorrentState.seeding: 'seeding',
  TorrentState.paused: 'paused',
  TorrentState.queued: 'queued',
  TorrentState.completed: 'completed',
  TorrentState.error: 'error',
};

const _$TorrentPriorityEnumMap = {
  TorrentPriority.low: 'low',
  TorrentPriority.normal: 'normal',
  TorrentPriority.high: 'high',
};

_$_TorrentData _$$_TorrentDataFromJson(Map<String, dynamic> json) =>
    _$_TorrentData(
      id: json['id'] as int,
      name: json['name'] as String,
      downloadedBytes: json['downloadedBytes'] as int,
      sizeToDownloadBytes: json['sizeToDownloadBytes'] as int,
      sizeBytes: json['sizeBytes'] as int,
      estimatedTimeLeft:
          Duration(microseconds: json['estimatedTimeLeft'] as int),
      downloadBytesPerSecond: json['downloadBytesPerSecond'] as int,
      uploadBytesPerSecond: json['uploadBytesPerSecond'] as int,
      state: $enumDecode(_$TorrentStateEnumMap, json['state']),
      downloadLimited: json['downloadLimited'] as bool,
      uploadLimited: json['uploadLimited'] as bool,
      downloadLimitBytesPerSecond: json['downloadLimitBytesPerSecond'] as int,
      uploadLimitBytesPerSecond: json['uploadLimitBytesPerSecond'] as int,
      priority: $enumDecode(_$TorrentPriorityEnumMap, json['priority']),
      addedOn: json['addedOn'] == null
          ? null
          : DateTime.parse(json['addedOn'] as String),
      completedOn: json['completedOn'] == null
          ? null
          : DateTime.parse(json['completedOn'] as String),
      lastActivity: json['lastActivity'] == null
          ? null
          : DateTime.parse(json['lastActivity'] as String),
      location: json['location'] as String?,
      magnet: json['magnet'] as String?,
      torrentFileLocation: json['torrentFileLocation'] as String?,
      ratio: (json['ratio'] as num).toDouble(),
      uploadedEverBytes: json['uploadedEverBytes'] as int?,
      downloadedEverBytes: json['downloadedEverBytes'] as int?,
      timeDownloading: json['timeDownloading'] == null
          ? null
          : Duration(microseconds: json['timeDownloading'] as int),
      timeSeeding: json['timeSeeding'] == null
          ? null
          : Duration(microseconds: json['timeSeeding'] as int),
      files: (json['files'] as List<dynamic>)
          .map((e) => TorrentFileData.fromJson(e as Map<String, dynamic>))
          .toList(),
      peers: (json['peers'] as List<dynamic>).map((e) => e as String).toList(),
      trackers:
          (json['trackers'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$_TorrentDataToJson(_$_TorrentData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'downloadedBytes': instance.downloadedBytes,
      'sizeToDownloadBytes': instance.sizeToDownloadBytes,
      'sizeBytes': instance.sizeBytes,
      'estimatedTimeLeft': instance.estimatedTimeLeft.inMicroseconds,
      'downloadBytesPerSecond': instance.downloadBytesPerSecond,
      'uploadBytesPerSecond': instance.uploadBytesPerSecond,
      'state': _$TorrentStateEnumMap[instance.state]!,
      'downloadLimited': instance.downloadLimited,
      'uploadLimited': instance.uploadLimited,
      'downloadLimitBytesPerSecond': instance.downloadLimitBytesPerSecond,
      'uploadLimitBytesPerSecond': instance.uploadLimitBytesPerSecond,
      'priority': _$TorrentPriorityEnumMap[instance.priority]!,
      'addedOn': instance.addedOn?.toIso8601String(),
      'completedOn': instance.completedOn?.toIso8601String(),
      'lastActivity': instance.lastActivity?.toIso8601String(),
      'location': instance.location,
      'magnet': instance.magnet,
      'torrentFileLocation': instance.torrentFileLocation,
      'ratio': instance.ratio,
      'uploadedEverBytes': instance.uploadedEverBytes,
      'downloadedEverBytes': instance.downloadedEverBytes,
      'timeDownloading': instance.timeDownloading?.inMicroseconds,
      'timeSeeding': instance.timeSeeding?.inMicroseconds,
      'files': instance.files,
      'peers': instance.peers,
      'trackers': instance.trackers,
    };

_$_TorrentFileData _$$_TorrentFileDataFromJson(Map<String, dynamic> json) =>
    _$_TorrentFileData(
      name: json['name'] as String,
      downloadedBytes: json['downloadedBytes'] as int,
      sizeBytes: json['sizeBytes'] as int,
      priority: $enumDecode(_$TorrentPriorityEnumMap, json['priority']),
      state: $enumDecode(_$TorrentStateEnumMap, json['state']),
    );

Map<String, dynamic> _$$_TorrentFileDataToJson(_$_TorrentFileData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'downloadedBytes': instance.downloadedBytes,
      'sizeBytes': instance.sizeBytes,
      'priority': _$TorrentPriorityEnumMap[instance.priority]!,
      'state': _$TorrentStateEnumMap[instance.state]!,
    };

_$_TorrentsState _$$_TorrentsStateFromJson(Map<String, dynamic> json) =>
    _$_TorrentsState(
      downloadSpeedBytesPerSecond: json['downloadSpeedBytesPerSecond'] as int,
      uploadSpeedBytesPerSecond: json['uploadSpeedBytesPerSecond'] as int,
      downloadLimitBytesPerSecond: json['downloadLimitBytesPerSecond'] as int?,
      uploadLimitBytesPerSecond: json['uploadLimitBytesPerSecond'] as int?,
      alternativeSpeedLimitsEnabled:
          json['alternativeSpeedLimitsEnabled'] as bool,
      downloadSpeeds: (json['downloadSpeeds'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            int.parse(k), (e as List<dynamic>).map((e) => e as int).toList()),
      ),
      uploadSpeeds: (json['uploadSpeeds'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            int.parse(k), (e as List<dynamic>).map((e) => e as int).toList()),
      ),
      quickTorrents: (json['quickTorrents'] as List<dynamic>)
          .map((e) => TorrentQuickData.fromJson(e as Map<String, dynamic>))
          .toList(),
      torrents: (json['torrents'] as List<dynamic>)
          .map((e) => TorrentData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_TorrentsStateToJson(_$_TorrentsState instance) =>
    <String, dynamic>{
      'downloadSpeedBytesPerSecond': instance.downloadSpeedBytesPerSecond,
      'uploadSpeedBytesPerSecond': instance.uploadSpeedBytesPerSecond,
      'downloadLimitBytesPerSecond': instance.downloadLimitBytesPerSecond,
      'uploadLimitBytesPerSecond': instance.uploadLimitBytesPerSecond,
      'alternativeSpeedLimitsEnabled': instance.alternativeSpeedLimitsEnabled,
      'downloadSpeeds':
          instance.downloadSpeeds.map((k, e) => MapEntry(k.toString(), e)),
      'uploadSpeeds':
          instance.uploadSpeeds.map((k, e) => MapEntry(k.toString(), e)),
      'quickTorrents': instance.quickTorrents,
      'torrents': instance.torrents,
    };
