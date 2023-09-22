import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:simple_grid/simple_grid.dart';
import 'package:torrent_frontend/providers/transmission.dart';
import 'package:torrent_frontend/widgets/common/button.dart';
import 'package:torrent_frontend/widgets/smooth_graph/smooth_graph.dart';
import 'package:torrent_frontend/widgets/torrent/torrent.dart';

class TorrentBottomOverview extends HookConsumerWidget {
  const TorrentBottomOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transmission = ref.watch(transmissionProvider);
    transmission.getTorrents().then((value) => print(value));
    final theme = Theme.of(context);

    return Row(
      children: [
        Stack(
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
                        Icons.folder,
                        color: theme.colorScheme.onPrimary,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: TextButton(
                      child: Icon(
                        Icons.info,
                        color: theme.colorScheme.onSecondary,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
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
                    SizedBox(
                      width: double.infinity,
                      child: ResponsiveGridList(
                        verticalGridMargin: 10,
                        horizontalGridMargin: 10,
                        horizontalGridSpacing:
                            16, // Horizontal space between grid items
                        verticalGridSpacing:
                            16, // Vertical space between grid items
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
                          (index) => TorrentTile(
                            bytes: 12582912,
                            bytesToDownload: 12582912,
                            bytesDownloadSpeed: 524288,
                            bytesDownloaded: 1048576,
                            isFile: true,
                            timeLeft: Duration(seconds: 24),
                          ),
                        ), // The list of widgets in the list
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
