import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:responsive_grid_list/src/responsive_grid_list/list_view_builder_options.dart';
import 'package:quiver/iterables.dart';
import 'package:responsive_grid_list/src/extensions/list_extensions.dart';
import 'dart:math' as math;

///
/// An [AbstractResponsiveGridList] returning the grid inside a
/// [ListView.builder()]
///
class ResponsiveGridList2 extends AbstractResponsiveGridList2 {
  /// Constructor of [ResponsiveGridList].
  const ResponsiveGridList2({
    required super.minItemWidth,
    required super.children,
    super.key,
    super.minItemsPerRow = 1,
    super.maxItemsPerRow,
    super.horizontalGridSpacing = 16,
    super.verticalGridSpacing = 16,
    super.horizontalGridMargin,
    super.verticalGridMargin,
    super.rowMainAxisAlignment = MainAxisAlignment.start,
    @Deprecated('Use listViewBuilderOptions instead') this.shrinkWrap = false,
    this.listViewBuilderOptions,
    // coverage:ignore-start
  });

  /// shrinkWrap property of [ListView.builder].
  @Deprecated('Use listViewBuilderOptions.shrinkWrap instead')
  final bool shrinkWrap; // coverage:ignore-end

  ///
  /// Object that can be set if any of the [ListView.builder] options
  /// need to be overridden. The [ResponsiveGridList] defines the builder
  /// and item count. All other options are optional and can be set through
  /// this object.
  ///
  final ListViewBuilderOptions? listViewBuilderOptions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Get the grid list items
        final items = getResponsiveGridListItems(constraints.maxHeight);

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return items[index];
          },
          scrollDirection:
              listViewBuilderOptions?.scrollDirection ?? Axis.horizontal,
          reverse: listViewBuilderOptions?.reverse ?? false,
          controller: listViewBuilderOptions?.controller,
          primary: listViewBuilderOptions?.primary,
          physics: listViewBuilderOptions?.physics,
          // TODO(hauketoenjes): Remove this when the shrinkWrap property
          // is removed
          // ignore: deprecated_member_use_from_same_package
          shrinkWrap: listViewBuilderOptions?.shrinkWrap ?? shrinkWrap,
          padding: listViewBuilderOptions?.padding,
          itemExtent: listViewBuilderOptions?.itemExtent,
          prototypeItem: listViewBuilderOptions?.prototypeItem,
          findChildIndexCallback:
              listViewBuilderOptions?.findChildIndexCallback,
          addAutomaticKeepAlives:
              listViewBuilderOptions?.addAutomaticKeepAlives ?? true,
          addRepaintBoundaries:
              listViewBuilderOptions?.addRepaintBoundaries ?? true,
          addSemanticIndexes:
              listViewBuilderOptions?.addSemanticIndexes ?? true,
          cacheExtent: listViewBuilderOptions?.cacheExtent,
          semanticChildCount: listViewBuilderOptions?.semanticChildCount,
          dragStartBehavior: listViewBuilderOptions?.dragStartBehavior ??
              DragStartBehavior.start,
          keyboardDismissBehavior:
              listViewBuilderOptions?.keyboardDismissBehavior ??
                  ScrollViewKeyboardDismissBehavior.manual,
          restorationId: listViewBuilderOptions?.restorationId,
          clipBehavior: listViewBuilderOptions?.clipBehavior ?? Clip.hardEdge,
        );
      },
    );
  }
}

///
/// Abstract class providing the method [getResponsiveGridListItems] to
/// calculate the most fitting items in row with [horizontalGridSpacing],
/// [verticalGridSpacing] and [minItemWidth].
///
/// The maximum number of items per row can be constrained with
/// [maxItemsPerRow].
///
abstract class AbstractResponsiveGridList2 extends StatelessWidget {
  /// Constructor of [AbstractResponsiveGridList].
  const AbstractResponsiveGridList2({
    required this.minItemWidth,
    required this.minItemsPerRow,
    required this.horizontalGridSpacing,
    required this.verticalGridSpacing,
    required this.rowMainAxisAlignment,
    required this.children,
    this.maxItemsPerRow,
    this.horizontalGridMargin,
    this.verticalGridMargin,
    super.key,
  })  : assert(
          // coverage:ignore-start
          minItemWidth > 0,
          'minItemWidth has to be > 0. It instead was set to $minItemWidth',
        ),
        assert(
          minItemsPerRow > 0,
          'minItemsPerRow has to be > 0. It instead was set to $minItemsPerRow',
        ),
        assert(
          maxItemsPerRow == null || maxItemsPerRow >= minItemsPerRow,
          'maxItemsPerRow can only be null or >= minItemsPerRow '
          '($minItemsPerRow). It instead was set to $maxItemsPerRow',
        );

  ///
  /// Children of the resulting grid list.
  ///
  final List<Widget> children;

  ///
  /// The minimum item width of each individual item in the list. Can be smaller
  /// if the viewport constraints are smaller.
  ///
  final double minItemWidth;

  ///
  /// Minimum items to show per row. If this is set to a value higher than 1,
  /// this takes precedence over [minItemWidth] and allows items to be smaller
  /// than [minItemWidth] to fit at least [minItemsPerRow] items.
  ///
  final int minItemsPerRow;

  ///
  /// Maximum items to show per row. By default the package shows all items that
  /// fit into the available space according to [minItemWidth].
  ///
  /// Note that this should only be used when limiting items on large screens
  /// since it will stretch [maxItemsPerRow] items across the whole width
  /// when maximum is reached. This can result in a large difference to
  /// [minItemWidth].
  ///
  final int? maxItemsPerRow;

  ///
  /// The horizontal spacing between the items in the grid.
  ///
  final double horizontalGridSpacing;

  ///
  /// The vertical spacing between the items in the grid.
  ///
  final double verticalGridSpacing;

  ///
  /// The horizontal spacing around the grid.
  ///
  final double? horizontalGridMargin;

  ///
  /// The vertical spacing around the grid.
  ///
  final double? verticalGridMargin;

  ///
  /// [MainAxisAlignment] of each row in the grid list.
  ///
  final MainAxisAlignment rowMainAxisAlignment; // coverage:ignore-end

  ///
  /// Method to generate a list of [ResponsiveGridRow]'s with spacing in between
  /// them.
  ///
  /// [maxWidth] is the maximum width of the current layout.
  ///
  List<Widget> getResponsiveGridListItems(double maxWidth) {
    // Start with the minimum allowed number of items per row.
    var itemsPerRow = minItemsPerRow;

    // Calculate the current width according to the items per row
    var currentWidth =
        itemsPerRow * minItemWidth + (itemsPerRow - 1) * horizontalGridSpacing;

    // Add outer margin (vertical) if set
    if (horizontalGridMargin != null) {
      currentWidth += 2 * horizontalGridMargin!;
    }

    // While another pair of spacing + minItemWidth fits the row, add it to
    // the variables. Only add items while maxItemsPerRow is not reached.
    while (currentWidth < maxWidth &&
        (maxItemsPerRow == null || itemsPerRow < maxItemsPerRow!)) {
      if (currentWidth + (minItemWidth + horizontalGridSpacing) <= maxWidth) {
        // If another spacing + item fits in the row, add one item to the row
        // and update the currentWidth
        currentWidth += minItemWidth + horizontalGridSpacing;
        itemsPerRow++;
      } else {
        // If no other item + spacer fits into the row, break
        break;
      }
    }

    print(currentWidth);
    // Calculate the spacers per row (they are only in between the items, not
    // at the edges)
    final spacePerRow = itemsPerRow - 1;

    // Calculate the itemWidth that results from the maxWidth and number of
    // spacers and outer margin (horizontal)
    final itemWidth = (maxWidth -
            (spacePerRow * horizontalGridSpacing) -
            (2 * (horizontalGridMargin ?? 0))) /
        itemsPerRow;

    // Partition the items into groups of itemsPerRow length and map them
    // to ResponsiveGridRow's
    final items = partition(children, itemsPerRow)
        .map<Widget>(
          (e) => ResponsiveGridRow(
            rowItems: e,
            spacing: horizontalGridSpacing,
            horizontalGridMargin: horizontalGridMargin,
            itemWidth: itemWidth,
          ),
        )
        .toList();

    // Join the rows width spacing in between them (vertical)
    final responsiveGridListItems =
        items.genericJoin(SizedBox(width: verticalGridSpacing));

    // Add outer margin (vertical) if set
    if (verticalGridMargin != null) {
      return [
        SizedBox(width: verticalGridMargin),
        ...responsiveGridListItems,
        // ...items
        SizedBox(width: verticalGridMargin),
      ];
    }

    return items;
  }
}

///
/// Creates a row of [rowItems] length size with a width of [itemWidth] and
/// [spacing] in between them.
///
/// The default [MainAxisAlignment] of the returned row is
/// [MainAxisAlignment.start]. It can be modified through the
/// [rowMainAxisAlignment] parameter.
///
class ResponsiveGridRow extends StatelessWidget {
  /// Constructs a new [ResponsiveGridRow].
  const ResponsiveGridRow({
    required this.rowItems,
    required this.spacing,
    required this.itemWidth,
    super.key,
    this.horizontalGridMargin,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
  });

  ///
  /// The items in the row.
  ///
  final List<Widget> rowItems;

  ///
  /// The spacing between the items in the row.
  ///
  final double spacing;

  ///
  /// The width of the items in the row.
  ///
  final double itemWidth;

  /// horizontal Margin around the grid.
  final double? horizontalGridMargin;

  ///
  /// The MainAxisAlignment of the row.
  ///
  /// Default's to [MainAxisAlignment.start].
  ///
  final MainAxisAlignment rowMainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    // Wrap the items with a SizedBox of width [itemWidth]
    final sizedRowItems =
        rowItems.map((e) => SizedBox(height: itemWidth, child: e)).toList();

    // Join SizedBoxes in between the items with a fixed width of [spacing]
    var spacedRowItems = sizedRowItems.genericJoin(SizedBox(height: spacing));

    // Add outer margin, if not null
    if (horizontalGridMargin != null) {
      spacedRowItems = [
        SizedBox(height: horizontalGridMargin),
        ...spacedRowItems,
        SizedBox(height: horizontalGridMargin),
      ];
    }

    return IntrinsicWidth(
      child: Column(
        mainAxisAlignment: rowMainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: spacedRowItems,
      ),
    );
  }
}

class ResponsiveHorizontalGrid extends StatelessWidget {
  const ResponsiveHorizontalGrid({
    super.key,
    required this.children,
    required this.minWidgetWidth,
    required this.widgetHeight,
  });

  final List<Widget> children;
  final double minWidgetWidth;
  final double widgetHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraints) {
        final sectionedChildren =
            partition(children, (contraints.maxHeight / widgetHeight).floor())
                .toList();

        final sectionsCount = math.min(
          (contraints.maxWidth / minWidgetWidth).floor(),
          sectionedChildren.length,
        );

        final sectionWidth = contraints.maxWidth / sectionsCount;

        final abandonedChildrenPre = sectionedChildren.sublist(sectionsCount);
        var abandonedChildren = <Widget>[];

        if (abandonedChildrenPre.isNotEmpty) {
          abandonedChildren = abandonedChildrenPre
              .reduce((value, element) => value + element)
              .toList();
        }

        return SizedBox(
          width: contraints.maxWidth,
          child: Row(
            children: List.generate(
              sectionsCount,
              (i) {
                return SizedBox(
                  width: sectionWidth,
                  child: ListView(
                    // mainAxisAlignment: MainAxisAlignment.start,
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
                  ),
                );
              },
            ),
          ),
          // child: ListView.builder(
          //   scrollDirection: Axis.horizontal,
          //   itemCount: sectionsCount,
          //   itemBuilder: (context, index) {
          //     return Container(
          //       width: contraints.maxWidth,
          //       child: Column(
          //         children: children,
          //       ),
          //     );
          //   },
          // ),
        );
      },
    );
  }
}
