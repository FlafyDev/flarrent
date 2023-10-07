import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/models/filters.dart';

final filtersProvider = StateProvider(
  (ref) => const Filters(
    query: '',
    states: [],
    sortBy: SortBy.addedOn,
    ascending: true,
  ),
);
