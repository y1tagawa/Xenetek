// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

// Exampleアプリ用カラーグリッド

class ExColorGrid extends StatelessWidget {
  final int initialTabIndex;
  final bool nullable;
  final void Function(Color?)? onChanged;

  static const _tabs = <Widget>[
    MiTab(icon: Icon(Icons.flutter_dash)),
    MiTab(text: 'X11'),
    MiTab(text: 'JIS'),
  ];

  const ExColorGrid({
    super.key,
    this.initialTabIndex = 0,
    this.onChanged,
    this.nullable = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = <List<Color?>>[
      [if (nullable) null, ...Colors.primaries],
      x11Colors,
      jisCommonColors,
    ];

    final tooltips = [
      [if (nullable) 'null', ...primaryColorNames],
      x11ColorNames,
      jisCommonColorNames,
    ];

    return MiTabbedColorGrid(
      tabs: _tabs,
      colors: colors,
      tooltips: tooltips,
      onChanged: (tabIndex, colorIndex) {
        onChanged?.call(colors[tabIndex][colorIndex]);
      },
    );
  }
}
