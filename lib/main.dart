import 'dart:async';

import 'package:args/args.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/utils/rect_custom_clipper.dart';
import 'package:torrent_frontend/widgets/common/side_popup.dart';
import 'package:torrent_frontend/widgets/main_view.dart';
import 'package:torrent_frontend/widgets/side_view.dart';
import 'package:torrent_frontend/widgets/torrent/torrent.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption('config')
    ..addMultiOption('torrent')
    ..addFlag('verbose', defaultsTo: true);
  final results = parser.parse(args);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(Color.getAlphaFromOpacity(0.6), 0, 0, 0),
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.transparent,
          background: Colors.transparent,
          surface: Colors.transparent,
          onPrimary: Colors.white,
          shadow: Colors.black.withOpacity(0.2),
          onSecondary: const Color.fromARGB(255, 85, 188, 228),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color.fromARGB(255, 85, 188, 228)),
          ),
          hoverColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color.fromARGB(055, 85, 188, 228)),
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
      initialValue: 0,
    );
    final openSideTimer = useRef<Timer?>(null);

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
                        child: const Stack(
                          children: [
                            SideView(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: VerticalDivider(
                                width: 1,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Container(
                //   width: 300,
                //   child: Stack(
                //     children: [
                //       Positioned(
                //         child: SizedBox(
                //           width: 300,
                //           child: SideView(),
                //         ),
                //       ),
                //       const Align(
                //         alignment: Alignment.centerRight,
                //         child: VerticalDivider(
                //           width: 1,
                //           color: Colors.lightBlue,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
                // Positioned.fill(
                //   child: ColoredBox(
                //     color: Colors.black.withOpacity(0.5),
                //     child: Center(
                //       child: Container(
                //         width: 300,
                //         height: 300,
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(10),
                //           border: Border.all(
                //             color: Colors.white,
                //             width: 2,
                //           ),
                //           color: Colors.black,
                //         ),
                //         padding: const EdgeInsets.all(10),
                //         child: Text('test'),
                //       ),
                //     ),
                //   ),
                // )
                // if (sideOpenAC.value == 0)
                //   Positioned(
                //     width: 120,
                //     height: MediaQuery.of(context).size.height,
                //     child: MouseRegion(
                //       onExit: (e) {
                //         openSideTimer.value?.cancel();
                //         openSideTimer.value = null;
                //       },
                //       onEnter: (e) {
                //         openSideTimer.value ??= Timer(const Duration(milliseconds: 100), () {
                //           sideOpenAC.animateTo(
                //             1,
                //             curve: Curves.easeOutExpo,
                //           );
                //           openSideTimer.value?.cancel();
                //           openSideTimer.value = null;
                //         });
                //       },
                //     ),
                //   ),
              ],
            );
          },
        );
      },
    );
  }
}
