// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// カスタム[PageView]
///
/// * ページ位置[pageNotifier]を外部と共有。
/// * [PageController]を内蔵し隠蔽。
///   s.a. https://api.flutter.dev/flutter/widgets/PageController-class.html
///
class MiPageView extends StatefulWidget {
  final int initialPage;
  final ValueNotifier<int> pageNotifier;
  final int? itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int>? onPageChanged;
  final Duration duration;
  final Curve curve;

  const MiPageView({
    super.key,
    this.initialPage = 0,
    required this.pageNotifier,
    this.itemCount,
    required this.itemBuilder,
    this.onPageChanged,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

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
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
    );
  }
}
