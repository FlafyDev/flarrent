import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:torrent_frontend/models/torrent.dart';
import 'package:torrent_frontend/state/torrents.dart';
import 'package:torrent_frontend/utils/equal.dart';
import 'package:torrent_frontend/utils/generic_join.dart';
import 'package:torrent_frontend/widgets/common/button.dart';
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

    useValueChanged<int, Object>(id, (_, __) {
      path.value = [];
      return;
    });

    final displayPathsList = ['/', ...path.value];
    final theme = Theme.of(context);

    return Column(
      children: [
        Stack(
          children: [
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
                                a.torrents
                                    .firstWhere((data) => data.id == id)
                                    .files,
                                const DeepCollectionEquality().equals,
                              ),
                            ),
                          )
                          .value;

                      final hierarchy = _convertToDirectoryHierarchy(
                        files.map((e) => e.name).toList(),
                      );
                      var currentDirectory = hierarchy;
                      for (final dir in path.value) {
                        currentDirectory =
                            currentDirectory[dir] as Map<String, dynamic>;
                      }
                      return ResponsiveGridList(
                        verticalGridMargin: 0,
                        horizontalGridMargin: 0,
                        horizontalGridSpacing: 4,
                        verticalGridSpacing: 4,
                        minItemWidth: 230,
                        minItemsPerRow: 1,
                        listViewBuilderOptions: ListViewBuilderOptions(),
                        children: currentDirectory.entries.map(
                          (e) {
                            if (e.value != null) {
                              // Directory
                              return InkButton(
                                key: ValueKey(e.key),
                                borderRadius: BorderRadius.circular(5),
                                onPressed: () {
                                  path.value = [...path.value, e.key];
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: theme.colorScheme.onSecondary
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  width: double.infinity,
                                  child: Text(
                                    e.key,
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      color: theme.colorScheme.onSecondary
                                          .withRed(255)
                                          .withGreen(255),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final file = files[int.parse(e.key)];

                            return TorrentFileTile(
                              key: ValueKey(e.key),
                              fileData: file.copyWith(
                                name: file.name.split('/').last,
                              ),
                              onPressed: () {},
                            );
                          },
                        ).toList(), // The list of widgets in the list
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

Map<String, dynamic> _convertToDirectoryHierarchy(List<String> filePaths) {
  final directoryHierarchy = <String, dynamic>{};

  var i = 0;
  for (final filePath in filePaths) {
    final parts = filePath.split('/');
    var currentDir = directoryHierarchy;

    for (var j = 0; j < parts.length - 1; j++) {
      final directoryName = parts[j];
      currentDir.putIfAbsent(directoryName, () => <String, dynamic>{});
      currentDir = currentDir[directoryName] as Map<String, dynamic>;
    }

    final fileName = i.toString();
    currentDir.putIfAbsent(fileName, () => null);
    i++;
  }

  return directoryHierarchy;
}
