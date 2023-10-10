import 'dart:math';

import 'package:flarrent/models/torrent.dart';
import 'package:flarrent/state/torrents.dart';
import 'package:flarrent/utils/equal.dart';
import 'package:flarrent/utils/generic_join.dart';
import 'package:flarrent/utils/multiselect_algo.dart';
import 'package:flarrent/utils/use_values_changed.dart';
import 'package:flarrent/widgets/common/button.dart';
import 'package:flarrent/widgets/common/side_popup.dart';
import 'package:flarrent/widgets/common/smooth_scrolling.dart';
import 'package:flarrent/widgets/torrent/torrent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:url_launcher/url_launcher.dart';

class OverviewFiles extends HookConsumerWidget {
  const OverviewFiles({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = useState(<String>[]);
    final selectedFilesPositions = useState(<int>[]);
    final hideRulerAC = useAnimationController(
      duration: const Duration(milliseconds: 200),
      initialValue: 1,
    );

    final files = ref
        .watch(
          torrentsProvider.select(
            (a) => Equal(
              a.torrents.firstWhere((data) => data.id == id).files,
              const DeepCollectionEquality().equals,
            ),
          ),
        )
        .value;
    final torrentState = ref.watch(
      torrentsProvider.select(
        (a) => a.torrents.firstWhere((data) => data.id == id).state,
      ),
    );

    useValuesChanged(
      [id],
      callback: () {
        path.value = [];
        selectedFilesPositions.value = [];
      },
    );

    useValuesChanged(
      [path.value],
      callback: () {
        selectedFilesPositions.value = [];
      },
    );

    useEffect(
      () {
        void callback() {
          if (selectedFilesPositions.value.isEmpty) {
            hideRulerAC.animateTo(1, curve: Curves.easeOutExpo);
          } else {
            hideRulerAC.animateTo(0, curve: Curves.easeOutExpo);
          }
        }

        selectedFilesPositions.addListener(callback);
        return () => selectedFilesPositions.removeListener(callback);
      },
      [],
    );

    final displayPathsList = ['/', ...path.value];
    final theme = Theme.of(context);

    final hierarchy = _convertToDirectoryHierarchy(
      files.map((e) => e.name).toList(),
    );
    var currentDirectory = hierarchy;
    for (final dir in path.value) {
      currentDirectory = currentDirectory[dir] as Map<dynamic, dynamic>;
    }

    final orderedFiles = currentDirectory;
    final filesWithPosition = orderedFiles.entries.toList().asMap().entries.toList();

    void onNodePress(int position, VoidCallback selectionDefault) {
      selectedFilesPositions.value = multiselectAlgo(
        selectedIndexes: selectedFilesPositions.value,
        index: position,
        selectionDefault: selectionDefault,
      );
    }

    final selectedFileIndexes = _getIndexesRecursively(
      Map<dynamic, dynamic>.fromEntries(
        selectedFilesPositions.value.map((p) => filesWithPosition[p].value),
      ),
    );

    return Column(
      children: [
        Stack(
          children: [
            AnimatedBuilder(
              animation: hideRulerAC,
              builder: (context, child) {
                return Opacity(
                  opacity: min(1, (1 - hideRulerAC.value) * 10),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      width: 160,
                      height: 40,
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: (hideRulerAC.value * 40).roundToDouble(),
                            width: 160,
                            height: 40,
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
                  Transform.flip(
                    flipY: true,
                    child: SidePopup(
                      color: theme.colorScheme.onSecondary,
                      smoothLength: 40,
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Builder(
                            builder: (context) {
                              final selectedFiles = selectedFileIndexes.map((index) => files[index]).toList();
                              final differentPriorities = selectedFiles.isEmpty ||
                                  selectedFiles.any((t) => t.priority != selectedFiles.first.priority);
                              final currentPriority =
                                  differentPriorities ? TorrentPriority.normal : selectedFiles.first.priority;
                              return Transform.flip(
                                flipY: true,
                                child: IconButton(
                                  icon: const Icon(Icons.low_priority),
                                  splashRadius: 15,
                                  // iconSize: 18,
                                  color: torrentPriorityToColor(currentPriority),
                                  onPressed: () {
                                    ref.read(torrentsProvider.notifier).changeFilePriority(
                                          id,
                                          selectedFileIndexes,
                                          TorrentPriority
                                              .values[(currentPriority.index + 1) % TorrentPriority.values.length],
                                        );
                                  },
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.pause),
                            splashRadius: 15,
                            // iconSize: 18,
                            onPressed: () {
                              ref.read(torrentsProvider.notifier).pauseFiles(
                                    id,
                                    selectedFileIndexes,
                                  );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.play_arrow_outlined),
                            splashRadius: 15,
                            // iconSize: 32,
                            onPressed: () {
                              ref.read(torrentsProvider.notifier).resumeFiles(
                                    id,
                                    selectedFileIndexes,
                                  );
                            },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8).copyWith(left: 0),
              child: Row(
                children: displayPathsList
                    .asMap()
                    .entries
                    .map<Widget>(
                      (e) {
                        final dirName = e.value;
                        const radius = 10.0;
                        final radiuses = e.key == 0
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(radius),
                                bottomLeft: Radius.circular(radius),
                              )
                            : (e.key == displayPathsList.length - 1
                                ? const BorderRadius.only(
                                    topRight: Radius.circular(radius),
                                    bottomRight: Radius.circular(radius),
                                  )
                                : BorderRadius.zero);

                        return Container(
                          constraints: const BoxConstraints(
                            maxWidth: 200,
                          ),
                          child: InkButton(
                            padding: const EdgeInsets.all(6),
                            color: theme.colorScheme.surface,
                            borderRadius: radiuses,
                            onPressed: () {
                              path.value = path.value.sublist(0, e.key);
                            },
                            child: Text(
                              dirName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    )
                    .toList()
                    .genericJoin(const SizedBox(width: 4)),
              ),
            ),
          ],
        ),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 8),
                  width: double.infinity,
                  child: Consumer(
                    builder: (context, ref, child) {
                      return SmoothScrolling(
                        multiplier: 1,
                        builder: (context, scrollController, physics) {
                          return ResponsiveGridList(
                            verticalGridMargin: 0,
                            horizontalGridMargin: 0,
                            horizontalGridSpacing: 4,
                            verticalGridSpacing: 4,
                            minItemWidth: 230,
                            listViewBuilderOptions: ListViewBuilderOptions(
                              controller: scrollController,
                              physics: physics,
                            ),
                            children: filesWithPosition.map(
                              (entry) {
                                final position = entry.key;
                                final e = entry.value;

                                if (e.value != null) {
                                  // Directory
                                  final indexes = _getIndexesRecursively(e.value as Map<dynamic, dynamic>);
                                  final inFiles = indexes.map((index) => files[index]).toList();
                                  final inWantedFiles = inFiles.where((f) => f.state != TorrentState.paused).toList();
                                  final name = e.key as String;

                                  final downloadedBytes = inWantedFiles.fold(
                                    0,
                                    (previousValue, element) => previousValue + element.downloadedBytes,
                                  );
                                  final sizeBytes = inWantedFiles.fold(
                                    0,
                                    (previousValue, element) => previousValue + element.sizeBytes,
                                  );
                                  return TorrentFileTile(
                                    titleColor: Colors.yellow,
                                    torrentState: torrentState,
                                    selected: selectedFilesPositions.value.contains(position),
                                    onPressed: () => onNodePress(position, () {
                                      path.value = [...path.value, name];
                                    }),
                                    fileData: TorrentFileData(
                                      name: name,
                                      downloadedBytes: downloadedBytes,
                                      sizeBytes: sizeBytes,
                                      priority: TorrentPriority.normal,
                                      state: sizeBytes == downloadedBytes
                                          ? TorrentState.completed
                                          : inWantedFiles.any((f) => f.state == TorrentState.downloading)
                                              ? TorrentState.downloading
                                              : TorrentState.paused,
                                    ),
                                  );
                                  // return InkButton(
                                  //   key: ValueKey(name),
                                  //   borderRadius: BorderRadius.circular(5),
                                  //   onPressed: () => onNodePress(position, () {
                                  //     path.value = [...path.value, name];
                                  //   }),
                                  //   child: Container(
                                  //     decoration: BoxDecoration(
                                  //       borderRadius: BorderRadius.circular(5),
                                  //       border: Border.all(
                                  //         color: theme.colorScheme.onSecondary.withOpacity(0.2),
                                  //       ),
                                  //       color: selectedFilesPositions.value.contains(position)
                                  //           ? Colors.blue.withOpacity(0.2)
                                  //           : Colors.transparent,
                                  //     ),
                                  //     padding: const EdgeInsets.all(5),
                                  //     width: double.infinity,
                                  //     child: Text(
                                  //       name,
                                  //       style: TextStyle(
                                  //         fontFamily: 'Roboto',
                                  //         color: theme.colorScheme.onSecondary.withRed(255).withGreen(255),
                                  //         fontSize: 12,
                                  //         fontWeight: FontWeight.bold,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // );
                                }

                                final index = e.key as int;
                                final file = files[index];

                                return TorrentFileTile(
                                  key: ValueKey(index),
                                  torrentState: torrentState,
                                  fileData: file.copyWith(
                                    name: file.name.split('/').last,
                                  ),
                                  selected: selectedFilesPositions.value.contains(position),
                                  onPressed: () {
                                    selectedFilesPositions.value = multiselectAlgo(
                                      selectedIndexes: selectedFilesPositions.value,
                                      index: position,
                                      selectionDefault: () => onNodePress(position, () {
                                        final torrent = ref.read(
                                          torrentsProvider.select(
                                            (a) => a.torrents.firstWhere((data) => data.id == id),
                                          ),
                                        );
                                        launchUrl(Uri.parse('file:${torrent.location}/${file.name}'));
                                      }),
                                    );
                                  },
                                );
                              },
                            ).toList(), // The list of widgets in the list
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

List<int> _getIndexesRecursively(Map<dynamic, dynamic> hierarchy) {
  final selectedIndexes = <int>[];

  for (final node in hierarchy.entries) {
    // is file
    if (node.value == null) {
      selectedIndexes.add(node.key as int);
    } else {
      // is folder
      selectedIndexes.addAll(_getIndexesRecursively(node.value as Map<dynamic, dynamic>));
    }
  }

  return selectedIndexes;
}

Map<dynamic, dynamic> _convertToDirectoryHierarchy(List<String> filePaths) {
  final directoryHierarchy = <dynamic, dynamic>{};

  var i = 0;
  for (final filePath in filePaths) {
    final parts = filePath.split('/');
    var currentDir = directoryHierarchy;

    for (var j = 0; j < parts.length - 1; j++) {
      final directoryName = parts[j];
      currentDir.putIfAbsent(directoryName, () => <dynamic, dynamic>{});
      currentDir = currentDir[directoryName] as Map<dynamic, dynamic>;
    }

    currentDir.putIfAbsent(i, () => null);
    i++;
  }

  return directoryHierarchy;
}
