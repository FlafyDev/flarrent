import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/models/torrent.dart';
import 'package:torrent_frontend/utils/units.dart';
import 'package:torrent_frontend/widgets/common/button.dart';

class TorrentTile extends HookConsumerWidget {
  const TorrentTile({
    super.key,
    required this.quickData,
    this.onPressed,
  });

  final TorrentQuickData quickData;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const borderRadius = 10.0;
    final theme = Theme.of(context);
    final progress = quickData.downloadedBytes / quickData.sizeToDownloadBytes;
    final sizeUnit = detectUnit(quickData.sizeToDownloadBytes);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 22,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: theme.colorScheme.onSecondary.withOpacity(0.2),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              clipper: RectCustomClipper(
                (size) => Rect.fromLTWH(
                  0,
                  size.height - 5,
                  size.width * progress,
                  size.height - 5,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: Colors.lightBlue),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: CustomPaint(
                painter: _GlowPainter(
                  color: Colors.lightBlue.withOpacity(0.7),
                  progress: progress,
                ),
              ),
            ),
          ),
          InkButton(
            borderRadius: BorderRadius.circular(borderRadius),
            onPressed: onPressed ?? () {},
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: quickData.name,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: theme.colorScheme.onSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      Text(
                        '''${fromBytesToUnit(quickData.downloadedBytes, unit: sizeUnit).toStringAsFixed(2)} of ${fromBytesToUnit(quickData.sizeToDownloadBytes, unit: sizeUnit).toStringAsFixed(2)} ${sizeUnit.name}    ${(progress * 100).floor()}%''',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 62, 107, 159),
                        ),
                      ),
                      const Spacer(),
                      _PriorityIcon(
                        quickData.priority,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 62, 107, 159),
                          ),
                          children: [
                            TextSpan(
                              text: formatDuration(quickData.estimatedTimeLeft),
                            ),
                            const WidgetSpan(child: SizedBox(width: 10)),
                            TextSpan(
                              text:
                                  '${fromBytesToUnit(quickData.downloadBytesPerSecond).toStringAsFixed(2)} ${detectUnit(quickData.downloadBytesPerSecond).name}/s',
                              style: quickData.limited
                                  ? const TextStyle(
                                      color: Color.fromARGB(255, 150, 107, 159),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TorrentFileTile extends HookConsumerWidget {
  const TorrentFileTile({
    super.key,
    required this.fileData,
    this.onPressed,
  });

  final TorrentFileData fileData;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const borderRadius = 5.0;
    final theme = Theme.of(context);
    final progress = fileData.downloadedBytes / fileData.sizeBytes;
    final sizeUnit = detectUnit(fileData.sizeBytes);

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: theme.colorScheme.onSecondary.withOpacity(0.2),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: ClipRect(
            clipper: RectCustomClipper(
              (size) => Rect.fromLTWH(
                0,
                size.height - 5,
                size.width * progress,
                size.height - 5,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: Colors.lightBlue),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: CustomPaint(
              painter: _GlowPainter(
                color: Colors.lightBlue.withOpacity(0.7),
                progress: progress,
              ),
            ),
          ),
        ),
        Positioned(
          child: InkButton(
            borderRadius: BorderRadius.circular(borderRadius),
            onPressed: onPressed ?? () {},
            child: Container(
              padding: const EdgeInsets.all(5),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: fileData.name,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: theme.colorScheme.onSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const WidgetSpan(
                          child: SizedBox(
                            width: 5,
                          ),
                        ),
                        TextSpan(
                          text:
                              '''${fromBytesToUnit(fileData.downloadedBytes, unit: sizeUnit).toStringAsFixed(2)} of ${fromBytesToUnit(fileData.sizeBytes, unit: sizeUnit).toStringAsFixed(2)} ${sizeUnit.name} (${(progress * 100).floor()}%)''',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color.fromARGB(255, 62, 107, 159),
                          ),
                        ),
                        WidgetSpan(
                          child: _PriorityIcon(
                            fileData.priority,
                            size: 15,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
    // return Container(
    //   child: ColoredBox(color: Colors.amber),
    // );
  }
}

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
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        10,
      );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width * progress + 10, size.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

class _PriorityIcon extends StatelessWidget {
  const _PriorityIcon(this.priority, {super.key, required this.size});

  final TorrentPriority priority;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (priority == TorrentPriority.medium) return const SizedBox();
    return Icon(
      priority == TorrentPriority.high
          ? Icons.arrow_drop_up
          : Icons.arrow_drop_down,
      color: priority == TorrentPriority.high
          ? Theme.of(context).colorScheme.onSecondary
          : const Color.fromARGB(255, 150, 107, 159),
      size: size,
    );
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
