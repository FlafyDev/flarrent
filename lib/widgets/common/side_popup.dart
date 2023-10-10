import 'package:flutter/material.dart';
import 'package:flarrent/utils/rect_custom_clipper.dart';

class SidePopup extends StatelessWidget {
  const SidePopup({
    required this.color,
    this.smoothLength = 50.0,
    super.key,
  });

  final Color color;
  final double smoothLength;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipper: RectCustomClipper(
        (size) => Rect.fromLTRB(
          -100,
          -100,
          size.width + 100,
          size.height,
        ),
      ),
      child: CustomPaint(
        painter: _PathPainter(
          color: color,
          smoothLength: smoothLength,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter({
    required this.color,
    required this.smoothLength,
  });

  final Paint _paint = Paint();
  final Paint _paint2 = Paint();
  final Color color;
  final double smoothLength;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 1.0;
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..isAntiAlias = true
      ..color = color;
    _paint2
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    final path = Path()
      ..moveTo(0, size.height + 1)
      ..cubicTo(
        smoothLength / 2,
        size.height + 1,
        smoothLength / 2,
        0,
        smoothLength,
        0,
      )
      ..lineTo(size.width, stroke);
    canvas
      ..drawPath(
        Path.from(path)..lineTo(size.width, size.height + 1),
        _paint2,
      )
      ..drawPath(
        path,
        _paint,
      );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
