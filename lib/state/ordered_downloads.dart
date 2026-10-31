import 'dart:async';

import 'package:flarrent/state/torrents.dart';
import 'package:flarrent/state/transmission.dart';
import 'package:flarrent/utils/ordered_downloads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final orderedDownloadsClientProvider =
    Provider.autoDispose<OrderedDownloads>((ref) {
  final backend = ref.watch(torrentsProvider.notifier);
  if (backend is! TransmissionTorrents) {
    throw UnsupportedError(
        'Ordered downloads are unavailable for this backend');
  }
  return OrderedDownloads(backend.transmission);
});

// Share one batch between torrent indicators and the selection toolbar. Watch
// only the ID set so quick-torrent speed updates do not restart this poll.
final orderedDownloadsProvider = FutureProvider.autoDispose<OrderedDownloadsSnapshot>((ref) async {
  final key = ref.watch(
    torrentsProvider.select((state) {
      final ids = state.quickTorrents.map((torrent) => torrent.id).toSet().toList()..sort();
      return ids.join(',');
    }),
  );
  final client = ref.watch(orderedDownloadsClientProvider);
  Timer? timer;
  var disposed = false;
  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
  });
  try {
    final ids = key.isEmpty ? <int>[] : key.split(',').map(int.parse).toList();
    return await client.read(ids);
  } finally {
    // Schedule after completion, including failures, to avoid overlapping slow
    // requests. Disposal or torrent ID changes cancel the next refresh.
    if (!disposed) {
      timer = Timer(const Duration(seconds: 2), ref.invalidateSelf);
    }
  }
});
