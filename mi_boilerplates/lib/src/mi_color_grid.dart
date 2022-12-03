// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../mi_boilerplates.dart';

/// カラーグリッド

class MiColorGrid extends StatelessWidget {
  static const double kItemSize = 40.0;

  final List<Color?> colors;
  final List<String?>? tooltips;
  final double? itemSize;
  final ValueChanged<int>? onChanged;

  const MiColorGrid({
    super.key,
    required this.colors,
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
            child: run(
              () {
                Widget item = MiColorChip(color: colors[i], size: itemSize_);
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

class MiTabbedColorGrid extends StatelessWidget {
  final int initialTabIndex;
  final List<Widget> tabs;
  final List<List<Color?>> colors;
  final List<List<String>?>? tooltips;
  final void Function(int tabIndex, int colorIndex)? onChanged;

  const MiTabbedColorGrid({
    super.key,
    this.initialTabIndex = 0,
    required this.tabs,
    required this.colors,
    this.tooltips,
    this.onChanged,
  }) : assert(tabs.length == colors.length);

  @override
  Widget build(BuildContext context) {
    return MiEmbeddedTabView(
      tabs: tabs,
      initialIndex: initialTabIndex,
      children: colors
          .mapIndexed(
            (tabIndex, colors_) => SingleChildScrollView(
              child: MiColorGrid(
                colors: colors_,
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

///

class MiColorGridHelper {
  static Future<bool> showColorSelectDialog({
    required BuildContext context,
    Widget? title,
    Color? initialColor,
    ValueChanged<Color?>? onChanged,
    double? width,
    double? height,
    required Widget Function(BuildContext context, ValueChanged<Color?>? onChanged) builder,
  }) async {
    Color? color = initialColor;

    return await showDialog<bool>(
      context: context,
      builder: (context) => MiOkCancelDialog<bool>(
        icon: MiColorChip(color: color),
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
    ).then((value) => value ?? false);
  }
}
