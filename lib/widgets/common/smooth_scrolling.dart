import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';

class SmoothScrolling extends HookWidget {
  const SmoothScrolling({
    super.key,
    required this.builder,
    this.multiplier = 2.5,
  });

  final Widget Function(BuildContext context, ScrollController scrollController, ScrollPhysics physics) builder;
  final double multiplier;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    return ImprovedScrolling(
      scrollController: scrollController,
      enableCustomMouseWheelScrolling: true,
      customMouseWheelScrollConfig: CustomMouseWheelScrollConfig(
        scrollDuration: const Duration(milliseconds: 300),
        scrollAmountMultiplier: multiplier,
      ),
      child: Builder(
        builder: (context) {
          return builder(context, scrollController, const NeverScrollableScrollPhysics());
        },
      ),
    );
  }
}
