// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart' hide ReorderableListView;
import 'package:flutter/material.dart' as material show ReorderableListView;
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

/// リストを外部と共有する[ReorderableListView]。
///
/// こちらのサンプル
/// https://api.flutter.dev/flutter/material/ReorderableListView-class.html
/// における_itemsを[ValueNotifier]として外部と共有することにより、
/// * 内部の順序変更を外部に伝達。
/// * 外部からの順序変更に応じてリビルド。
/// ができるようにした。
///
/// [T] リスト要素の型
/// [enabled]
/// [orderNotifier] リストを保持する[ValueNotifier]。
/// [itemBuilder] リストのウィジェットを生成するメソッド。それぞれユニークな[key]を与える必要がある。

class ReorderableListView<T> extends StatefulWidget {
  final bool enabled;
  final ScrollController? scrollController;
  final ValueNotifier<List<T>> orderNotifier;
  final List<Widget>? children;
  final IndexedWidgetBuilder? itemBuilder;
  final ValueChanged<ScrollController>? onScroll;
  final Color? dragHandleColor;
  // TODO: 必要に応じて他のプロパティも

  const ReorderableListView({
    super.key,
    this.enabled = true,
    this.scrollController,
    required this.orderNotifier,
    required this.children,
    this.onScroll,
    this.dragHandleColor,
  })  : assert(children != null),
        itemBuilder = null;

  const ReorderableListView.builder({
    super.key,
    this.enabled = true,
    this.scrollController,
    required this.orderNotifier,
    required this.itemBuilder,
    this.onScroll,
    this.dragHandleColor,
  })  : assert(itemBuilder != null),
        children = null;

  @override
  State<ReorderableListView> createState() => _ReorderableListViewState();
}

class _ReorderableListViewState<T> extends State<ReorderableListView<T>> {
  static final _logger = Logger((_ReorderableListViewState).toString());

  void _valueChanged() {
    setState(() {});
  }

  void _scrolled() {
    _logger.fine('scroll ${widget.scrollController?.offset}');
    widget.onScroll?.call(widget.scrollController!);
  }

  @override
  void initState() {
    super.initState();
    widget.orderNotifier.addListener(_valueChanged);
    if (widget.scrollController != null) {
      widget.scrollController!.addListener(_scrolled);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.orderNotifier.removeListener(_valueChanged);
    if (widget.scrollController != null) {
      widget.scrollController!.removeListener(_scrolled);
    }
  }

  @override
  void didUpdateWidget(covariant ReorderableListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      oldWidget.orderNotifier.removeListener(_valueChanged);
      if (oldWidget.scrollController != null) {
        oldWidget.scrollController!.removeListener(_scrolled);
      }
      widget.orderNotifier.addListener(_valueChanged);
      if (widget.scrollController != null) {
        widget.scrollController!.addListener(_scrolled);
      }
      // widgetのプロパティ変更に追従するため。Stateもリビルドする。
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children != null) {
      assert(widget.itemBuilder == null);
      assert(widget.children!.length == widget.orderNotifier.value.length);
    } else {
      assert(widget.itemBuilder != null);
    }

    _logger.fine('[i] build');

    final theme = Theme.of(context);

    void onReorder(int oldIndex, int newIndex) {
      setState(() {
        widget.orderNotifier.value = widget.orderNotifier.value.moved(oldIndex, newIndex);
      });
    }

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: IconTheme(
        data: IconThemeData(
          color: widget.enabled ? widget.dragHandleColor : theme.disabledColor,
        ),
        child: widget.children != null
            ? material.ReorderableListView(
                scrollController: widget.scrollController,
                onReorder: onReorder,
                children: widget.children!,
              )
            : material.ReorderableListView.builder(
                scrollController: widget.scrollController,
                onReorder: onReorder,
                itemCount: widget.orderNotifier.value.length,
                itemBuilder: (context, index) {
                  return widget.itemBuilder!.call(context, index);
                },
              ),
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
