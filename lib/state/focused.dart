import 'package:flarrent/utils/timer_stream.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

final focusedProvider = StreamProvider((ref) async* {
  await windowManager.ensureInitialized();
  await for (final _ in timerStream(const Duration(seconds: 1))) {
    yield await windowManager.isFocused();
  }
});
