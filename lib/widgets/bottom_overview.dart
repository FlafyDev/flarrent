import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/providers/transmission.dart';
import 'package:torrent_frontend/widgets/smooth_graph/smooth_graph.dart';

class BottomOverview extends HookConsumerWidget {
  const BottomOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
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
                        Icon(Icons.arrow_downward, color: Colors.white),
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
                        Icon(Icons.arrow_upward, color: Colors.white),
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
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: Wrap(
                    direction: Axis.vertical,
                    runAlignment: WrapAlignment.spaceEvenly,
                    children: [0, 1, 2, 3, 4, 5]
                        .map(
                          (e) => SizedBox(
                            height: 20,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.arrow_upward,
                                          color: Colors.grey),
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
                          ),
                        )
                        .toList(),
                  ),
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
    );
  }
}
