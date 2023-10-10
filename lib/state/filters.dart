import 'package:flarrent/models/filters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final filtersProvider = StateProvider(
  (ref) => const Filters(
    query: '',
    states: [],
    sortBy: SortBy.addedOn,
    ascending: false,
  ),
);
