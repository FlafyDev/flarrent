import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/models/torrent.dart';
import 'package:torrent_frontend/utils/rect_custom_clipper.dart';
import 'package:torrent_frontend/utils/safe_divide.dart';
import 'package:torrent_frontend/utils/units.dart';
import 'package:torrent_frontend/widgets/common/button.dart';

Color _stateToColor(TorrentState state) => switch (state) {
      TorrentState.queued => Colors.yellowAccent,
      TorrentState.paused => Colors.grey,
      TorrentState.error => Colors.pinkAccent,
      TorrentState.downloading => Colors.greenAccent,
      TorrentState.seeding => Colors.purpleAccent,
      TorrentState.completed => Colors.lightBlue,
    };

class _Shell extends StatelessWidget {
  const _Shell({
    required this.borderRadius,
    required this.progress,
    required this.color,
    required this.selected,
    required this.child,
    super.key,
  });

  final double borderRadius;
  final double progress;
  final Color color;
  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: theme.colorScheme.onSecondary.withOpacity(0.2),
              ),
              color: selected ? Colors.blue.withOpacity(0.2) : null,
            ),
          ),
        ),

        Positioned.fill(
          child: ClipRect(
            clipper: RectCustomClipper(
              (size) => Rect.fromLTWH(
                0,
                size.height - 5,
                size.width,
                size.height - 5,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: color.withOpacity(color.alpha / 255 * 0.3)),
              ),
            ),
          ),
        ),

        // Progress
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
                border: Border.all(color: color),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: CustomPaint(
              painter: _GlowPainter(
                color: color.withOpacity(0.7),
                progress: progress,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class TorrentTile extends HookConsumerWidget {
  const TorrentTile({
    super.key,
    required this.quickData,
    required this.selected,
    this.onPressed,
  });

  final TorrentQuickData quickData;
  final void Function()? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const borderRadius = 10.0;
    final theme = Theme.of(context);
    final progress = safeDivide(
      quickData.downloadedBytes / quickData.sizeToDownloadBytes,
    );
    final color = _stateToColor(quickData.state);

    return DecoratedBox(
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
      child: _Shell(
        borderRadius: borderRadius,
        progress: progress,
        color: color,
        selected: selected,
        child: InkButton(
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
                      '''${stringBytesOfWithUnits(quickData.downloadedBytes, quickData.sizeBytes)}    ${(progress * 100).floor()}%''',
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
                    Builder(
                      builder: (context) {
                        return RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 62, 107, 159),
                            ),
                            children: [
                              if (quickData.state == TorrentState.downloading &&
                                  quickData.estimatedTimeLeft.inSeconds > 0)
                                TextSpan(
                                  text: formatDuration(
                                    quickData.estimatedTimeLeft,
                                  ),
                                ),
                              if (quickData.state == TorrentState.downloading ||
                                  quickData.state == TorrentState.seeding)
                                const WidgetSpan(child: SizedBox(width: 10)),
                              if (quickData.state == TorrentState.seeding)
                                TextSpan(
                                  text: '${stringBytesWithUnits(quickData.uploadBytesPerSecond)}/s',
                                  style: quickData.uploadLimited
                                      ? const TextStyle(
                                          color: Color.fromARGB(255, 150, 107, 159),
                                        )
                                      : null,
                                ),
                              if (quickData.state == TorrentState.seeding)
                                WidgetSpan(
                                  child: Icon(
                                    Icons.arrow_upward,
                                    size: 15,
                                    color: quickData.uploadLimited
                                        ? const Color.fromARGB(255, 150, 107, 159)
                                        : const Color.fromARGB(255, 62, 107, 159),
                                  ),
                                ),
                              if (quickData.state == TorrentState.downloading)
                                TextSpan(
                                  text: '${stringBytesWithUnits(quickData.downloadBytesPerSecond)}/s',
                                  style: quickData.downloadLimited
                                      ? const TextStyle(
                                          color: Color.fromARGB(255, 150, 107, 159),
                                        )
                                      : null,
                                ),
                              if (quickData.state == TorrentState.downloading)
                                WidgetSpan(
                                  child: Icon(
                                    Icons.arrow_downward,
                                    size: 15,
                                    color: quickData.downloadLimited
                                        ? const Color.fromARGB(255, 150, 107, 159)
                                        : const Color.fromARGB(255, 62, 107, 159),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TorrentFileTile extends HookConsumerWidget {
  const TorrentFileTile({
    super.key,
    required this.torrentState,
    required this.fileData,
    required this.selected,
    this.onPressed,
  });

  final TorrentState torrentState;
  final TorrentFileData fileData;
  final bool selected;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const borderRadius = 5.0;
    final theme = Theme.of(context);
    final progress = safeDivide(fileData.downloadedBytes / fileData.sizeBytes);
    final color = _stateToColor(
      fileData.state == TorrentState.downloading && torrentState != TorrentState.downloading
          ? TorrentState.paused
          : fileData.state,
    );

    return _Shell(
      borderRadius: borderRadius,
      progress: progress < 0.02 ? 0 : progress,
      color: color,
      selected: selected,
      child: Opacity(
        opacity: fileData.state == TorrentState.paused ? 0.5 : 1,
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
                            '''${stringBytesOfWithUnits(fileData.downloadedBytes, fileData.sizeBytes)} (${(progress * 100).floor()}%)''',
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
  const _PriorityIcon(this.priority, {required this.size});

  final TorrentPriority priority;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (priority == TorrentPriority.normal) return const SizedBox();
    return Icon(
      priority == TorrentPriority.high ? Icons.arrow_drop_up : Icons.arrow_drop_down,
      color: priority == TorrentPriority.high
          ? Theme.of(context).colorScheme.onSecondary
          : const Color.fromARGB(255, 150, 107, 159),
      size: size,
    );
  }
}
