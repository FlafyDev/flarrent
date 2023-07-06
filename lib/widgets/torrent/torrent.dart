import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.color,
    required this.progress,
  });

  final Paint _paint = Paint();
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = color
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        10,
      );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width * progress + 10, size.height),
      _paint,
    );
    // final closedPath = path.shift(Offset.zero)
    //   ..relativeLineTo(0, -size.height)
    //   ..relativeLineTo(-size.width * 2, 0)
    //   ..close();
    // canvas
    //   ..drawPath(
    //     closedPath,
    //     Paint()
    //       ..style = PaintingStyle.fill
    //       ..blendMode = BlendMode.clear,
    //   )
    //   ..restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

class TorrentTile extends HookConsumerWidget {
  const TorrentTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 22,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              clipper: RectCustomClipper(
                (size) => Rect.fromLTWH(
                  0,
                  size.height - 5,
                  size.width * 0.5,
                  size.height - 5,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.lightBlue),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                painter: _GlowPainter(
                  color: Colors.lightBlue.shade700.withOpacity(0.7),
                  progress: 0.5,
                ),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            splashColor: Colors.blue.shade700.withOpacity(0.2),
            highlightColor: Colors.blue.shade700.withOpacity(0.2),
            // style: ButtonStyle(
            //   padding: MaterialStatePropertyAll(EdgeInsets.zero),
            //   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //     RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            //   shadowColor: MaterialStatePropertyAll(Colors.black),
            //   foregroundColor:
            //       MaterialStatePropertyAll(Color.fromARGB(255, 85, 188, 228)),
            //   backgroundColor:
            //       MaterialStatePropertyAll(Color.fromARGB(57, 7, 10, 50)),
            // ),
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "[Cerberus] KonoSuba S1 + S2 + OVA + Movie [BD 1080p HEVC 10-bit OPUS] [Dual-Audio]",
                    style: TextStyle(
                      color: Color.fromARGB(255, 85, 188, 228),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("2.2 of 4.9 GiB    45%",
                          style: TextStyle(
                              color: Color.fromARGB(255, 62, 107, 159))),
                      Text("2m 33s     4.4 MB/s",
                          style: TextStyle(
                              color: Color.fromARGB(255, 62, 107, 159))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    // return Container(
    //   child: ColoredBox(color: Colors.amber),
    // );
  }
}

class RectCustomClipper extends CustomClipper<Rect> {
  const RectCustomClipper(Rect Function(Size size) getClip)
      : _getClip = getClip;

  final Rect Function(Size size) _getClip;

  @override
  Rect getClip(Size size) => _getClip(size);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) =>
      oldClipper != this;
}
