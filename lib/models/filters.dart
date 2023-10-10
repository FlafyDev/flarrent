import 'package:flarrent/models/torrent.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'filters.freezed.dart';
part 'filters.g.dart';

enum SortBy {
  name,
  downloadSpeed,
  uploadSpeed,
  size,
  addedOn,
  completedOn,
}

@freezed
class Filters with _$Filters {
  const factory Filters({
    required String query,
    required List<TorrentState> states,
    required SortBy sortBy,
    required bool ascending,
  }) = _Filters;

  factory Filters.fromJson(Map<String, Object?> json) => _$FiltersFromJson(json);
}
