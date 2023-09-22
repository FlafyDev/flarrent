// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/widgets/bottom_overview.dart';
import 'package:torrent_frontend/widgets/smooth_graph/smooth_graph.dart';
import 'package:torrent_frontend/widgets/torrent/torrent.dart';
import 'package:torrent_frontend/widgets/torrent/torrent_bottom_overview.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor:
            Color.fromARGB(Color.getAlphaFromOpacity(0.6), 0, 0, 0),
        colorScheme: ColorScheme.dark(
          primary: Colors.transparent,
          secondary: Colors.transparent,
          background: Colors.transparent,
          surface: Colors.transparent,
          onPrimary: Colors.white,
          shadow: Colors.black.withOpacity(0.2),
          onSecondary: Color.fromARGB(255, 85, 188, 228),
          // onBackground: Colors.white,
          // onSurface: Colors.white,
        ),
        shadowColor: Colors.black.withOpacity(0.2),
        // textTheme: const TextTheme(
        //   // bodyLarge: TextStyle(),
        //   // bodyMedium: TextStyle(),
        //   // titleMedium: TextStyle(),
        //   // labelMedium: TextStyle(),
        //   // labelLarge: TextStyle(),
        //   // labelSmall: TextStyle(),
        //   // titleLarge: TextStyle(),
        //   // titleSmall: TextStyle(),
        // ).apply(
        //   bodyColor: Colors.white,
        //   displayColor: Colors.white,
        // ),
      ),
      home: Scaffold(
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
  Widget build(context, ref) {
    final bottomExpandedAC =
        useAnimationController(duration: Duration(milliseconds: 300));
    final _easeOutAnimation = CurvedAnimation(
      parent: bottomExpandedAC,
      curve: Curves.easeOutExpo,
      reverseCurve: Curves.easeOutExpo.flipped,
    );
    final theme = Theme.of(context);
    final sideOpen = false;
    final sideOnTop = 0.0;

    return Row(
      children: [
        if (sideOpen) Container(width: 300, child: const Text('mid')),
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
                      sideOnTop * 300, 0, size.width, size.height),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.all(10).copyWith(bottom: 0),
                              child: ListView(
                                children: [
                                  TorrentTile(
                                    bytes: 12582912,
                                    bytesToDownload: 12582912,
                                    bytesDownloadSpeed: 524288,
                                    bytesDownloaded: 1048576,
                                    isFile: false,
                                    timeLeft: Duration(seconds: 24),
                                    onPressed: () {
                                      // showDialog(
                                      //   context: context,
                                      //   builder: (context) => Scaffold(body: const TorrentBottomOverview()),
                                      // );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Scaffold(
                                              body:
                                                  const TorrentBottomOverview()),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TorrentTile(
                                    bytes: 12582912,
                                    bytesToDownload: 12582912,
                                    bytesDownloadSpeed: 524288,
                                    bytesDownloaded: 1048576,
                                    isFile: false,
                                    timeLeft: Duration(seconds: 24),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TorrentTile(
                                    bytes: 12582912,
                                    bytesToDownload: 12582912,
                                    bytesDownloadSpeed: 524288,
                                    bytesDownloaded: 1048576,
                                    isFile: false,
                                    timeLeft: Duration(seconds: 24),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TorrentTile(
                                    bytes: 12582912,
                                    bytesToDownload: 12582912,
                                    bytesDownloadSpeed: 524288,
                                    bytesDownloaded: 1048576,
                                    isFile: false,
                                    timeLeft: Duration(seconds: 24),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TorrentTile(
                                    bytes: 12582912,
                                    bytesToDownload: 12582912,
                                    bytesDownloadSpeed: 524288,
                                    bytesDownloaded: 1048576,
                                    isFile: false,
                                    timeLeft: Duration(seconds: 24),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TorrentTile(
                                    bytes: 12582912,
                                    bytesToDownload: 12582912,
                                    bytesDownloadSpeed: 524288,
                                    bytesDownloaded: 1048576,
                                    isFile: false,
                                    timeLeft: Duration(seconds: 24),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IgnorePointer(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
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
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _easeOutAnimation,
                      builder: (context, child) {
                        const hidePoint = 0.90;
                        return _easeOutAnimation.value < hidePoint
                            ? Opacity(
                                opacity:
                                    1 - _easeOutAnimation.value / hidePoint,
                                child: Divider(
                                  color: Colors.lightBlue,
                                  height: 1,
                                ),
                              )
                            : Container();
                      },
                    ),
                    AnimatedBuilder(
                      animation: _easeOutAnimation,
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 48,
                            child: GestureDetector(
                              onTap: () {
                                if (bottomExpandedAC.isCompleted) {
                                  bottomExpandedAC.reverse();
                                } else {
                                  bottomExpandedAC.forward();
                                }
                              },
                            ),
                          ),
                          TorrentBottomOverview(),
                        ],
                      ),
                      builder: (context, child) {
                        final height =
                            max(MediaQuery.of(context).size.height * 0.3, 200);
                        return SizedBox(
                          height: height +
                              (MediaQuery.of(context).size.height - height) *
                                  _easeOutAnimation.value,
                          child: child,
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (sideOpen)
                IgnorePointer(
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
    );
  }
}
