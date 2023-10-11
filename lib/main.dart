import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:flarrent/models/cli_args.dart';
import 'package:flarrent/state/cli_args.dart';
import 'package:flarrent/state/config.dart';
import 'package:flarrent/state/torrents.dart';
import 'package:flarrent/utils/filter_unknown_arguments.dart';
import 'package:flarrent/utils/rect_custom_clipper.dart';
import 'package:flarrent/widgets/main_view.dart';
import 'package:flarrent/widgets/side_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption('config')
    ..addMultiOption('torrent');
  final results = parser.parse(filterUnknownArguments(args, parser));

  final container = ProviderContainer(
    overrides: [
      cliArgsProvider.overrideWithValue(
        CliArgs(
          configLocation: results['config'] as String?,
          torrentsLinks: results['torrent'] as List<String>?,
        ),
      )
    ],
  );

  for (final link in container.read(cliArgsProvider).torrentsLinks ?? <String>[]) {
    if (link.startsWith('magnet:')) {
      container.read(torrentsProvider.notifier).addTorrentMagnet(link);
    } else if (File(link).existsSync()) {
      container.read(torrentsProvider.notifier).addTorrentBase64(const Base64Encoder().convert(File(link).readAsBytesSync()));
    } else {
      container.read(torrentsProvider.notifier).addTorrentBase64(link);
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).valueOrNull;
    if (config == null) {
      return const SizedBox();
    }

    final color = config.color!;

    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: config.backgroundColor,
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.transparent,
          background: Colors.transparent,
          // surface: Colors.transparent,
          onPrimary: Colors.white,
          shadow: Colors.black.withOpacity(0.2),
          onSecondary: color,
          surfaceVariant: HSLColor.fromColor(color).withSaturation(0.2).withLightness(0.2).toColor(),
          surface: HSLColor.fromColor(color).withSaturation(1).withLightness(0.2).toColor(),
        ),
        // splashColor: color,
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: color),
          ),
          hoverColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: color.withAlpha(055)),
          ),
        ),
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      home: const Scaffold(
        body: SizedBox.expand(
          child: AppEntry(),
        ),
      ),
    );
  }
}

class AppEntry extends HookConsumerWidget {
  const AppEntry({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prevOnTop = useRef(true);
    final sideOpenAC = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final openSideTimer = useRef<Timer?>(null);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final sideOnTop = constraints.maxWidth < 1000;
        if (prevOnTop.value != sideOnTop) {
          sideOpenAC.animateTo(
            sideOnTop ? 0 : 1,
            curve: Curves.easeOutExpo,
          );
          prevOnTop.value = sideOnTop;
        }

        return AnimatedBuilder(
          animation: sideOpenAC,
          builder: (context, child) {
            final sideOpen = sideOpenAC.value;
            final sideWidth = 300 * sideOpenAC.value;
            return Stack(
              children: [
                MouseRegion(
                  onExit: (e) {
                    if (sideOnTop && sideOpenAC.value != 0) {
                      sideOpenAC.animateTo(
                        0,
                        curve: Curves.easeOutExpo,
                      );
                    }
                  },
                  child: ClipRect(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      widthFactor: sideOpen,
                      child: SizedBox(
                        width: 300,
                        child: Stack(
                          children: [
                            const SideView(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: VerticalDivider(
                                width: 1,
                                color: theme.colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: sideOnTop ? 0 : sideWidth,
                  top: 0,
                  width: sideOnTop ? constraints.maxWidth : constraints.maxWidth - sideWidth,
                  height: constraints.maxHeight,
                  child: ClipRect(
                    clipper: RectCustomClipper(
                      (size) => Rect.fromLTRB(
                        sideOnTop ? sideWidth : 0,
                        0,
                        size.width,
                        size.height,
                      ),
                    ),
                    child: MainView(
                      menuPlace: sideOnTop,
                      onMenuPlaceExit: () {
                        openSideTimer.value?.cancel();
                        openSideTimer.value = null;
                      },
                      onMenuPlaceEnter: () {
                        openSideTimer.value?.cancel();
                        openSideTimer.value = Timer(const Duration(milliseconds: 100), () {
                          sideOpenAC.animateTo(
                            1,
                            curve: Curves.easeOutExpo,
                          );
                          openSideTimer.value?.cancel();
                          openSideTimer.value = null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
