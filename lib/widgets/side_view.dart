// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/models/filters.dart';
import 'package:torrent_frontend/models/torrent.dart';
import 'package:torrent_frontend/state/filters.dart';
import 'package:torrent_frontend/utils/capitalize_string.dart';

class SideView extends HookConsumerWidget {
  const SideView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        _Border(
          title: 'Connection',
          child: SizedBox(
            width: double.infinity,
            child: Text(
              'Connection: Transmission 4.0.4',
            ),
          ),
        ),
        SizedBox(height: 20),
        _Border(
          title: 'Filter & Sort',
          child: Column(
            children: [
              HookConsumer(
                builder: (context, ref, child) {
                  final controller = useTextEditingController(text: ref.read(filtersProvider.select((s) => s.query)));
                  return TextField(
                    controller: controller,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Query',
                    ),
                    onChanged: (value) {
                      ref.read(filtersProvider.notifier).update((s) => s.copyWith(query: value));
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              Consumer(
                builder: (context, ref, child) {
                  final states = ref.watch(filtersProvider.select((s) => s.states));
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: TorrentState.values.map((e) {
                      final selected = states.contains(e);
                      return TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          backgroundColor: Colors.lightBlue.withOpacity(selected ? 0.5 : 0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        onPressed: () {
                          ref.read(filtersProvider.notifier).update((s) {
                            if (selected) {
                              return s.copyWith(states: s.states.where((state) => state != e).toList());
                            } else {
                              return s.copyWith(states: {...s.states, e}.toList());
                            }
                          });
                        },
                        child: Text(capitalizeString(e.name)),
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      return DropdownMenu(
                        initialSelection: ref.read(filtersProvider.select((s) => s.sortBy)), // Not sure how correct it is to do this.
                        onSelected: (value) {
                          if (value == null) return;
                          ref.read(filtersProvider.notifier).update((s) => s.copyWith(sortBy: value));
                        },
                        dropdownMenuEntries: [
                          DropdownMenuEntry(label: 'Name', value: SortBy.name),
                          DropdownMenuEntry(label: 'Download speed', value: SortBy.downloadSpeed),
                          DropdownMenuEntry(label: 'Upload speed', value: SortBy.uploadSpeed),
                          DropdownMenuEntry(label: 'Size', value: SortBy.size),
                          DropdownMenuEntry(label: 'Added on', value: SortBy.addedOn),
                          DropdownMenuEntry(label: 'Completed on', value: SortBy.completedOn),
                        ],
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final ascending = ref.watch(filtersProvider.select((s) => s.ascending));
                      return AnimatedRotation(
                        turns: ascending ? 0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutExpo,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          splashRadius: 20,
                          onPressed: () {
                            ref.read(filtersProvider.notifier).update((s) => s.copyWith(ascending: !s.ascending));
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        TextButton(
          onPressed: () {},
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Icon(Icons.add),
                SizedBox(width: 10),
                Text('Add torrent file'),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Icon(Icons.add),
                SizedBox(width: 10),
                Text('Add torrent magnet'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InvertedClipper extends CustomClipper<Path> {
  const _InvertedClipper(this.removedRect);

  final Rect removedRect;

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(-1, -1, size.width + 2, size.height + 2))
      ..addRect(removedRect)
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class _Border extends HookConsumerWidget {
  const _Border({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final removedRect = useRef(Rect.fromLTWH(5, 0, _textSize(title).width, 12));

    useValueChanged<String, Object>(title, (_, __) {
      removedRect.value = Rect.fromLTWH(5, 0, _textSize(title).width, 12);
      return;
    });

    return Stack(
      children: [
        ClipPath(
          clipper: _InvertedClipper(removedRect.value),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: DottedBorder(
              borderType: BorderType.RRect,
              dashPattern: [5, 3],
              radius: Radius.circular(12),
              padding: EdgeInsets.all(10),
              color: Colors.grey.shade700.withOpacity(0.3),
              strokeWidth: 2,
              child: child,
            ),
          ),
        ),
        Positioned(
          left: 10,
          child: Text(title, style: TextStyle(color: Colors.grey.shade500)),
        ),
      ],
    );
  }
}

Size _textSize(String text, [TextStyle? style]) {
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();
  return textPainter.size;
}
