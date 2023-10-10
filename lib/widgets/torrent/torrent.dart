import 'package:flarrent/models/torrent.dart';
import 'package:flarrent/utils/rect_custom_clipper.dart';
import 'package:flarrent/utils/safe_divide.dart';
import 'package:flarrent/utils/units.dart';
import 'package:flarrent/widgets/common/button.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Color _stateToColor(TorrentState state) => switch (state) {
      TorrentState.queued => Colors.yellowAccent,
      TorrentState.paused => Colors.grey,
      TorrentState.error => Colors.pinkAccent,
      TorrentState.downloading => Colors.greenAccent,
      TorrentState.seeding => Colors.purpleAccent,
      TorrentState.completed => Colors.lightBlue,
    };

Color torrentPriorityToColor(TorrentPriority priority) => switch (priority) {
      TorrentPriority.low => const Color.fromARGB(255, 150, 107, 159),
      TorrentPriority.normal => Colors.white,
      TorrentPriority.high => Colors.lightBlue,
    };

class _Shell extends StatelessWidget {
  const _Shell({
    required this.borderRadius,
    required this.progress,
    required this.color,
    required this.selected,
    required this.child,
    // ignore: unused_element
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
              color: selected ? theme.colorScheme.onSecondary.withOpacity(0.2) : null,
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
    final progress = safeDivide(quickData.downloadedBytes / quickData.sizeToDownloadBytes, 1);
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
                      '''${_stringBytesOfDoneWithUnits(quickData.downloadedBytes, quickData.sizeToDownloadBytes, quickData.sizeBytes)}    ${(progress * 100).floor()}%''',
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorTween(begin: theme.colorScheme.onSecondary, end: Colors.black).transform(0.4),
                      ),
                    ),
                    const Spacer(),
                    _PriorityIcon(
                      quickData.priority,
                      size: 16,
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
    this.titleColor,
    this.onPressed,
  });

  final TorrentState torrentState;
  final TorrentFileData fileData;
  final bool selected;
  final Color? titleColor;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const borderRadius = 5.0;
    final theme = Theme.of(context);
    final progress = safeDivide(fileData.downloadedBytes / fileData.sizeBytes, 1);
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
                          color: titleColor ?? theme.colorScheme.onSecondary,
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
                            '''${_stringBytesOfWithUnits(fileData.downloadedBytes, fileData.sizeBytes)} (${(progress * 100).floor()}%)''',
                        style: TextStyle(
                          fontSize: 11,
                          color: ColorTween(begin: theme.colorScheme.onSecondary, end: Colors.black).transform(0.4),
                        ),
                      ),
                      WidgetSpan(
                        child: _PriorityIcon(
                          fileData.priority,
                          size: 13,
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
      color: torrentPriorityToColor(priority),
      size: size,
    );
  }
}


String _stringBytesOfWithUnits(int bytes1, int bytes2, {Unit? unit}) {
  final u1 = detectUnit(bytes1).name;
  final u2 = detectUnit(bytes2).name;
  final b1 = fromBytesToUnit(bytes1, unit: unit);
  final b2 = fromBytesToUnit(bytes2, unit: unit);

  if (u1 == u2) {
    return '$b1 of $b2 $u2';
  } else {
    return '$b1 $u1 of $b2 $u2';
  }
}

String _stringBytesOfDoneWithUnits(int bytes1, int bytes2, int bytes3, {Unit? unit}) {
  if (bytes3 == bytes2) return _stringBytesOfWithUnits(bytes1, bytes2, unit: unit);
 
  final u1 = detectUnit(bytes1).name;
  final u2 = detectUnit(bytes2).name;
  final u3 = detectUnit(bytes3).name;
  final b1 = fromBytesToUnit(bytes1, unit: unit);
  final b2 = fromBytesToUnit(bytes2, unit: unit);
  final b3 = fromBytesToUnit(bytes3, unit: unit);

  if (u1 == u2 && u1 == u3) {
    return '$b1 of $b2 ($b3) $u2';
  } else if (u1 == u2 && u1 != u3) {
    return '$b1 of $b2 $u2 ($b3 $u3)';
  } else if (u1 != u2 && u1 == u3) {
    return '$b1 $u1 of $b2 ($b3) $u2 ';
  } else {
    return '$b1 $u1 of $b2 $u2 ($b3 $u3)';
  }
}
