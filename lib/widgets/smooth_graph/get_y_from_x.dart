// ignore_for_file: implementation_imports

import 'dart:math';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart_painter.dart';

// Edited version of `generateNormalBarPath` from package:fl_chart/src/chart/line_chart/line_chart_painter.dart.
(double, double) getYFromX(
  double x,
  double initialT,
  Size viewSize,
  LineChartBarData barData,
  List<FlSpot> barSpots,
  PaintHolder<LineChartData> holder,
) {
  final instance = LineChartPainter();

  final size = barSpots.length;

  var temp = Offset.zero;

  for (var i = 1; i < size; i++) {
    /// CurrentSpot
    final current = Offset(
      instance.getPixelX(barSpots[i].x, viewSize, holder),
      instance.getPixelY(barSpots[i].y, viewSize, holder),
    );

    /// previous spot
    final previous = Offset(
      instance.getPixelX(barSpots[i - 1].x, viewSize, holder),
      instance.getPixelY(barSpots[i - 1].y, viewSize, holder),
    );

    /// next point
    final next = Offset(
      instance.getPixelX(
        barSpots[i + 1 < size ? i + 1 : i].x,
        viewSize,
        holder,
      ),
      instance.getPixelY(
        barSpots[i + 1 < size ? i + 1 : i].y,
        viewSize,
        holder,
      ),
    );

    final controlPoint1 = previous + temp;

    /// if the isCurved is false, we set 0 for smoothness,
    /// it means we should not have any smoothness then we face with
    /// the sharped corners line
    final smoothness = barData.isCurved ? barData.curveSmoothness : 0.0;
    temp = ((next - previous) / 2) * smoothness;

    if (barData.preventCurveOverShooting) {
      if ((next - current).dy <= barData.preventCurveOvershootingThreshold ||
          (current - previous).dy <= barData.preventCurveOvershootingThreshold) {
        temp = Offset(temp.dx, 0);
      }

      if ((next - current).dx <= barData.preventCurveOvershootingThreshold ||
          (current - previous).dx <= barData.preventCurveOvershootingThreshold) {
        temp = Offset(0, temp.dy);
      }
    }

    final controlPoint2 = current - temp;

    if (i == size - 2) {
      final t = findT(
        x,
        previous,
        controlPoint1,
        controlPoint2,
        current,
        initialT: initialT,
        epsilon: 1e-1,
      );
      final y = cubicBezierCurveY(t, previous, controlPoint1, controlPoint2, current);

      return (y, t);
    }
  }

  return (0, 0);
}

double cubicBezierCurveY(double t, Offset p0, Offset p1, Offset p2, Offset p3) {
  final y = pow(1 - t, 3) * p0.dy + 3 * pow(1 - t, 2) * t * p1.dy + 3 * (1 - t) * pow(t, 2) * p2.dy + pow(t, 3) * p3.dy;
  return y;
}

double findT(
  double x,
  Offset p0,
  Offset p1,
  Offset p2,
  Offset p3, {
  double epsilon = 1e-6,
  double maxIterations = 100,
  double initialT = 0,
}) {
  var t0 = 0.0;
  var t1 = 1.0;

  // Perform bisection to find t
  for (var i = 0; i < maxIterations; i++) {
    // Calculate the midpoint of the interval
    final t = (t0 + t1) / 2.0;

    // Calculate the X value at the current t
    final xT = (1 - t) * (1 - t) * (1 - t) * p0.dx +
        3 * (1 - t) * (1 - t) * t * p1.dx +
        3 * (1 - t) * t * t * p2.dx +
        t * t * t * p3.dx;

    // Check if the current X value is close enough to the desired X value
    if ((xT - x).abs() < epsilon) {
      return t;
    }

    // Update the interval based on the X value
    if (xT < x) {
      t0 = t;
    } else {
      t1 = t;
    }
  }

  // If the desired precision is not achieved within the maximum iterations,
  // return the best approximation found
  return t1;
}
