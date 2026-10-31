import 'package:transmission_rpc/transmission_rpc.dart';

/// Unknown is deliberately distinct from disabled: never infer server state.
enum OrderedSelection { empty, unknown, disabled, enabled, mixed }

class OrderedDownloadsSnapshot {
  OrderedDownloadsSnapshot(
      {required this.supported, required Map<int, bool?> torrents})
      : torrents = Map.unmodifiable(torrents);

  final bool supported;
  final Map<int, bool?> torrents;

  OrderedSelection selection(List<int> ids) {
    if (ids.isEmpty) return OrderedSelection.empty;
    final values = ids.map((id) => torrents[id]).toList();
    if (values.contains(null)) return OrderedSelection.unknown;
    if (values.every((value) => value == true)) return OrderedSelection.enabled;
    if (values.every((value) => value == false))
      return OrderedSelection.disabled;
    return OrderedSelection.mixed;
  }
}

/// Uses the package's public raw interface because its typed torrent model drops
/// sequential state and its setter sends the incorrect `sequentialDownload` key.
/// Transmission 4.1 api-compat.cc retains `sequential_download` even in the
/// legacy RPC envelope used by transmission_rpc (there is no camelCase alias).
class OrderedDownloads {
  OrderedDownloads(this.transmission);

  final Transmission transmission;

  Future<TransmissionResponse> _request(
          String method, Map<String, Object> arguments) =>
      transmission
          .sendRawRequest(
              TransmissionRequest(method: method, arguments: arguments))
          .timeout(const Duration(seconds: 10));

  static bool supports(Map<String, Object> session) {
    final semver =
        session['rpc-version-semver'] ?? session['rpc_version_semver'];
    if (semver is String) {
      final match =
          RegExp(r'^(\d+)\.(\d+)\.(\d+)(?:[-+].*)?$').firstMatch(semver);
      if (match != null) return int.parse(match.group(1)!) >= 6;
    }
    final version = session['rpc-version'] ?? session['rpc_version'];
    return version is int && version >= 18;
  }

  Future<bool> _supported() async =>
      supports((await _request('session-get', {})).arguments);

  Future<OrderedDownloadsSnapshot> read(List<int> ids) async {
    if (!await _supported()) {
      return OrderedDownloadsSnapshot(supported: false, torrents: {});
    }
    if (ids.isEmpty)
      return OrderedDownloadsSnapshot(supported: true, torrents: {});
    return _readTorrents(ids);
  }

  Future<OrderedDownloadsSnapshot> _readTorrents(List<int> ids) async {
    final response = await _request('torrent-get', {
      'ids': ids.toSet().toList(),
      'fields': ['id', 'sequential_download'],
      'format': 'objects',
    });
    final raw = response.arguments['torrents'];
    if (raw is! List)
      throw const FormatException('Missing torrent state in server response');
    final values = <int, bool?>{};
    for (final row in raw) {
      if (row is! Map || row['id'] is! int) {
        throw const FormatException('Invalid torrent state in server response');
      }
      final value = row['sequential_download'];
      values[row['id'] as int] = value is bool ? value : null;
    }
    return OrderedDownloadsSnapshot(supported: true, torrents: values);
  }

  /// Never omit ids: Transmission interprets omission as *all* torrents.
  /// Recheck capability and read back state rather than optimistically claiming
  /// success (older servers can silently ignore unknown torrent-set keys).
  Future<void> set(List<int> ids, {required bool enabled}) async {
    if (ids.isEmpty) return;
    if (!await _supported())
      throw UnsupportedError(
          'Ordered downloads require Transmission 4.1 or newer');
    final selected = ids.toSet().toList();
    await _request(
        'torrent-set', {'ids': selected, 'sequential_download': enabled});
    final actual = await _readTorrents(selected);
    if (selected.any((id) => actual.torrents[id] != enabled)) {
      throw StateError(
          'The server did not confirm ordered downloads for every selected torrent. Refresh and retry.');
    }
  }
}
