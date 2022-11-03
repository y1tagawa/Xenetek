// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../mi_boilerplates.dart';

/// カラーグリッド
///
/// TODO: グリッド部分切り出し

class MiColorGrid extends StatefulWidget {
  final Color? initialColor;
  final double? chipSize;
  final List<Color?> colors;
  final ValueChanged<Color?>? onChanged;
  final void Function(Color?, bool)? onHover;

  const MiColorGrid({
    super.key,
    this.initialColor,
    this.chipSize = 40,
    required this.colors,
    this.onChanged,
    this.onHover,
  });

  @override
  State<StatefulWidget> createState() => _MiColorGridState();
}

class _MiColorGridState extends State<MiColorGrid> {
  // ignore: unused_field
  Color? _color;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: widget.colors.map((color) {
        return InkWell(
          onTap: () {
            setState(() {
              _color = color;
            });
            widget.onChanged?.call(color);
          },
          onHover: (enter) {
            widget.onHover?.call(color, enter);
          },
          child: SizedBox.square(
            dimension: widget.chipSize,
            child: color != null ? ColoredBox(color: color) : const Icon(Icons.block_outlined),
          ),
        );
      }).toList(),
    );
  }
}

/// カラーグリッドダイアログ表示
///
/// return true: OK, false: キャンセル。
Future<bool> showColorGridDialog({
  required BuildContext context,
  Widget? icon,
  Widget? title,
  Color? initialColor,
  List<Color?>? colors,
  Map<String, List<Color?>>? colorTabs,
  ValueChanged<Color?>? onChanged,
  bool barrierDismissible = true,
}) async {
  assert(colors != null || colorTabs != null);

  Color? color = initialColor;

  return await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return MiOkCancelDialog<bool>(
          icon: MiColorChip(color: color),
          title: title,
          content: colorTabs != null
              ? MiDefaultTabController(
                  length: colorTabs.length,
                  initialIndex: 0,
                  builder: (context) {
                    return Column(
                      children: [
                        MiTabBar(
                          embedded: true,
                          tabs: colorTabs.keys.map((key) => MiTab(text: key)).toList(),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: TabBarView(
                            children: colorTabs.values
                                .map(
                                  (colors) => SingleChildScrollView(
                                    child: MiColorGrid(
                                      colors: colors,
                                      onChanged: (value) {
                                        setState(() => color = value);
                                        onChanged?.call(value);
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    );
                  })
              : SingleChildScrollView(
                  child: MiColorGrid(
                    initialColor: initialColor,
                    colors: colors!,
                    onChanged: (value) {
                      setState(() => color = value);
                      onChanged?.call(value);
                    },
                  ),
                ),
          getValue: (ok) => ok,
        );
      },
    ),
    barrierDismissible: barrierDismissible,
  ).then((value) => value ?? false);
}
