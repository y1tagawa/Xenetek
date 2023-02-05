// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../mi_boilerplates.dart' as mi;

/// カラーグリッド
class ColorGrid extends StatelessWidget {
  static const double kItemSize = 40.0;

  final List<Color?> colors;
  final Icon? nullIcon;
  final List<String?>? tooltips;
  final double? itemSize;
  final ValueChanged<int>? onChanged;

  const ColorGrid({
    super.key,
    required this.colors,
    this.nullIcon,
    this.tooltips,
    this.itemSize,
    this.onChanged,
  }) : assert(tooltips == null || tooltips.length == colors.length);

  @override
  Widget build(BuildContext context) {
    final itemSize_ = itemSize ?? kItemSize;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (int i = 0; i < colors.length; ++i)
          InkWell(
            onTap: () {
              onChanged?.call(i);
            },
            child: mi.run(
              () {
                Widget item = mi.ColorChip(
                  color: colors[i],
                  nullIcon: nullIcon,
                  size: itemSize_,
                );
                if (tooltips != null && i < tooltips!.length && tooltips![i] != null) {
                  item = Tooltip(
                    message: tooltips![i],
                    child: item,
                  );
                }
                return item;
              },
            ),
          ),
      ],
    );
  }
}

/// タブ付きカラーグリッド
class TabbedColorGrid extends StatelessWidget {
  final int initialTabIndex;
  final List<Widget> tabs;
  final List<List<Color?>> colors;
  final Icon? nullIcon;
  final List<List<String>?>? tooltips;
  final void Function(int tabIndex, int colorIndex)? onChanged;

  const TabbedColorGrid({
    super.key,
    this.initialTabIndex = 0,
    required this.tabs,
    required this.colors,
    this.nullIcon,
    this.tooltips,
    this.onChanged,
  }) : assert(tabs.length == colors.length);

  @override
  Widget build(BuildContext context) {
    return mi.EmbeddedTabView(
      tabs: tabs,
      initialIndex: initialTabIndex,
      children: colors
          .mapIndexed(
            (tabIndex, colors_) => SingleChildScrollView(
              child: ColorGrid(
                colors: colors_,
                nullIcon: nullIcon,
                tooltips: tooltips?.let((it) => tabIndex < it.length ? it[tabIndex] : null),
                onChanged: (colorIndex) {
                  onChanged?.call(tabIndex, colorIndex);
                },
              ),
            ),
          )
          .toList(),
    );
  }
}

class ColorGridHelper {
  /// 色選択ダイアログ
  ///
  /// [initialColor]を初期値とする色選択ダイアログを表示する。
  /// OKかキャンセルか、最後に選択した色(またはnull)のペアを返す。
  static Future<MapEntry<bool, Color?>> showColorSelectDialog({
    required BuildContext context,
    Widget? title,
    Color? initialColor,
    Icon? nullIcon,
    ValueChanged<Color?>? onChanged,
    double? width,
    double? height,
    required Widget Function(BuildContext context, ValueChanged<Color?>? onChanged) builder,
  }) async {
    Color? color = initialColor;

    return await showDialog<bool>(
      context: context,
      builder: (context) => mi.OkCancelDialog<bool>(
        icon: mi.ColorChip(
          color: color,
          nullIcon: nullIcon,
        ),
        title: title,
        getValue: (ok) => ok,
        content: SizedBox(
          width: width ?? MediaQuery.of(context).size.width * 0.8,
          height: height ?? MediaQuery.of(context).size.height * 0.4,
          child: StatefulBuilder(
            builder: (context, setState) {
              return builder(context, (color_) {
                setState(() => color = color_);
                onChanged?.call(color_);
              });
            },
          ),
        ),
      ),
    ).then((value) => MapEntry(value ?? false, color));
  }
}
