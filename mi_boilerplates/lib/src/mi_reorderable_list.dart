// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

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
/// [notifier] リストを保持する[ValueNotifier]。
/// [itemBuilder] リストのウィジェットを生成するメソッド。それぞれユニークな[key]を与える必要がある。

class MiReorderableListView<T> extends StatefulWidget {
  final bool enabled;
  final ValueNotifier<List<T>> notifier;
  final IndexedWidgetBuilder itemBuilder;
  final Color? dragHandleColor;
  // TODO: 必要に応じて他のプロパティも

  const MiReorderableListView({
    super.key,
    this.enabled = true,
    required this.notifier,
    required this.itemBuilder,
    this.dragHandleColor,
  });

  @override
  State<MiReorderableListView> createState() => _MiReorderableListViewState();
}

class _MiReorderableListViewState<T> extends State<MiReorderableListView<T>> {
  static final _logger = Logger((_MiReorderableListViewState).toString());

  void _valueChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_valueChanged);
  }

  @override
  void dispose() {
    super.dispose();
    widget.notifier.removeListener(_valueChanged);
  }

  @override
  void didUpdateWidget(covariant MiReorderableListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      oldWidget.notifier.removeListener(_valueChanged);
      widget.notifier.addListener(_valueChanged);
      // widgetのプロパティ変更に追従するため。Stateもリビルドする。
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.fine('[i] build');

    final theme = Theme.of(context);

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: IconTheme(
        data: IconThemeData(
          color: widget.enabled ? widget.dragHandleColor : theme.disabledColor,
        ),
        child: ReorderableListView.builder(
          itemCount: widget.notifier.value.length,
          itemBuilder: (context, index) {
            return widget.itemBuilder(context, index);
          },
          onReorder: (oldIndex, newIndex) {
            setState(() {
              widget.notifier.value = widget.notifier.value.moved(oldIndex, newIndex);
            });
          },
        ),
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
