import 'package:flarrent/widgets/torrent/torrent_overview/overview_files.dart';
import 'package:flarrent/widgets/torrent/torrent_overview/overview_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TorrentOverview extends HookConsumerWidget {
  const TorrentOverview({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pageController = usePageController();
    final currentPage = useValueNotifier(0);
    final icons = [
      Icons.info,
      Icons.folder,
    ];

    useEffect(
      () {
        void callback() {
          currentPage.value = pageController.page?.round() ?? 0;
        }

        pageController.addListener(callback);
        return () => pageController.removeListener(callback);
      },
      [pageController],
    );

    // final aa = ref.watch(transmissionMainTorrentsProvider.select((s) => s.isReloading ));

    // The idea is not update the overview with a new torrent id if data is not loaded yet.
    // final exists = ref.watch(torrentsProvider.select((s) => s.torrents.any((t) => t.id == id)));
    // if (!exists) {
    //   if (prevId == id || prevId == null) {
    //     return const SizedBox();
    //   } else {
    //     shownId = prevId;
    //   }
    // }

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: icons
                .asMap()
                .entries
                .map(
                  (e) => SizedBox(
                    width: 40,
                    height: 40,
                    child: TextButton(
                      child: ValueListenableBuilder(
                        valueListenable: currentPage,
                        builder: (context, val, child) {
                          return Icon(
                            e.value,
                            color: val == e.key ? theme.colorScheme.onSecondary : Colors.white,
                          );
                        },
                      ),
                      onPressed: () {
                        pageController.animateToPage(
                          e.key,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutExpo,
                        );
                      },
                    ),
                  ),
                )
                .toList(),
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
