import 'package:flarrent/state/ordered_downloads.dart';
import 'package:flarrent/utils/ordered_downloads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OrderedDownloadsButton extends HookConsumerWidget {
  const OrderedDownloadsButton({required this.torrentIds, super.key});

  final List<int> torrentIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = useState(false);
    if (torrentIds.isEmpty) return const SizedBox.shrink();
    final ids = torrentIds.toSet().toList()..sort();
    final result = ref.watch(orderedDownloadsProvider);
    // Riverpod retains the last server value during refresh. Keep rendering it
    // instead of flashing back to an unknown/disabled icon on every poll.
    final snapshot = result.valueOrNull;
    final selection = snapshot?.selection(ids) ?? OrderedSelection.unknown;
    final canChange = !result.hasError &&
        (snapshot?.supported ?? false) &&
        selection != OrderedSelection.unknown;
    final enabled = selection == OrderedSelection.enabled;
    final String tooltip;
    if (busy.value) {
      tooltip = 'Updating ordered downloads...';
    } else if (result.hasError) {
      tooltip =
          'Could not read ordered downloads: ${result.error}. Click to retry.';
    } else if (snapshot?.supported == false) {
      tooltip = 'Ordered downloads require Transmission 4.1 or newer';
    } else if (selection == OrderedSelection.mixed) {
      tooltip =
          'Ordered downloads: mixed. Enable for all selected torrents';
    } else if (selection == OrderedSelection.unknown) {
      tooltip = snapshot == null
          ? 'Ordered downloads: waiting for server state'
          : 'Ordered downloads: selected torrent state unavailable';
    } else {
      tooltip =
          'Ordered downloads: ${enabled ? 'on. Disable' : 'off. Enable'} for selected torrents';
    }

    return IconButton(
      tooltip: tooltip,
      splashRadius: 20,
      color: enabled ? Colors.lightBlue : null,
      disabledColor: enabled ? Colors.lightBlue : null,
      icon: const Icon(Icons.format_list_numbered),
      onPressed: busy.value || (!canChange && !result.hasError)
          ? null
          : () async {
              if (result.hasError) {
                ref.invalidate(orderedDownloadsProvider);
                return;
              }
              busy.value = true;
              try {
                await ref
                    .read(orderedDownloadsClientProvider)
                    .set(ids, enabled: !enabled);
                if (context.mounted) ref.invalidate(orderedDownloadsProvider);
              } catch (error) {
                if (context.mounted) {
                  ref.invalidate(orderedDownloadsProvider);
                  await showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Could not update ordered downloads'),
                      content: Text('$error'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              } finally {
                if (context.mounted) busy.value = false;
              }
            },
    );
  }
}
