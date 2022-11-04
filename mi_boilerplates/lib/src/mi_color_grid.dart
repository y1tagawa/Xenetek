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
  static const double kItemSize = 40.0;

  final Color? initialColor;
  final double? chipSize;
  final List<Color?> colors;
  final List<String>? tooltips;
  final ValueChanged<int>? onChanged;
  final void Function(int, bool)? onHover;

  const MiColorGrid({
    super.key,
    this.initialColor,
    this.chipSize,
    required this.colors,
    this.tooltips,
    this.onChanged,
    this.onHover,
  }) : assert(tooltips == null || tooltips.length == colors.length);

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
          child: run(() {
            Widget item = SizedBox.square(
              dimension: widget.chipSize ?? MiColorGrid.kItemSize,
              child: value != null ? ColoredBox(color: value) : const Icon(Icons.block_outlined),
            );
            if (widget.tooltips != null) {
              item = Tooltip(
                message: widget.tooltips![index],
                child: item,
              );
            }
            return item;
          }),
        );
      }).toList(),
    );
  }
}
