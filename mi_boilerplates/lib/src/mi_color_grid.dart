// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../mi_boilerplates.dart';

/// カラーグリッド

class MiColorGrid extends StatelessWidget {
  static const double kItemSize = 40.0;

  final List<Color?> colors;
  final List<String>? tooltips;
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
                if (tooltips != null) {
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
