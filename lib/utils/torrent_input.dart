import 'dart:convert';
import 'dart:io';

/// Dispatch desktop URLs, local paths, and existing raw metainfo inputs.
Future<void> dispatchTorrentInput(
  String input, {
  required Future<void> Function(String) addMagnet,
  required Future<void> Function(String) addBase64,
}) async {
  final uri = Uri.tryParse(input);
  if (uri?.scheme == 'magnet') {
    await addMagnet(input);
    return;
  }

  // localhost is a local authority, but Dart's POSIX toFilePath rejects it.
  final localUri = uri?.scheme == 'file' && uri?.host == 'localhost'
      ? uri!.replace(host: '')
      : uri;
  // File.fromUri decodes escaped paths and rejects non-local file URIs.
  // Explicit file URIs must be read as files, never sent as raw metainfo.
  final file = uri?.scheme == 'file' ? File.fromUri(localUri!) : File(input);
  if (uri?.scheme == 'file' || file.existsSync()) {
    await addBase64(base64Encode(await file.readAsBytes()));
  } else {
    await addBase64(input);
  }
}
