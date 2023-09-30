import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/state/torrents.dart';
import 'package:torrent_frontend/utils/multiselect_algo.dart';
import 'package:torrent_frontend/widgets/torrent/torrent.dart';
import 'package:torrent_frontend/widgets/torrent/torrent_overview/torrent_overview.dart';

class MainView extends HookConsumerWidget {
  const MainView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomExpandedAC = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final bottomHideAC = useAnimationController(
      duration: const Duration(milliseconds: 300),
      initialValue: 1,
    );
    final rulerHideAC = useAnimationController(
      duration: const Duration(milliseconds: 500),
      initialValue: 1,
    );
    final easeOutAnimation = useRef(
      CurvedAnimation(
        parent: bottomExpandedAC,
        curve: Curves.easeOutExpo,
        reverseCurve: Curves.easeOutExpo.flipped,
      ),
    ).value;
    final hideAnimation = useRef(
      CurvedAnimation(
        parent: bottomHideAC,
        curve: Curves.easeOutExpo,
        reverseCurve: Curves.easeOutExpo.flipped,
      ),
    ).value;
    final rulerAnimation = useRef(
      CurvedAnimation(
        parent: rulerHideAC,
        curve: Curves.easeOutExpo,
        reverseCurve: Curves.easeOutExpo.flipped,
      ),
    ).value;
    final selectedTorrentIds = useValueNotifier<List<int>>([]);

    useEffect(
      () {
        void callback() {
          if (selectedTorrentIds.value.length == 1) {
            bottomHideAC.reverse();
          } else {
            bottomHideAC.forward();
          }

          if (selectedTorrentIds.value.isEmpty) {
            rulerHideAC.forward();
          } else {
            rulerHideAC.reverse();
          }
        }

        selectedTorrentIds.addListener(callback);
        return () => selectedTorrentIds.removeListener(callback);
      },
      [],
    );

    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(10).copyWith(bottom: 0),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final torrentsQuickData = ref.watch(
                        torrentsProvider.select((v) => v.quickTorrents),
                      );

                      final orderedTorrents = torrentsQuickData;

                      return ValueListenableBuilder(
                        valueListenable: selectedTorrentIds,
                        builder: (context, ids, child) {
                          return ListView.separated(
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: 10,
                            ),
                            itemCount: orderedTorrents.length,
                            itemBuilder: (context, index) {
                              return TorrentTile(
                                selected:
                                    ids.contains(orderedTorrents[index].id),
                                quickData: orderedTorrents[index],
                                onPressed: () {
                                  selectedTorrentIds.value = multiselectAlgo(
                                    selectedIndexes: selectedTorrentIds.value
                                        .map(
                                          (id) => orderedTorrents
                                              .indexWhere((e) => e.id == id),
                                        )
                                        .toList(),
                                    index: index,
                                  ).map((i) => orderedTorrents[i].id).toList();
                                },
                                // onPressed: () {
                                //   final shiftKeys = [
                                //     LogicalKeyboardKey.shiftLeft,
                                //     LogicalKeyboardKey.shiftRight
                                //   ];
                                //
                                //   final ctrlKeys = [
                                //     LogicalKeyboardKey.control,
                                //     LogicalKeyboardKey.controlLeft,
                                //     LogicalKeyboardKey.controlRight,
                                //   ];
                                //
                                //   final isShiftPressed = RawKeyboard
                                //       .instance.keysPressed
                                //       .where(shiftKeys.contains)
                                //       .isNotEmpty;
                                //
                                //   final isCtrlPressed = RawKeyboard
                                //       .instance.keysPressed
                                //       .where(ctrlKeys.contains)
                                //       .isNotEmpty;
                                //
                                //   if (isShiftPressed &&
                                //       selectedTorrentIds.value.isNotEmpty) {
                                //     var firstIndex = orderedTorrents.length;
                                //     var lastIndex = 0;
                                //
                                //     for (final id in selectedTorrentIds.value) {
                                //       firstIndex = min(
                                //         firstIndex,
                                //         orderedTorrents
                                //             .indexWhere((e) => e.id == id),
                                //       );
                                //       lastIndex = max(
                                //         lastIndex,
                                //         orderedTorrents
                                //             .indexWhere((e) => e.id == id),
                                //       );
                                //     }
                                //
                                //     if (firstIndex < index) {
                                //       selectedTorrentIds.value = {
                                //         for (var i = firstIndex;
                                //             i <= index;
                                //             i++)
                                //           orderedTorrents[i].id,
                                //       }.toList();
                                //     } else {
                                //       selectedTorrentIds.value = {
                                //         for (var i = index;
                                //             i <= lastIndex;
                                //             i++)
                                //           orderedTorrents[i].id,
                                //       }.toList();
                                //
                                //     }
                                //   } else if (isCtrlPressed) {
                                //     selectedTorrentIds.value = {
                                //       ...selectedTorrentIds.value,
                                //       orderedTorrents[index].id,
                                //     }.toList();
                                //   } else {
                                //     final id = orderedTorrents[index].id;
                                //
                                //     if (selectedTorrentIds.value.length == 1 &&
                                //         selectedTorrentIds.value.first == id) {
                                //       selectedTorrentIds.value = [];
                                //     } else {
                                //       selectedTorrentIds.value = [id];
                                //     }
                                //   }
                                // },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: hideAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: (1 - hideAnimation.value),
                    child: child,
                  );
                },
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: rulerAnimation,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment.bottomRight,
                    child: Opacity(
                      opacity: min(1, (1 - rulerAnimation.value) * 10),
                      child: SizedBox(
                        height: 50,
                        width: 340,
                        child: Stack(
                          children: [
                            Positioned(
                              height: 50,
                              width: 340,
                              top: (50 * rulerAnimation.value).roundToDouble(),
                              child: child!,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRect(
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
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.low_priority),
                              splashRadius: 20,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              splashRadius: 20,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.folder_outlined),
                              splashRadius: 20,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.speed),
                              splashRadius: 20,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.link),
                              splashRadius: 20,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.pause),
                              splashRadius: 20,
                              onPressed: () {
                                ref.read(torrentsProvider.notifier).pause(
                                      selectedTorrentIds.value,
                                    );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_arrow_outlined),
                              splashRadius: 20,
                              onPressed: () {
                                ref.read(torrentsProvider.notifier).resume(
                                      selectedTorrentIds.value,
                                    );
                              },
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        AnimatedBuilder(
          animation: Listenable.merge([easeOutAnimation, hideAnimation]),
          builder: (context, child) {
            const hidePoint = 0.90;
            final value = easeOutAnimation.value + hideAnimation.value;
            return value < hidePoint
                ? Opacity(
                    opacity: 1 - value / hidePoint,
                    child: Divider(
                      color: theme.colorScheme.onSecondary,
                      height: 1,
                    ),
                  )
                : Container();
          },
        ),
        AnimatedBuilder(
          animation: Listenable.merge([easeOutAnimation, hideAnimation]),
          builder: (context, child) {
            final height =
                max(MediaQuery.of(context).size.height * 0.3, 200).toDouble();
            final expandedHeight = height +
                (MediaQuery.of(context).size.height - height) *
                    easeOutAnimation.value;
            return SizedBox(
              height: (1 - hideAnimation.value) * expandedHeight,
              child: Stack(
                children: [
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    height: expandedHeight,
                    child: child!,
                  ),
                ],
              ),
            );
          },
          child: Stack(
            children: [
              ValueListenableBuilder(
                valueListenable: selectedTorrentIds,
                builder: (context, ids, child) {
                  if (ids.length != 1) {
                    return Container();
                  }
                  return TorrentOverview(id: ids.first);
                },
              ),
              SizedBox(
                height: 10,
                child: GestureDetector(
                  onTap: () {
                    if (bottomExpandedAC.isCompleted) {
                      bottomExpandedAC.reverse();
                    } else {
                      bottomExpandedAC.forward();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter({
    required this.color,
  });

  final Paint _paint = Paint();
  final Paint _paint2 = Paint();
  final Paint _paint3 = Paint();
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 1.0;
    const smoothLength = 50.0;
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..isAntiAlias = true
      ..color = color;
    _paint2
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    _paint3
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        10,
      );

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
    // canvas.drawPath(, _paint);
    canvas
      // ..drawPath(
      //   path,
      //   _paint3,
      // )
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
