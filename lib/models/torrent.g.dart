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
      estimatedTimeLeft:
          Duration(microseconds: json['estimatedTimeLeft'] as int),
      downloadBytesPerSecond: json['downloadBytesPerSecond'] as int,
      state: $enumDecode(_$TorrentStateEnumMap, json['state']),
      limited: json['limited'] as bool,
      priority: $enumDecode(_$TorrentPriorityEnumMap, json['priority']),
    );

Map<String, dynamic> _$$_TorrentQuickDataToJson(_$_TorrentQuickData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'downloadedBytes': instance.downloadedBytes,
      'sizeToDownloadBytes': instance.sizeToDownloadBytes,
      'estimatedTimeLeft': instance.estimatedTimeLeft.inMicroseconds,
      'downloadBytesPerSecond': instance.downloadBytesPerSecond,
      'state': _$TorrentStateEnumMap[instance.state]!,
      'limited': instance.limited,
      'priority': _$TorrentPriorityEnumMap[instance.priority]!,
    };

const _$TorrentStateEnumMap = {
  TorrentState.downloading: 'downloading',
  TorrentState.seeding: 'seeding',
  TorrentState.paused: 'paused',
  TorrentState.queued: 'queued',
  TorrentState.completed: 'completed',
};

const _$TorrentPriorityEnumMap = {
  TorrentPriority.low: 'low',
  TorrentPriority.medium: 'medium',
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
      limited: json['limited'] as bool,
      priority: $enumDecode(_$TorrentPriorityEnumMap, json['priority']),
      addedOn: DateTime.parse(json['addedOn'] as String),
      completedOn: json['completedOn'] == null
          ? null
          : DateTime.parse(json['completedOn'] as String),
      location: json['location'] as String,
      ratio: (json['ratio'] as num).toDouble(),
      uploadedBytes: json['uploadedBytes'] as int,
      origin: json['origin'] as String,
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
      'limited': instance.limited,
      'priority': _$TorrentPriorityEnumMap[instance.priority]!,
      'addedOn': instance.addedOn.toIso8601String(),
      'completedOn': instance.completedOn?.toIso8601String(),
      'location': instance.location,
      'ratio': instance.ratio,
      'uploadedBytes': instance.uploadedBytes,
      'origin': instance.origin,
      'files': instance.files,
      'peers': instance.peers,
      'trackers': instance.trackers,
    };

_$_TorrentFileData _$$_TorrentFileDataFromJson(Map<String, dynamic> json) =>
    _$_TorrentFileData(
      name: json['name'] as String,
      wanted: json['wanted'] as bool,
      downloadedBytes: json['downloadedBytes'] as int,
      sizeBytes: json['sizeBytes'] as int,
      priority: $enumDecode(_$TorrentPriorityEnumMap, json['priority']),
    );

Map<String, dynamic> _$$_TorrentFileDataToJson(_$_TorrentFileData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'wanted': instance.wanted,
      'downloadedBytes': instance.downloadedBytes,
      'sizeBytes': instance.sizeBytes,
      'priority': _$TorrentPriorityEnumMap[instance.priority]!,
    };
