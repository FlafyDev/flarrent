import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:torrent_frontend/models/torrent.dart';
import 'package:torrent_frontend/state/torrents.dart';
import 'package:torrent_frontend/utils/units.dart';
import 'package:torrent_frontend/widgets/common/button.dart';
import 'package:torrent_frontend/widgets/common/responsive_horizontal_grid.dart';
import 'package:torrent_frontend/widgets/smooth_graph/smooth_graph.dart';
import 'package:torrent_frontend/widgets/torrent/torrent.dart';
import 'dart:math' as math;

class TorrentBottomOverview extends HookConsumerWidget {
  const TorrentBottomOverview({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final transmission = ref.watch(transmissionProvider);
    final theme = Theme.of(context);
    final pageController = usePageController();

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: TextButton(
                  child: Icon(
                    Icons.info,
                    color: theme.colorScheme.onSecondary,
                  ),
                  onPressed: () {
                    pageController.animateToPage(
                      0,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeOutExpo,
                    );
                  },
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: TextButton(
                  child: Icon(
                    Icons.folder,
                    color: theme.colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    pageController.animateToPage(
                      1,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeOutExpo,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            children: [
              _TorrentInfo(id: id),
              _TorrentFiles(id: id),
            ],
          ),
        ),
      ],
    );
  }
}

class _TorrentFiles extends HookConsumerWidget {
  const _TorrentFiles({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: EdgeInsets.all(8).copyWith(left: 0),
              child: Row(
                children: [
                  InkButton(
                    padding: EdgeInsets.all(6),
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                    onPressed: () {},
                    child: Text("ROOT"),
                  ),
                  SizedBox(width: 6),
                  InkButton(
                    padding: EdgeInsets.all(6),
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                    onPressed: () {},
                    child: Text("Season 1"),
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(right: 8),
                width: double.infinity,
                child: ResponsiveGridList(
                  verticalGridMargin: 0,
                  horizontalGridMargin: 0,
                  horizontalGridSpacing:
                      4, // Horizontal space between grid items
                  verticalGridSpacing: 4, // Vertical space between grid items
                  minItemWidth:
                      230, // The minimum item width (can be smaller, if the layout constraints are smaller)
                  minItemsPerRow:
                      1, // The minimum items to show in a single row. Takes precedence over minItemWidth
                  // maxItemsPerRow:
                  //     5, // The maximum items to show in a single row. Can be useful on large screens
                  listViewBuilderOptions:
                      ListViewBuilderOptions(), // Options that are getting passed to the ListView.builder() function
                  children: List.generate(
                    6,
                    (index) => const TorrentFileTile(
                      fileData: TorrentFileData(
                        name: 'test',
                        wanted: true,
                        downloadedBytes: 0,
                        sizeBytes: 920020000,
                        priority: TorrentPriority.low,
                      ),
                    ),
                  ), // The list of widgets in the list
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TorrentInfoTile extends StatelessWidget {
  const _TorrentInfoTile(
    this.title,
    this.value, {
    super.key,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          SizedBox(
            width: 10,
          ),
          Flexible(
              child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          )),
        ],
      ),
    );
  }
}

class _TorrentInfo extends HookConsumerWidget {
  const _TorrentInfo({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, contraints) {
      final maxWidth = contraints.maxWidth;
        return Row(
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              width: (maxWidth / 3).clamp(300, 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  2,
                  (i) {
                    final provider = i == 0
                        ? torrentDownloadSpeedProvider(id)
                        : torrentUploadSpeedProvider(id);
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SmoothChart(
                                tint: i == 0 ? Colors.lightBlue : Colors.purple,
                                getInitialPointsY: (i) {
                                  return ref
                                          .read(
                                            provider.notifier,
                                          )
                                          .state[i]
                                          .toDouble() /
                                      1024 /
                                      1024;
                                },
                                getNextPointY: () {
                                  return ref
                                          .read(
                                            provider.notifier,
                                          )
                                          .state
                                          .last
                                          .toDouble() /
                                      1024 /
                                      1024;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 100,
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final bytesPerSecond = ref.watch(
                                    torrentsProvider.select(
                                      (v) => i == 0
                                          ? v
                                              .firstWhere(
                                                (element) => element.id == id,
                                              )
                                              .downloadBytesPerSecond
                                          : v
                                              .firstWhere(
                                                (element) => element.id == id,
                                              )
                                              .uploadBytesPerSecond,
                                    ),
                                  );

                                  final unit = detectUnit(bytesPerSecond);

                                  return RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: fromBytesToUnit(
                                            bytesPerSecond,
                                            unit: unit,
                                          ),
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        TextSpan(
                                          text: ' ${unit.name}/s',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Icon(
                                            i == 0
                                                ? Icons.arrow_downward
                                                : Icons.arrow_upward,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  // const SizedBox(
                  //   height: 100,
                  //   child: SmoothChart(),
                  // ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Consumer(
                builder: (context, ref, child) {
                  final data = ref.watch(
                    torrentsProvider.select(
                      (v) => v.firstWhere(
                        (element) => element.id == id,
                      ),
                    ),
                  );

                  return Center(
                    child: ResponsiveHorizontalGrid(
                      maxWidgetWidth: 500,
                      minWidgetWidth: 250,
                      widgetHeight: 30,
                      children: [
                        _TorrentInfoTile(
                            'Size', stringBytesWithUnits(data.sizeBytes)),
                        _TorrentInfoTile(
                            'Added on', dateTimeToString(data.addedOn)),
                        if (data.completedOn != null)
                          _TorrentInfoTile(
                              'Completed on', dateTimeToString(data.completedOn!)),
                        _TorrentInfoTile('Ratio', data.ratio.toStringAsFixed(2)),
                        _TorrentInfoTile(
                            'Uploaded', stringBytesWithUnits(data.uploadedBytes)),
                        _TorrentInfoTile('Comment', ''),
                        _TorrentInfoTile('Origin', data.origin),
                        _TorrentInfoTile('Limit', ''),
                        _TorrentInfoTile('location', data.location),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
