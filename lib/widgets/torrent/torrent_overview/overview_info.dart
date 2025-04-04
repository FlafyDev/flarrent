import 'package:collection/collection.dart';
import 'package:flarrent/state/torrents.dart';
import 'package:flarrent/utils/capitalize_string.dart';
import 'package:flarrent/utils/units.dart';
import 'package:flarrent/widgets/common/responsive_horizontal_grid.dart';
import 'package:flarrent/widgets/smooth_graph/smooth_graph.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OverviewInfo extends HookConsumerWidget {
  const OverviewInfo({
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
        final width = (maxWidth / 3).clamp(300, 500).toDouble();
        return Row(
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              width: width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  2,
                  (i) {
                    return _TorrentGraph(
                      id: id,
                      theme: theme,
                      isDownload: i == 0,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final data = ref.watch(
                    torrentsProvider.select(
                      (v) => v.torrents.firstWhereOrNull(
                        (element) => element.id == id,
                      ),
                    ),
                  );
                  if (data == null) return Container();

                  return Center(
                    child: ResponsiveHorizontalGrid(
                      maxWidgetWidth: 500,
                      minWidgetWidth: 250,
                      widgetHeight: 30,
                      children: [
                        _TorrentInfoTile('State', capitalizeString(data.state.name)),
                        _TorrentInfoTile('Size', stringBytesWithUnits(data.sizeBytes)),
                        if (data.sizeBytes != data.sizeToDownloadBytes)
                          _TorrentInfoTile('Download size', stringBytesWithUnits(data.sizeToDownloadBytes)),
                        _TorrentInfoTile('Downloaded', stringBytesWithUnits(data.downloadedBytes)),
                        if (data.addedOn != null) _TorrentInfoTile('Added on', dateTimeToString(data.addedOn!)),
                        if (data.completedOn != null)
                          _TorrentInfoTile('Completed on', dateTimeToString(data.completedOn!)),
                        if (data.lastActivity != null)
                          _TorrentInfoTile('Last activity', dateTimeToString(data.lastActivity!)),
                        if (data.timeDownloading != null)
                          _TorrentInfoTile('Time downloading', formatDuration(data.timeDownloading!)),
                        if (data.timeSeeding != null)
                          _TorrentInfoTile('Time seeding', formatDuration(data.timeSeeding!)),
                        _TorrentInfoTile('Ratio', data.ratio.toStringAsFixed(2)),

                        if (data.downloadedEverBytes != null)
                          _TorrentInfoTile('Downloaded ever', stringBytesWithUnits(data.downloadedEverBytes!)),
                        if (data.uploadedEverBytes != null)
                          _TorrentInfoTile('Uploaded ever', stringBytesWithUnits(data.uploadedEverBytes!)),
                        if (data.location != null) _TorrentInfoTile('location', data.location!),
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

class _TorrentGraph extends HookConsumerWidget {
  const _TorrentGraph({
    required this.id,
    required this.theme,
    required this.isDownload,
    // ignore: unused_element
    super.key,
  });

  final int id;
  final ThemeData theme;
  final bool isDownload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<int> read() => ref.read(
          torrentsProvider.select(
            (v) => isDownload ? v.downloadSpeeds[id]! : v.uploadSpeeds[id]!,
          ),
        );

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SmoothChart(
                tint: isDownload ? Colors.lightBlue : Colors.purple,
                key: ValueKey(id),
                getInitialPointsY: (i) {
                  return read()[i].toDouble() / 1024 / 1024;
                },
                getNextPointY: () {
                  return read().last.toDouble() / 1024 / 1024;
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: Consumer(
                builder: (context, ref, child) {
                  final bytesPerSecond = ref.watch(
                    torrentsProvider.select(
                      (v) {
                        final speeds = isDownload ? v.downloadSpeeds[id] : v.uploadSpeeds[id];
                        if (speeds == null) return 0;
                        return speeds[speeds.length - 3];
                      },
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
                            isDownload ? Icons.arrow_downward : Icons.arrow_upward,
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
  }
}

class _TorrentInfoTile extends StatelessWidget {
  const _TorrentInfoTile(
    this.title,
    this.value, {
    // ignore: unused_element
    super.key,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
