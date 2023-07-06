// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/widgets/smooth_graph/smooth_graph.dart';
import 'package:torrent_frontend/widgets/torrent/torrent.dart';

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
        textTheme: const TextTheme(
          bodyLarge: TextStyle(),
          bodyMedium: TextStyle(),
          titleMedium: TextStyle(),
          labelMedium: TextStyle(),
          labelLarge: TextStyle(),
          labelSmall: TextStyle(),
          titleLarge: TextStyle(),
          titleSmall: TextStyle(),
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(0),
          child: Column(
            children: [
              Flexible(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TorrentTile(),
                      SizedBox(
                        height: 10,
                      ),
                      TorrentTile(),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: SmoothChart(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_downward,
                                        color: Colors.white),
                                    Text(
                                      "15.5 MB",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_upward,
                                        color: Colors.white),
                                    Text(
                                      "5.05 MB",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.blue,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              direction: Axis.vertical,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.arrow_upward,
                                              color: Colors.grey),
                                          Text("/"),
                                          Icon(Icons.arrow_downward,
                                              color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Center(
                                        child: Text(
                                          (5.05 / 15.5).toStringAsFixed(2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.arrow_upward,
                                              color: Colors.grey),
                                          Text("/"),
                                          Icon(Icons.arrow_downward,
                                              color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Center(
                                        child: Text(
                                          (5.05 / 15.5).toStringAsFixed(2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.arrow_upward,
                                              color: Colors.grey),
                                          Text("/"),
                                          Icon(Icons.arrow_downward,
                                              color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Center(
                                        child: Text(
                                          (5.05 / 15.5).toStringAsFixed(2),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ].map((e) => SizedBox(width: 200, child: e)).toList(),
                            ),
                          ),
                          Table(
                            children: [
                              TableRow(
                                children: [
                                  Center(),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
