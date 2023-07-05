// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/smooth_graph/smooth_graph.dart';
import 'package:torrent_frontend/torrent/torrent.dart';
// import 'package:fl_chart/src/chart/line_chart/line_chart_painter.dart';
// import 'package:fl_chart/src/chart/line_chart/line_chart_renderer.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      // themeMode: ThemeMode.dark,
      theme: ThemeData(
        scaffoldBackgroundColor:
            Color.fromARGB(Color.getAlphaFromOpacity(0.6), 0, 0, 0),
        // scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          // bodyText1: TextStyle(),
          // bodyText2: TextStyle(),
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
              Expanded(
                child: Column(
                  children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(14),
                          child: Table(
                            columnWidths: {
                              0: MaxColumnWidth(
                                FixedColumnWidth(100),
                                FlexColumnWidth(1.7),
                              ),
                              1: FixedColumnWidth(170),
                              2: FlexColumnWidth(4),
                            },
                            children: [
                              TableRow(
                                children: [
                                  Center(child: Text('Name')),
                                  Center(child: Text('Progress')),
                                  Center(child: Text('Size')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ] +
                      (['Torrent', 'Torrent2y']
                          .map(
                            (torrent) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              height: 30,
                              child: Table(
                                columnWidths: {
                                  0: MinColumnWidth(
                                    FixedColumnWidth(200),
                                    MaxColumnWidth(
                                      FixedColumnWidth(100),
                                      FlexColumnWidth(1.7),
                                    ),
                                  ),
                                  1: FixedColumnWidth(170),
                                  2: FlexColumnWidth(4),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Text(torrent),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: ColoredBox(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                            Positioned.fill(
                                              child: ClipRect(
                                                clipper: RectCustomClipper(
                                                  (size) => Rect.fromLTWH(
                                                    0,
                                                    0,
                                                    size.width * 1,
                                                    size.height,
                                                  ),
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.lightBlue,
                                                        Colors
                                                            .lightBlue.shade200
                                                      ],
                                                      stops: [
                                                        0.5,
                                                        0.9,
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text('30 GB'),
                                    ]
                                        .map(
                                          (e) => Container(
                                            height: 40,
                                            padding: EdgeInsets.all(12),
                                            child: e,
                                          ),
                                        )
                                        .toList(),
                                  )
                                ],
                              ),
                            ),
                          )
                          .toList()),
                ),
                // child: DataTable(
                //   columns: [
                //     DataColumn(label: Text('Name')),
                //     DataColumn(label: Text('Progress')),
                //     DataColumn(label: Text('Size')),
                //   ],
                //   headingRowHeight: 30,
                //   headingRowColor: MaterialStateProperty.all(
                //     Colors.lightBlue.withOpacity(0.15),
                //   ),
                //   rows: ["Torrent", "Torrent2"]
                //       .map(
                //         (torrent) => DataRow(
                //           color: MaterialStateProperty.all(
                //               Colors.lightBlue.withOpacity(0.1)),
                //           cells: [
                //             DataCell(
                //               TableCell(
                //                 child: Padding(
                //                   padding: const EdgeInsets.all(8.0),
                //                   child: Text(
                //                     torrent,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //             DataCell(
                //               ClipRRect(
                //                 borderRadius: BorderRadius.circular(20),
                //                 child: SizedBox(
                //                   width: 100,
                //                   height: 7,
                //                   child: Stack(
                //                     children: [
                //                       Positioned.fill(
                //                         child: ColoredBox(
                //                           color: Colors.grey.withOpacity(0.2),
                //                         ),
                //                       ),
                //                       Positioned.fill(
                //                         child: ClipRect(
                //                           clipper: RectCustomClipper(
                //                             (size) => Rect.fromLTWH(
                //                               0,
                //                               0,
                //                               size.width * 1,
                //                               size.height,
                //                             ),
                //                           ),
                //                           child: Container(
                //                             decoration: BoxDecoration(
                //                               gradient: LinearGradient(
                //                                 colors: [
                //                                   Colors.lightBlue,
                //                                   Colors.lightBlue.shade200
                //                                 ],
                //                                 stops: [
                //                                   0.5,
                //                                   0.9,
                //                                 ],
                //                               ),
                //                             ),
                //                           ),
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //             ),
                //             DataCell(Text('30 GB')),
                //           ],
                //         ),
                //       )
                //       .toList(),
                //   // rows: [
                //   //   DataRow(cells: [
                //   //     DataCell(Text('Name')),
                //   //     DataCell(Text('Progress')),
                //   //     DataCell(Text('Size')),
                //   //   ]),
                //   //   DataRow(cells: [
                //   //     DataCell(Text('Name')),
                //   //     DataCell(Text('Progress')),
                //   //     DataCell(Text('Size')),
                //   //   ]),
                //   //   DataRow(cells: [
                //   //     DataCell(Text('Name')),
                //   //     DataCell(Text('Progress')),
                //   //     DataCell(Text('Size')),
                //   //   ]),
                //   // ],
                // ),
              ),
              // ListView.separated(
              //   shrinkWrap: true,
              //   itemCount: 10,
              //   itemBuilder: (context, index) {
              //     return Container(
              //       height: 40,
              //       child: TorrentTile(),
              //     );
              //   },
              //   separatorBuilder: (context, index) {
              //     return SizedBox(height: 10);
              //   },
              // ),
              SizedBox(
                width: 500,
                height: 200,
                child: SmoothChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
