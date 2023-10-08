import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/models/filters.dart';
import 'package:torrent_frontend/models/torrent.dart';
import 'package:torrent_frontend/state/filters.dart';
import 'package:torrent_frontend/state/torrents.dart';
import 'package:torrent_frontend/utils/equal.dart';
import 'package:torrent_frontend/utils/multiselect_algo.dart';
import 'package:torrent_frontend/utils/rect_custom_clipper.dart';
import 'package:torrent_frontend/utils/units.dart';
import 'package:torrent_frontend/utils/use_values_changed.dart';
import 'package:torrent_frontend/widgets/common/side_popup.dart';
import 'package:torrent_frontend/widgets/torrent/torrent.dart';
import 'package:torrent_frontend/widgets/torrent/torrent_overview/torrent_overview.dart';
import 'package:url_launcher/url_launcher.dart';

class MainView extends HookConsumerWidget {
  const MainView({
    required this.menuPlace,
    required this.onMenuPlaceEnter,
    required this.onMenuPlaceExit,
    super.key,
  });

  final bool menuPlace;
  final VoidCallback onMenuPlaceEnter;
  final VoidCallback onMenuPlaceExit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomExpandedAC = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final bottomHideAC = useAnimationController(
      duration: const Duration(milliseconds: 300),
      initialValue: 1,
    );
    final rulerShowAC = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );
    final easeOutAnimation = useRef(
      CurvedAnimation(
        parent: bottomExpandedAC,
        curve: Curves.easeOutExpo,
        reverseCurve: Curves.easeOutExpo.flipped,
      ),
    ).value;
    final selectedTorrentIds = useValueNotifier<List<int>>([]);

    ref.listen(
        torrentsProvider.select(
          (e) => Equal(
            e.quickTorrents,
            const DeepCollectionEquality().equals,
          ),
        ), (prev, next) {
      final ids = next.value.map((e) => e.id);
      selectedTorrentIds.value = selectedTorrentIds.value.where(ids.contains).toList();
    });

    useEffect(
      () {
        void callback() {
          if (selectedTorrentIds.value.length == 1) {
            bottomHideAC.animateTo(0, curve: Curves.easeOutExpo);
          } else {
            bottomHideAC.animateTo(1, curve: Curves.easeOutExpo);
          }

          if (selectedTorrentIds.value.isEmpty) {
            rulerShowAC.animateTo(0, curve: Curves.easeOutExpo);
          } else {
            rulerShowAC.animateTo(1, curve: Curves.easeOutExpo);
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
                child: Consumer(
                  builder: (context, ref, child) {
                    final torrentsQuickData = ref.watch(
                      torrentsProvider.select((v) => v.quickTorrents),
                    );
                    final filters = ref.watch(filtersProvider.select((v) => v));

                    final orderedTorrents = torrentsQuickData.where((t) {
                      return t.name.toLowerCase().contains(filters.query.toLowerCase()) &&
                          (filters.states.isEmpty || filters.states.contains(t.state));
                    }).sorted((before, after) {
                      final a = filters.ascending ? before : after;
                      final b = filters.ascending ? after : before;
                      return switch (filters.sortBy) {
                        SortBy.name => a.name.compareTo(b.name),
                        SortBy.size => a.sizeBytes.compareTo(b.sizeBytes),
                        SortBy.downloadSpeed => a.downloadBytesPerSecond.compareTo(b.downloadBytesPerSecond),
                        SortBy.uploadSpeed => a.uploadBytesPerSecond.compareTo(b.uploadBytesPerSecond),
                        SortBy.addedOn => (a.addedOn ?? DateTime.now()).compareTo(b.addedOn ?? DateTime.now()),
                        SortBy.completedOn =>
                          (a.completedOn ?? DateTime.now()).compareTo(b.completedOn ?? DateTime.now()),
                      };
                    });

                    return ValueListenableBuilder(
                      valueListenable: selectedTorrentIds,
                      builder: (context, ids, child) {
                        return ListView.separated(
                          padding: const EdgeInsets.all(10).copyWith(bottom: 0),
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 10,
                          ),
                          itemCount: orderedTorrents.length,
                          itemBuilder: (context, index) {
                            return TorrentTile(
                              selected: ids.contains(orderedTorrents[index].id),
                              quickData: orderedTorrents[index],
                              onPressed: () {
                                selectedTorrentIds.value = multiselectAlgo(
                                  selectedIndexes: selectedTorrentIds.value
                                      .map(
                                        (id) => orderedTorrents.indexWhere((e) => e.id == id),
                                      )
                                      .toList(),
                                  index: index,
                                ).map((i) => orderedTorrents[i].id).toList();
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              if (menuPlace)
                Positioned(
                  width: 120,
                  height: MediaQuery.of(context).size.height,
                  child: MouseRegion(
                    onExit: (e) => onMenuPlaceExit(),
                    onEnter: (e) => onMenuPlaceEnter(),
                  ),
                ),
              AnimatedBuilder(
                animation: bottomHideAC,
                builder: (context, child) {
                  return Opacity(
                    opacity: 1 - bottomHideAC.value,
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
                animation: rulerShowAC,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment.bottomRight,
                    child: Opacity(
                      opacity: min(1, (rulerShowAC.value) * 10),
                      child: Row(
                        children: [
                          const Spacer(),
                          ClipRect(
                            clipper: RectCustomClipper(
                              (size) => Rect.fromLTRB(
                                -1,
                                -1,
                                size.width + 1,
                                size.height + 1,
                              ),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional.topStart,
                              heightFactor: rulerShowAC.value,
                              child: child,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SidePopup(color: theme.colorScheme.onSecondary),
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedTorrentIds,
                      builder: (context, value, child) {
                        return Row(
                          children: [
                            const SizedBox(width: 40),
                            _Tools(torrentIds: value),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AnimatedBuilder(
          animation: Listenable.merge([easeOutAnimation, bottomHideAC]),
          builder: (context, child) {
            const hidePoint = 0.90;
            final value = easeOutAnimation.value + bottomHideAC.value;
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
          animation: Listenable.merge([easeOutAnimation, bottomHideAC]),
          builder: (context, child) {
            final height = max(MediaQuery.of(context).size.height * 0.3, 200).toDouble();
            final expandedHeight = height + (MediaQuery.of(context).size.height - height - 30) * easeOutAnimation.value;
            return SizedBox(
              height: (1 - bottomHideAC.value) * expandedHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Positioned(
                        width: constraints.maxWidth,
                        height: expandedHeight,
                        child: child!,
                      ),
                    ],
                  );
                },
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
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Consumer(
            builder: (context, ref, child) {
              final client = ref.watch(torrentsProvider.select((v) => v.client));
              final downLimitString = client.downloadLimitBytesPerSecond != null
                  ? ' (Limit ${stringBytesWithUnits(client.downloadLimitBytesPerSecond!)})'
                  : '';
              final upLimitString = client.uploadLimitBytesPerSecond != null
                  ? ' (Limit ${stringBytesWithUnits(client.uploadLimitBytesPerSecond!)})'
                  : '';

              return Row(
                children: [
                  if (client.freeSpaceBytes != null)
                    Text(
                      'Free space: ${stringBytesWithUnits(client.freeSpaceBytes!)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  if (client.freeSpaceBytes != null) const SizedBox(width: 20),
                  Text(
                    'Down: ${stringBytesWithUnits(client.downloadSpeedBytesPerSecond)}$downLimitString',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Up: ${stringBytesWithUnits(client.uploadSpeedBytesPerSecond)}$upLimitString',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () async {
                        await ref.read(torrentsProvider.notifier).setAlternativeLimits(
                              enabled: !ref.read(torrentsProvider).client.alternativeSpeedLimitsEnabled,
                            );
                      },
                      child: Icon(
                        Icons.speed,
                        size: 20,
                        color: client.alternativeSpeedLimitsEnabled ? Colors.redAccent : Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        )
      ],
    );
  }
}

class _Tools extends HookConsumerWidget {
  const _Tools({
    required this.torrentIds,
  });

  final List<int> torrentIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickTorrents = ref.watch(
      torrentsProvider.select(
        (v) => torrentIds.isEmpty
            ? <TorrentQuickData>[]
            : v.quickTorrents.where((torrent) => torrentIds.contains(torrent.id)),
      ),
    );
    final torrent = torrentIds.length == 1
        ? ref.read(torrentsProvider).torrents.firstWhereOrNull((t) => t.id == torrentIds.first)
        : null;
    final showSingleTorrentToolsAC = useAnimationController(
      duration: const Duration(milliseconds: 300),
      initialValue: 1,
    );

    useValuesChanged(
      [Equal(torrentIds, const DeepCollectionEquality().equals)],
      callback: () {
        if (torrentIds.length == 1) {
          showSingleTorrentToolsAC.animateTo(1, curve: Curves.easeOutExpo);
        } else if (torrentIds.length >= 2) {
          showSingleTorrentToolsAC.animateTo(0, curve: Curves.easeOutExpo);
        }
      },
    );

    void onSetLimits() {
      showDialog<void>(
        context: context,
        builder: (context) {
          return HookBuilder(
            builder: (context) {
              final downloadSpeed = useTextEditingController();
              final uploadSpeed = useTextEditingController();

              useEffect(
                () {
                  if (torrent != null) {
                    downloadSpeed.text = torrent.downloadLimited
                        ? (torrent.downloadLimitBytesPerSecond / pow(1024, 2)).toStringAsFixed(4)
                        : '';
                    uploadSpeed.text = torrent.uploadLimited
                        ? (torrent.uploadLimitBytesPerSecond / pow(1024, 2)).toStringAsFixed(4)
                        : '';
                  }
                  return;
                },
                [],
              );

              return AlertDialog(
                backgroundColor: Colors.black,
                title: const Text('Set speed limits'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: downloadSpeed,
                      decoration: const InputDecoration(labelText: 'Download speed limit (MiB/s)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: uploadSpeed,
                      decoration: const InputDecoration(labelText: 'Upload speed limit (MiB/s)'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      var downloadLimit =
                          downloadSpeed.text.trim().isNotEmpty ? double.tryParse(downloadSpeed.text) : null;
                      var uploadLimit = uploadSpeed.text.trim().isNotEmpty ? double.tryParse(uploadSpeed.text) : null;
                      if (downloadLimit != null) downloadLimit *= pow(1024, 2);
                      if (uploadLimit != null) uploadLimit *= pow(1024, 2);
                      ref.read(torrentsProvider.notifier).setTorrentsLimit(
                            torrentIds,
                            downloadLimit?.toInt(),
                            uploadLimit?.toInt(),
                          );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (context) {
                final differentPriorities =
                    quickTorrents.isEmpty || quickTorrents.any((t) => t.priority != quickTorrents.first.priority);
                final currentPriority = differentPriorities ? TorrentPriority.normal : quickTorrents.first.priority;

                return Transform.flip(
                  flipY: true,
                  child: IconButton(
                    icon: const Icon(Icons.low_priority),
                    splashRadius: 20,
                    color: torrentPriorityToColor(currentPriority),
                    onPressed: () {
                      ref.read(torrentsProvider.notifier).changePriority(
                            torrentIds,
                            TorrentPriority.values[(currentPriority.index + 1) % TorrentPriority.values.length],
                          );
                    },
                  ),
                );
              },
            ),
            _ToolsBin(
              color: Colors.redAccent,
              onPressed: () {
                ref.read(torrentsProvider.notifier).deleteTorrent(torrentIds, deleteData: true);
              },
            ),
            _ToolsBin(
              color: Colors.white,
              onPressed: () {
                ref.read(torrentsProvider.notifier).deleteTorrent(torrentIds, deleteData: false);
              },
            ),
            AnimatedBuilder(
              animation: showSingleTorrentToolsAC,
              builder: (context, child) {
                return Container(
                  width: 40 * showSingleTorrentToolsAC.value,
                  decoration: const BoxDecoration(),
                  clipBehavior: Clip.hardEdge,
                  child: child,
                );
              },
              child: IconButton(
                icon: const Icon(Icons.folder_outlined),
                splashRadius: 20,
                onPressed: () async {
                  await launchUrl(Uri.parse('file:${torrent?.location}'));
                },
              ),
            ),
            AnimatedBuilder(
              animation: showSingleTorrentToolsAC,
              builder: (context, child) {
                return Container(
                  width: 40 * showSingleTorrentToolsAC.value,
                  decoration: const BoxDecoration(),
                  clipBehavior: Clip.hardEdge,
                  child: child,
                );
              },
              child: IconButton(
                icon: const Icon(Icons.speed),
                splashRadius: 20,
                onPressed: onSetLimits,
              ),
            ),
            // AnimatedBuilder(
            //   animation: showSingleTorrentToolsAC,
            //   builder: (context, child) {
            //     return Container(
            //       width: 40 * showSingleTorrentToolsAC.value,
            //       decoration: const BoxDecoration(),
            //       clipBehavior: Clip.hardEdge,
            //       child: child,
            //     );
            //   },
            //   child: IconButton(
            //     icon: const Icon(Icons.download_outlined),
            //     splashRadius: 20,
            //     onPressed: () { }
            //   ),
            // ),
            AnimatedBuilder(
              animation: showSingleTorrentToolsAC,
              builder: (context, child) {
                return Container(
                  width: 40 * showSingleTorrentToolsAC.value,
                  decoration: const BoxDecoration(),
                  clipBehavior: Clip.hardEdge,
                  child: child,
                );
              },
              child: IconButton(
                icon: const Icon(Icons.link),
                splashRadius: 20,
                onPressed: () async {
                  if (torrent?.magnet != null) {
                    await Clipboard.setData(ClipboardData(text: torrent!.magnet!));
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.pause),
              splashRadius: 20,
              onPressed: () {
                ref.read(torrentsProvider.notifier).pause(torrentIds);
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow_outlined),
              splashRadius: 20,
              onPressed: () {
                ref.read(torrentsProvider.notifier).resume(torrentIds);
              },
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolsBin extends HookConsumerWidget {
  const _ToolsBin({
    required this.color,
    required this.onPressed,
    super.key,
  });

  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdAC = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    useEffect(
      () {
        void callback(AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            holdAC.reset();
            onPressed();
          }
        }

        holdAC.addStatusListener(callback);

        return () => holdAC.removeStatusListener(callback);
      },
      [holdAC, onPressed],
    );

    return Center(
      child: Stack(
        children: [
          SizedBox(
            width: 40,
            child: InkWell(
              radius: 20,
              customBorder: const CircleBorder(),
              onTapUp: (e) {
                holdAC.reset();
              },
              onTapDown: (e) {
                holdAC.forward(from: 0);
              },
              child: Ink(
                decoration: const BoxDecoration(shape: BoxShape.circle),
                height: double.infinity,
                width: double.infinity,
                child: Icon(
                  Icons.delete_outline,
                  color: color,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: SizedBox(
                  width: 35,
                  height: 35,
                  child: AnimatedBuilder(
                    animation: holdAC,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: holdAC.value,
                        color: ColorTween(begin: Colors.white, end: Colors.redAccent).transform(holdAC.value),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
