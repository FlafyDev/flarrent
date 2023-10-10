import 'dart:math' as math;

import 'package:flarrent/widgets/common/smooth_scrolling.dart';
import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart' as quiver;

class ResponsiveHorizontalGrid extends StatelessWidget {
  const ResponsiveHorizontalGrid({
    super.key,
    required this.children,
    required this.minWidgetWidth,
    required this.maxWidgetWidth,
    required this.widgetHeight,
  });

  final List<Widget> children;
  final double minWidgetWidth;
  final double widgetHeight;
  final double maxWidgetWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraints) {
        final sectionedChildren = quiver
            .partition(children, (contraints.maxHeight / widgetHeight).floor())
            .toList();

        final sectionsCount = math.min(
          (contraints.maxWidth / minWidgetWidth).floor(),
          sectionedChildren.length,
        );
        
        final width = math.min(
          contraints.maxWidth,
          maxWidgetWidth * sectionsCount,
        );


        final sectionWidth = width / sectionsCount;

        final abandonedChildrenPre = sectionedChildren.sublist(sectionsCount);
        var abandonedChildren = <Widget>[];

        if (abandonedChildrenPre.isNotEmpty) {
          abandonedChildren = abandonedChildrenPre
              .reduce((value, element) => value + element)
              .toList();
        }

        return SizedBox(
          width: width,
          child: Row(
            children: List.generate(
              sectionsCount,
              (i) {
                return SizedBox(
                  width: sectionWidth,
                  child: SmoothScrolling(
                    multiplier: 1,
                    builder: (context, scrollController, physics) {
                      return ListView(
                        controller: scrollController,
                        physics: physics,
                        children: i < sectionedChildren.length
                            ? (sectionedChildren[i] +
                                    (i == 0 ? abandonedChildren : <Widget>[]))
                                .map<Widget>(
                                  (child) => SizedBox(
                                    width: sectionWidth,
                                    height: widgetHeight,
                                    child: child,
                                  ),
                                )
                                .toList()
                            : [],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
