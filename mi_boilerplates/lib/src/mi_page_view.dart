// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide PageView;
import 'package:flutter/material.dart' as material show PageView;
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

/// カスタム[PageView]
///
/// * ページ位置[pageNotifier]を外部と共有。
/// * [PageController]を内蔵し隠蔽。
///   s.a. https://api.flutter.dev/flutter/widgets/PageController-class.html

class PageView extends StatefulWidget {
  final bool enabled;
  final int initialPage;
  final ValueNotifier<int> pageNotifier;
  // items/itemCount, itemBuilderは排他。
  // ラムダ式はconstにできないので、初期化子にできないため、この様である。
  final List<Widget>? items;
  final int? itemCount;
  final IndexedWidgetBuilder? itemBuilder;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool pageSnapping;
  final ValueChanged<int>? onPageChanged;
  final DragStartBehavior dragStartBehavior;
  final bool allowImplicitScrolling;
  final String? restorationId;
  final Clip clipBehavior;
  final ScrollBehavior? scrollBehavior;
  final bool padEnds;
  final double viewportFraction;
  final Duration? animationDuration;
  final Curve curve;

  const PageView({
    super.key,
    this.enabled = true,
    this.initialPage = 0,
    required this.pageNotifier,
    required this.items,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehavior,
    this.padEnds = true,
    this.viewportFraction = 1.0,
    this.animationDuration,
    this.curve = Curves.easeInOut,
  })  : assert(items != null),
        itemCount = null,
        itemBuilder = null;

  const PageView.builder({
    super.key,
    this.enabled = true,
    this.initialPage = 0,
    required this.pageNotifier,
    this.itemCount,
    required this.itemBuilder,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehavior,
    this.padEnds = true,
    this.viewportFraction = 1.0,
    this.animationDuration,
    this.curve = Curves.easeInOut,
  })  : assert(itemCount != null && itemBuilder != null),
        items = null;

  @override
  State<mi.PageView> createState() => _PageViewState();
}

class _PageViewState extends State<PageView> {
  // ignore: unused_field
  static final _logger = Logger((_PageViewState).toString());

  late PageController _pageController;
  late int _lastPage;

  void _pageChanged() async {
    final page = widget.pageNotifier.value;
    if (page == _lastPage - 1 || page == _lastPage + 1) {
      await _pageController.animateToPage(
        page,
        duration: widget.animationDuration ?? kTabScrollDuration,
        curve: widget.curve,
      );
    } else {
      _pageController.jumpToPage(page);
    }
    _lastPage = widget.pageNotifier.value;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialPage,
      viewportFraction: widget.viewportFraction,
    );
    _lastPage = widget.initialPage;
    widget.pageNotifier.addListener(_pageChanged);
  }

  @override
  void dispose() {
    widget.pageNotifier.removeListener(_pageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      oldWidget.pageNotifier.removeListener(_pageChanged);
      widget.pageNotifier.addListener(_pageChanged);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    assert((widget.items != null && widget.itemCount == null && widget.itemBuilder == null) ||
        (widget.items == null && widget.itemCount != null && widget.itemBuilder != null));

    return material.PageView.builder(
      controller: _pageController,
      itemCount: widget.itemCount ?? widget.items!.length,
      itemBuilder: widget.itemBuilder ?? (_, index) => widget.items![index],
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      physics: widget.enabled ? widget.physics : const NeverScrollableScrollPhysics(),
      pageSnapping: widget.pageSnapping,
      onPageChanged: (index) {
        //_logger.fine('onPageChanged $index ${_pageController.page} ${widget.pageNotifier.value}');
        widget.pageNotifier.value = index;
        widget.onPageChanged?.call(index);
      },
      dragStartBehavior: widget.dragStartBehavior,
      allowImplicitScrolling: widget.allowImplicitScrolling,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      scrollBehavior: widget.scrollBehavior,
      padEnds: widget.padEnds,
    );
  }
}

/// ページインジケータ
///
class PageIndicator extends StatelessWidget {
  static const Widget kDefaultSelectedIcon = Icon(Icons.circle, size: 12);
  static const Widget kDefaultUnselectedIcon = Icon(Icons.fiber_manual_record, size: 12);

  final int length;
  final int index;
  final ValueChanged<int>? onSelected;
  final Widget? selectedIcon;
  final Color? selectedIconColor;
  final Widget? unselectedIcon;
  final Color? unselectedIconColor;
  final double? spacing;
  final double? runSpacing;
  final String? tooltip;

  const PageIndicator({
    super.key,
    required this.length,
    required this.index,
    this.onSelected,
    this.selectedIcon,
    this.selectedIconColor,
    this.unselectedIcon,
    this.unselectedIconColor,
    this.spacing,
    this.runSpacing,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIcon_ = selectedIcon ?? kDefaultSelectedIcon;
    final unselectedIcon_ = unselectedIcon ?? kDefaultUnselectedIcon;
    final selectedIconColor_ = selectedIconColor ?? theme.foregroundColor;
    final unselectedIconColor_ = unselectedIconColor ?? theme.unselectedIconColor;

    return IconTheme.merge(
      data: IconThemeData(
        color: unselectedIconColor_,
      ),
      child: Tooltip(
        message: tooltip ?? 'Page ${index + 1}',
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: spacing ?? 2.0,
          runSpacing: runSpacing ?? 2.0,
          children: mi.iota(length).map(
            (i) {
              Widget widget = i == index
                  ? IconTheme.merge(
                      data: IconThemeData(
                        color: selectedIconColor_,
                      ),
                      child: selectedIcon_,
                    )
                  : unselectedIcon_;
              if (onSelected != null) {
                widget = InkWell(
                  onTap: () => onSelected?.call(i),
                  child: widget,
                );
              }
              return widget;
            },
          ).toList(),
        ),
      ),
    );
  }
}
