import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:simple_grid/simple_grid.dart';
import 'package:torrent_frontend/models/torrent.dart';
import 'package:torrent_frontend/providers/transmission.dart';
import 'package:torrent_frontend/state/torrents.dart';
import 'package:torrent_frontend/utils/units.dart';
import 'package:torrent_frontend/widgets/common/button.dart';
import 'package:torrent_frontend/widgets/smooth_graph/smooth_graph.dart';
import 'package:torrent_frontend/widgets/torrent/torrent.dart';

import '../test.dart';

class TorrentBottomOverview extends HookConsumerWidget {
  const TorrentBottomOverview({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transmission = ref.watch(transmissionProvider);
    transmission.getTorrents().then((value) => print(value));
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
          Text(value),
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

    return Row(
      children: [
        SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final downloadBytesPerSecond = ref.watch(
                    torrentsProvider.select(
                      (v) => v
                          .firstWhere(
                            (element) => element.id == id,
                          )
                          .downloadBytesPerSecond,
                    ),
                  );

                  final unit = detectUnit(downloadBytesPerSecond);

                  return SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        const Expanded(child: SmoothChart()),
                        const SizedBox(width: 12),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: fromBytesToUnit(
                                  downloadBytesPerSecond,
                                  unit: unit,
                                ).toStringAsFixed(2),
                                style: const TextStyle(fontSize: 24),
                              ),

                              /// Mb/s
                              TextSpan(
                                text: ' ${unit.name}/s',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                              const WidgetSpan(
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 100,
                child: SmoothChart(),
              ),
            ],
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            final data = ref.watch(
              torrentsProvider.select(
                (v) => v.firstWhere(
                  (element) => element.id == id,
                ),
              ),
            );

            return Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: ResponsiveHorizontalGrid(
                    minWidgetWidth: 250,
                    widgetHeight: 30,
                    children: [
                      _TorrentInfoTile(
                          'Size', printBytesWithUnits(data.sizeBytes)),
                      _TorrentInfoTile(
                          'Added on', dateTimeToString(data.addedOn)),
                      if (data.completedOn != null)
                        _TorrentInfoTile('Completed on',
                            dateTimeToString(data.completedOn!)),
                      _TorrentInfoTile('Ratio', data.ratio.toStringAsFixed(2)),
                      _TorrentInfoTile(
                          'Uploaded', printBytesWithUnits(data.uploadedBytes)),
                      _TorrentInfoTile('Comment', ''),
                      _TorrentInfoTile('Origin', data.origin),
                      _TorrentInfoTile('Limit', ''),
                      _TorrentInfoTile('location', data.location),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
