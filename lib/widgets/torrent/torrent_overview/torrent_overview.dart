import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/widgets/torrent/torrent_overview/overview_files.dart';
import 'package:torrent_frontend/widgets/torrent/torrent_overview/overview_info.dart';

class TorrentOverview extends HookConsumerWidget {
  const TorrentOverview({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pageController = usePageController();

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
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
                      duration: const Duration(milliseconds: 200),
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
                      duration: const Duration(milliseconds: 200),
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
              OverviewInfo(id: id),
              OverviewFiles(id: id),
            ],
          ),
        ),
      ],
    );
  }
}
