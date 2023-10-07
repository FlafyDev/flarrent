import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/utils/rect_custom_clipper.dart';
import 'package:torrent_frontend/widgets/common/side_popup.dart';
import 'package:torrent_frontend/widgets/main_view.dart';
import 'package:torrent_frontend/widgets/side_view.dart';
import 'package:torrent_frontend/widgets/torrent/torrent.dart';

void main() {
  // timeDilation = 1.0;
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
        body: AppEntry(),
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
    final theme = Theme.of(context);
    final sideOpen = true;
    final sideOnTop = 0.0;

    return Stack(
      children: [
        Row(
          children: [
            if (sideOpen) Container(width: 300, child: SideView()),
            if (sideOpen)
              VerticalDivider(
                width: 1,
                color: Colors.lightBlue,
              ),
            Expanded(
              child: Stack(
                children: [
                  ClipRect(
                    clipper: RectCustomClipper(
                      (size) => Rect.fromLTRB(
                        sideOnTop * 300,
                        0,
                        size.width,
                        size.height,
                      ),
                    ),
                    child: const MainView(),
                  ),
                  // if (sideOpen)
                  //   IgnorePointer(
                  //     child: Align(
                  //       alignment: Alignment.centerLeft,
                  //       child: Container(
                  //         width: 60,
                  //         decoration: BoxDecoration(
                  //           gradient: LinearGradient(
                  //             begin: Alignment.centerRight,
                  //             end: Alignment.centerLeft,
                  //             colors: [
                  //               Colors.black.withOpacity(0),
                  //               Colors.black.withOpacity(0.1),
                  //               Colors.black.withOpacity(0.2),
                  //               Colors.black.withOpacity(0.3),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  if (sideOnTop > 0.0)
                    Positioned.fill(
                      right: MediaQuery.of(context).size.width - 300 * sideOnTop,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              child: const Text('mid'),
                            ),
                          ),
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
                  if (sideOnTop > 0.0)
                    Positioned.fill(
                      left: 300 * sideOnTop,
                      child: IgnorePointer(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Colors.black.withOpacity(0),
                                  Colors.black.withOpacity(0.1),
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
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
      ],
    );
  }
}
