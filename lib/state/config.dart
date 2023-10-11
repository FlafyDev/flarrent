import 'dart:convert';
import 'dart:io';

import 'package:flarrent/models/config.dart';
import 'package:flarrent/state/cli_args.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const defaultConfig = Config(
  connection: 'transmission:http://localhost:9091/transmission/rpc',
  color: Color.fromARGB(255, 105, 188, 255),
  backgroundColor: Color.fromARGB(153, 0, 0, 0),
  smoothScroll: false,
  animateOnlyOnFocus: true,
);

final configLocationProvider = StateProvider<String>(
  (ref) =>
      ref.watch(cliArgsProvider.select((c) => c.configLocation)) ??
      '${Platform.environment['HOME']}/.config/flarrent/config.json',
);

final configProvider = StreamProvider((ref) async* {
  final location = ref.watch(configLocationProvider);
  final file = File(location);

  if (!file.existsSync()) {
    file
      ..createSync(recursive: true)
      ..writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(defaultConfig.toJson()),
      );
  }

  Future<Config> loadConfig() async {
    final newConf = Config.fromJson(jsonDecode(await file.readAsString()) as Map<String, dynamic>);
    return newConf.copyWith(
      connection: newConf.connection ?? defaultConfig.connection,
      color: newConf.color ?? defaultConfig.color,
      backgroundColor: newConf.backgroundColor ?? defaultConfig.backgroundColor,
      smoothScroll: newConf.smoothScroll ?? defaultConfig.smoothScroll,
      animateOnlyOnFocus: newConf.animateOnlyOnFocus ?? defaultConfig.animateOnlyOnFocus,
    );
  }

  yield await loadConfig();
  await for (final event in file.parent.watch()) {
    if (event is FileSystemModifyEvent || event is FileSystemCreateEvent) {
      yield await loadConfig();
    }
  }
});
