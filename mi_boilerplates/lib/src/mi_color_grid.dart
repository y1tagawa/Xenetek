// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../mi_boilerplates.dart';

/// カラーグリッド
///
/// TODO: グリッド部分切り出し

class MiColorGrid extends StatefulWidget {
  final Color? initialColor;
  final double? chipSize;
  final List<Color?> colors;
  final ValueChanged<int>? onChanged;
  final void Function(int, bool)? onHover;

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
      children: widget.colors.mapIndexed((index, value) {
        return InkWell(
          onTap: () {
            setState(() {
              _color = value;
            });
            widget.onChanged?.call(index);
          },
          onHover: (enter) {
            widget.onHover?.call(index, enter);
          },
          child: SizedBox.square(
            dimension: widget.chipSize,
            child: value != null ? ColoredBox(color: value) : const Icon(Icons.block_outlined),
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
  void Function(String? key, int index)? onChanged,
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
                            children: colorTabs.entries
                                .map(
                                  (entry) => SingleChildScrollView(
                                    child: MiColorGrid(
                                      colors: entry.value,
                                      onChanged: (index) {
                                        setState(() => color = entry.value[index]);
                                        onChanged?.call(entry.key, index);
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
                    onChanged: (index) {
                      setState(() => color = colors[index]);
                      onChanged?.call(null, index);
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
