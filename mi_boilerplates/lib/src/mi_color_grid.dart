// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../mi_boilerplates.dart';

class MiGrid<T> extends StatefulWidget {
  final T initialValue;
  final int length;
  final Widget Function(
    BuildContext context,
    int index,
    void Function(T) setter,
  ) itemBuilder;

  const MiGrid({
    super.key,
    required this.initialValue,
    required this.length,
    required this.itemBuilder,
  });

  @override
  State<StatefulWidget> createState() => _MiGridState<T>();
}

class _MiGridState<T> extends State<MiGrid<T>> {
  // ignore: unused_field
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _setValue(T value) {
    setState(() {
      _value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (int i = 0; i < widget.length; ++i) widget.itemBuilder(context, i, _setValue),
      ],
    );
  }
}

/// カラーグリッド

class MiColorGrid extends StatelessWidget {
  static const double kItemSize = 40.0;

  final Color? initialColor;
  final List<Color?> colors;
  final List<String>? tooltips;
  final double? itemSize;
  final ValueChanged<int>? onChanged;
  final void Function(int, bool)? onHover;

  const MiColorGrid({
    super.key,
    this.initialColor,
    required this.colors,
    this.tooltips,
    this.itemSize,
    this.onChanged,
    this.onHover,
  }) : assert(tooltips == null || tooltips.length == colors.length);

  @override
  Widget build(BuildContext context) {
    return MiGrid<Color?>(
      initialValue: initialColor,
      length: colors.length,
      itemBuilder: (context, index, setter) {
        return InkWell(
          onTap: () {
            setter(colors[index]);
            onChanged?.call(index);
          },
          onHover: (enter) {
            onHover?.call(index, enter);
          },
          child: run(
            () {
              final value = colors[index];
              Widget item = SizedBox.square(
                dimension: itemSize ?? kItemSize,
                child: value != null ? ColoredBox(color: value) : const Icon(Icons.block_outlined),
              );
              if (tooltips != null) {
                item = Tooltip(
                  message: tooltips![index],
                  child: item,
                );
              }
              return item;
            },
          ),
        );
      },
    );
  }
}
