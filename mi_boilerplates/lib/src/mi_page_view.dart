// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// カスタム[PageView]
///
/// * ページ位置[pageNotifier]を外部と共有。
/// * [PageController]を内蔵し隠蔽。
///   s.a. https://api.flutter.dev/flutter/widgets/PageController-class.html
///
class MiPageView extends StatefulWidget {
  static const kDuration = Duration(milliseconds: 300);

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
  final Duration duration;
  final Curve curve;

  const MiPageView({
    super.key,
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
    this.duration = kDuration,
    this.curve = Curves.easeInOut,
  })  : assert(items != null),
        itemCount = null,
        itemBuilder = null;

  const MiPageView.builder({
    super.key,
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
    this.duration = kDuration,
    this.curve = Curves.easeInOut,
  })  : assert(itemCount != null && itemBuilder != null),
        items = null;

  @override
  State<MiPageView> createState() => _MiPageViewState();
}

class _MiPageViewState extends State<MiPageView> {
  // ignore: unused_field
  static final _logger = Logger((_MiPageViewState).toString());

  late PageController _pageController;

  void _pageChanged() async {
    await _pageController.animateToPage(
      widget.pageNotifier.value,
      duration: widget.duration,
      curve: widget.curve,
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialPage,
      viewportFraction: widget.viewportFraction,
    );
    widget.pageNotifier.addListener(_pageChanged);
  }

  @override
  void dispose() {
    widget.pageNotifier.removeListener(_pageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MiPageView oldWidget) {
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

    return PageView.builder(
      controller: _pageController,
      itemCount: widget.itemCount ?? widget.items!.length,
      itemBuilder: widget.itemBuilder ?? (_, index) => widget.items![index],
    );
  }
}
