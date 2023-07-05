import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/smooth_graph/get_y_from_x.dart';

class SmoothChart extends HookConsumerWidget {
  const SmoothChart({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const pointsNum = 4;
    const pointSpace = 1 / pointsNum;
    final moveAC =
        useAnimationController(duration: const Duration(milliseconds: 1000));
    final maxYAC = useAnimationController(
      initialValue: 1,
      upperBound: double.infinity,
    );
    final lastT = useRef<double>(0);

    // final movingPoints = useState<List<FlSpot>>([]);
    final points = useState(
      List.generate(
        pointsNum + 4,
        (i) => FlSpot(
          i * pointSpace - pointSpace,
          0,
        ),
      ),
    );
    final mod = useRef<double>(1);

    useEffect(
      () {
        moveAC
          ..forward()
          ..addListener(() {
            if (moveAC.status == AnimationStatus.completed) {
              lastT.value = 0;
              moveAC
                ..reset()
                ..forward();
              points.value = points.value
                      .skip(1)
                      .map((p) => p.copyWith(x: p.x - pointSpace))
                      .toList() +
                  [
                    FlSpot(1 + pointSpace * 2,
                        Random().nextDouble() * 0.4 + 0.3 * mod.value)
                  ];
              print(points.value);
              maxYAC.animateTo(
                max(
                  1,
                  ([...points.value]..sort((a, b) => a.y.compareTo(b.y)))
                          .last
                          .y *
                      1.2,
                ),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
              );
            }
          });
        return null;
      },
      [],
    );

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          mod.value *= 1.2;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          mod.value /= 1.2;
        }
      },
      child: AnimatedBuilder(
        animation: maxYAC,
        builder: (context, child) {
          final barData = LineChartBarData(
            color: Colors.lightBlue,

            dotData: FlDotData(
              show: false,
            ),
            spots: points.value,
            isCurved: true,
            // gradient: LinearGradient(
            //   colors: gradientColors,
            // ),
            barWidth: 1,
            isStrokeCapRound: true,
            // dotData: const FlDotData(
            //   show: false,
            // ),
            belowBarData: BarAreaData(
              show: false,
              // TODO(flafydev): fix sudden change in gradient.
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.lightBlue.withOpacity(0.4),
                  Colors.black.withOpacity(0),
                ],
              ),
            ),
          );
          final data = LineChartData(
            clipData: FlClipData.none(),
            gridData: FlGridData(
              show: false,
            ),
            titlesData: FlTitlesData(
              show: false,
            ),
            borderData: FlBorderData(
              show: false,
            ),
            minX: 0,
            maxX: 1,
            minY: -0.05,
            maxY: maxYAC.value,
            lineBarsData: [barData],
          );
          print(maxYAC.value);
          // final graph = LineChart(
          //   data,
          //   swapAnimationDuration: Duration.zero, // Optional
          // );
          return LayoutBuilder(
            builder: (context, constraints) {
              final graph = CustomPaint(
                painter: _PathPainter(
                  path: LineChartPainter().generateNormalBarPath(
                    Size(constraints.maxWidth, constraints.maxHeight),
                    barData,
                    barData.spots,
                    PaintHolder(data, data, 1),
                  ),
                  color: Colors.lightBlue,
                  glow: false,
                ),
              );
              final graphGlow = CustomPaint(
                painter: _PathPainter(
                  path: LineChartPainter().generateNormalBarPath(
                    Size(constraints.maxWidth, constraints.maxHeight),
                    barData,
                    barData.spots,
                    PaintHolder(data, data, 1),
                  ),
                  color: Colors.lightBlue,
                  glow: true,
                ),
              );
              return AnimatedBuilder(
                animation: moveAC,
                child: graph,
                builder: (context, graph) {
                  const ballSize = 12.0;
                  const ballOffset = 6;
                  final (y, t) = getYFromX(
                    constraints.maxWidth -
                        ballOffset +
                        moveAC.value * constraints.maxWidth / pointsNum,
                    lastT.value,
                    Size(constraints.maxWidth, constraints.maxHeight),
                    barData,
                    barData.spots.skip(barData.spots.length - 4).toList(),
                    PaintHolder(data, data, 1),
                  );
                  return Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomPaint(
                      painter: _GradientPainter(
                        strokeWidth: 1,
                        radius: 10,
                        gradient: LinearGradient(
                          end: Alignment(
                            1,
                            y / constraints.maxWidth * 2 * 2 - 1,
                          ),
                          stops: const [
                            0.0,
                            0.9,
                            1.0,
                          ],
                          colors: [
                            Colors.blue.withOpacity(0.1),
                            Colors.blue.withOpacity(0.3),
                            Colors.blue.withOpacity(0.7),
                          ],
                        ),
                      ),
                      // child: AnimatedGraph(),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          lastT.value = t;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: constraints.maxWidth -
                                    ballOffset -
                                    ballSize / 2,
                                top: y - ballSize / 2,
                                child: const SizedBox(
                                  width: ballSize,
                                  height: ballSize,
                                  child: Center(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.lightBlue,
                                            blurRadius: 60,
                                            spreadRadius: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: -moveAC.value *
                                    (constraints.maxWidth / pointsNum),
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                child: graphGlow,
                              ),
                              Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: const BoxDecoration(),
                                width: constraints.maxWidth - ballOffset,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: -moveAC.value *
                                          (constraints.maxWidth / pointsNum),
                                      width: constraints.maxWidth,
                                      height: constraints.maxHeight,
                                      child: graph!,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: constraints.maxWidth -
                                    ballOffset -
                                    ballSize / 2,
                                top: y - ballSize / 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.8),
                                    border: Border.all(
                                      color: Colors.lightBlue,
                                      width: 1.5,
                                    ),
                                  ),
                                  width: ballSize,
                                  height: ballSize,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

double _convertRadiusToSigma(double radius) {
  return radius * 0.57735 + 0.5;
}

class _PathPainter extends CustomPainter {
  _PathPainter({
    required this.path,
    required this.glow,
    required this.color,
  });

  final Paint _paint = Paint();
  final Path path;
  final bool glow;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = glow ? 30 : 1
      ..color = glow ? color.withOpacity(0.7) : color
      ..maskFilter = glow
          ? MaskFilter.blur(
              BlurStyle.normal,
              _convertRadiusToSigma(90),
            )
          : null;
    if (glow) {
      canvas.saveLayer(Rect.largest, Paint());
      canvas.drawPath(path, _paint);
      final closedPath = path.shift(Offset.zero)
        ..relativeLineTo(0, -size.height)
        ..relativeLineTo(-size.width * 2, 0)
        ..close();
      // ..close();
      canvas.drawPath(
        closedPath,
        Paint()
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.clear,
      );
      canvas.restore();
    } else {
      canvas.drawPath(path, _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

class _GradientPainter extends CustomPainter {
  _GradientPainter({
    required this.strokeWidth,
    required this.radius,
    required this.gradient,
  });

  final Paint _paint = Paint();
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    final outerRect = Offset.zero & size;
    final outerRRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(radius));

    // create inner rectangle smaller by strokeWidth
    final innerRect = Rect.fromLTWH(
      strokeWidth,
      strokeWidth,
      size.width - strokeWidth * 2,
      size.height - strokeWidth * 2,
    );
    final innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(radius - strokeWidth),
    );

    // apply gradient shader
    _paint.shader = gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    final path1 = Path()..addRRect(outerRRect);
    final path2 = Path()..addRRect(innerRRect);
    final path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

// TRASH

          // AnimatedBuilder(
          //   animation: moveAC,
          //   builder: (context, child) {
          //     return Container(
          //       clipBehavior: Clip.hardEdge,
          //       decoration: BoxDecoration(
          //         border: Border.all(color: Colors.lightBlue),
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       child: Stack(
          //         children: [
          //           Positioned(
          //             left: -moveAC.value *
          //                 (constraints.maxWidth / pointsNum),
          //             width: constraints.maxWidth,
          //             height: constraints.maxHeight,
          //             child: child!,
          //           ),
          //         ],
          //       ),
          //     );
          //   },
          //   child: Container(
          //     width: constraints.maxWidth,
          //     height: constraints.maxHeight,
          //     child: LineChartLeaf(
          //       data: LineChartData(
          //         gridData: FlGridData(
          //           show: false,
          //         ),
          //         titlesData: FlTitlesData(
          //           show: false,
          //         ),
          //         borderData: FlBorderData(
          //           show: false,
          //         ),
          //         minX: 0,
          //         maxX: 1,
          //         minY: -0.05,
          //         maxY: maxYAC.value,
          //         lineBarsData: [
          //           LineChartBarData(
          //             color: Colors.lightBlue,
          //
          //             dotData: FlDotData(
          //               show: true,
          //             ),
          //             spots: points.value
          //                 .skip(points.value.length - 4)
          //                 .take(3)
          //                 .toList(),
          //             isCurved: true,
          //             // gradient: LinearGradient(
          //             //   colors: gradientColors,
          //             // ),
          //             barWidth: 1,
          //             // dotData: const FlDotData(
          //             //   show: false,
          //             // ),
          //           ),
          //         ],
          //       ),
          //       targetData: LineChartData(
          //         gridData: FlGridData(
          //           show: false,
          //         ),
          //         titlesData: FlTitlesData(
          //           show: false,
          //         ),
          //         borderData: FlBorderData(
          //           show: false,
          //         ),
          //         minX: 0,
          //         maxX: 1,
          //         minY: -0.05,
          //         maxY: maxYAC.value,
          //         lineBarsData: [
          //           LineChartBarData(
          //             color: Colors.lightBlue,
          //             dotData: FlDotData(
          //               show: true,
          //             ),
          //             spots: points.value,
          //             isCurved: true,
          //             barWidth: 1,
          //             isStrokeCapRound: true,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),


                        // AnimatedBuilder(
                        //   animation: moveAC,
                        //   builder: (context, child) {
                        //     return LineChartLeaf(
                        //       dotOffset: moveAC.value *
                        //     (constraints.maxWidth / pointsNum),
                        //       data: LineChartData(
                        //         gridData: FlGridData(
                        //           show: false,
                        //         ),
                        //         titlesData: FlTitlesData(
                        //           show: false,
                        //         ),
                        //         borderData: FlBorderData(
                        //           show: false,
                        //         ),
                        //         minX: 0,
                        //         maxX: 1,
                        //         minY: -0.05,
                        //         maxY: maxYAC.value,
                        //         lineBarsData: [
                        //           LineChartBarData(
                        //             color: Colors.red,
                        //
                        //             dotData: FlDotData(
                        //               show: true,
                        //             ),
                        //             spots: points.value
                        //                 .skip(points.value.length - 4)
                        //                 .toList(),
                        //             isCurved: true,
                        //             // gradient: LinearGradient(
                        //             //   colors: gradientColors,
                        //             // ),
                        //             barWidth: 1,
                        //             // dotData: const FlDotData(
                        //             //   show: false,
                        //             // ),
                        //           ),
                        //         ],
                        //       ),
                        //       targetData: LineChartData(
                        //         gridData: FlGridData(
                        //           show: false,
                        //         ),
                        //         titlesData: FlTitlesData(
                        //           show: false,
                        //         ),
                        //         borderData: FlBorderData(
                        //           show: false,
                        //         ),
                        //         minX: 0,
                        //         maxX: 1,
                        //         minY: -0.05,
                        //         maxY: maxYAC.value,
                        //         lineBarsData: [
                        //           LineChartBarData(
                        //             color: Colors.lightBlue,
                        //             dotData: FlDotData(
                        //               show: true,
                        //             ),
                        //             spots: points.value,
                        //             isCurved: true,
                        //             barWidth: 1,
                        //             isStrokeCapRound: true,
                        //           ),
                        //         ],
                        //       ),
                        //     );
                        //   },
                        // ),
