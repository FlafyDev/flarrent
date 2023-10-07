import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:torrent_frontend/state/torrents.dart';
import 'package:torrent_frontend/utils/equal.dart';
import 'package:torrent_frontend/utils/generic_join.dart';
import 'package:torrent_frontend/utils/multiselect_algo.dart';
import 'package:torrent_frontend/widgets/common/button.dart';
import 'package:torrent_frontend/widgets/common/side_popup.dart';
import 'package:torrent_frontend/widgets/torrent/torrent.dart';

class OverviewFiles extends HookConsumerWidget {
  const OverviewFiles({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = useState(<String>[]);
    final selectedFilesIndexes = useValueNotifier(<int>[]);
    final hideRulerAC = useAnimationController(
      duration: const Duration(milliseconds: 200),
      initialValue: 1,
    );

    useValueChanged<int, Object>(id, (_, __) {
      path.value = [];
      selectedFilesIndexes.value = [];
      return;
    });

    useValueChanged<List<String>, Object>(path.value, (_, __) {
      selectedFilesIndexes.value = [];
      return;
    });

    useEffect(
      () {
        void callback() {
          if (selectedFilesIndexes.value.isEmpty) {
            hideRulerAC.animateTo(1, curve: Curves.easeOutExpo);
          } else {
            hideRulerAC.animateTo(0, curve: Curves.easeOutExpo);
          }
        }

        selectedFilesIndexes.addListener(callback);
        return () => selectedFilesIndexes.removeListener(callback);
      },
      [],
    );

    final displayPathsList = ['/', ...path.value];
    final theme = Theme.of(context);

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
                          Transform.flip(
                            flipY: true,
                            child: IconButton(
                              icon: const Icon(Icons.low_priority),
                              splashRadius: 15,
                              // iconSize: 18,
                              onPressed: () {},
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.pause),
                            splashRadius: 15,
                            // iconSize: 18,
                            onPressed: () {
                              ref.read(torrentsProvider.notifier).pauseFiles(
                                    id,
                                    selectedFilesIndexes.value,
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
                                    selectedFilesIndexes.value,
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
                            color: Colors.blue.withOpacity(0.2),
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

                      final hierarchy = _convertToDirectoryHierarchy(
                        files.map((e) => e.name).toList(),
                      );
                      var currentDirectory = hierarchy;
                      for (final dir in path.value) {
                        currentDirectory = currentDirectory[dir] as Map<dynamic, dynamic>;
                      }

                      final orderedFiles = currentDirectory;

                      return ValueListenableBuilder(
                        valueListenable: selectedFilesIndexes,
                        builder: (context, selectedIndexes, child) {
                          return ResponsiveGridList(
                            verticalGridMargin: 0,
                            horizontalGridMargin: 0,
                            horizontalGridSpacing: 4,
                            verticalGridSpacing: 4,
                            minItemWidth: 230,
                            listViewBuilderOptions: ListViewBuilderOptions(),
                            children: orderedFiles.entries.map(
                              (e) {
                                if (e.value != null) {
                                  // Directory
                                  final name = e.key as String;
                                  return InkButton(
                                    key: ValueKey(name),
                                    borderRadius: BorderRadius.circular(5),
                                    onPressed: () {
                                      path.value = [...path.value, name];
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: theme.colorScheme.onSecondary.withOpacity(0.2),
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      width: double.infinity,
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: theme.colorScheme.onSecondary.withRed(255).withGreen(255),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final index = e.key as int;

                                final file = files[index];

                                return TorrentFileTile(
                                  key: ValueKey(index),
                                  torrentState: torrentState,
                                  fileData: file.copyWith(
                                    name: file.name.split('/').last,
                                  ),
                                  selected: selectedIndexes.contains(index),
                                  onPressed: () {
                                    selectedFilesIndexes.value = multiselectAlgo(
                                      selectedIndexes: selectedFilesIndexes.value,
                                      index: index,
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
