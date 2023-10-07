// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Filters _$$_FiltersFromJson(Map<String, dynamic> json) => _$_Filters(
      query: json['query'] as String,
      states: (json['states'] as List<dynamic>)
          .map((e) => $enumDecode(_$TorrentStateEnumMap, e))
          .toList(),
      sortBy: $enumDecode(_$SortByEnumMap, json['sortBy']),
      ascending: json['ascending'] as bool,
    );

Map<String, dynamic> _$$_FiltersToJson(_$_Filters instance) =>
    <String, dynamic>{
      'query': instance.query,
      'states': instance.states.map((e) => _$TorrentStateEnumMap[e]!).toList(),
      'sortBy': _$SortByEnumMap[instance.sortBy]!,
      'ascending': instance.ascending,
    };

const _$TorrentStateEnumMap = {
  TorrentState.downloading: 'downloading',
  TorrentState.seeding: 'seeding',
  TorrentState.paused: 'paused',
  TorrentState.queued: 'queued',
  TorrentState.completed: 'completed',
  TorrentState.error: 'error',
};

const _$SortByEnumMap = {
  SortBy.name: 'name',
  SortBy.downloadSpeed: 'downloadSpeed',
  SortBy.uploadSpeed: 'uploadSpeed',
  SortBy.size: 'size',
  SortBy.addedOn: 'addedOn',
  SortBy.completedOn: 'completedOn',
};
