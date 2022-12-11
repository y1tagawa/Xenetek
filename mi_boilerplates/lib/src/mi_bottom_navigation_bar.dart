// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart' hide BottomNavigationBar;
import 'package:flutter/material.dart' as material show BottomNavigationBar;
import 'package:logging/logging.dart';

/// 非選択状態可能な[BottomNavigationBar]。
///
/// [currentIndex]が負またはitems範囲外の場合、見た目だけ、どのアイテムも選択されていないように表示する。

class BottomNavigationBar extends StatelessWidget {
  // ignore: unused_field
  static final _logger = Logger((BottomNavigationBar).toString());

  final bool enabled;
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final BottomNavigationBarType? type;
  final double iconSize;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double selectedFontSize;
  final double unselectedFontSize;

  // TODO: 必要になったら他のプロパティも
  const BottomNavigationBar({
    super.key,
    this.enabled = true,
    this.currentIndex = 0,
    required this.items,
    this.onTap,
    this.type,
    this.iconSize = 24.0,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedFontSize = 14.0,
    this.unselectedFontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final unselected = currentIndex < 0 || currentIndex >= items.length;
    final theme = Theme.of(context);

    return IgnorePointer(
      ignoring: !enabled,
      child: material.BottomNavigationBar(
        currentIndex: unselected ? 0 : currentIndex,
        items: items,
        onTap: onTap,
        type: type,
        iconSize: iconSize,
        selectedItemColor: enabled
            ? unselected
                ? unselectedItemColor ?? theme.unselectedWidgetColor
                : null
            : theme.disabledColor,
        unselectedItemColor: enabled ? null : theme.disabledColor,
        selectedFontSize: unselected ? unselectedFontSize : selectedFontSize,
      ),
    );
  }
}
