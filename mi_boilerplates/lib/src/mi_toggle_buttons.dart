// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../mi_boilerplates.dart';

/// カスタムToggleButtons
///
/// * [enabled]
/// * [split]を指定した場合、[children]その個数ごとに行に分割し、[Column]に格納する。
class MiToggleButtons extends StatelessWidget {
  final bool enabled;
  final int? split;
  final List<Widget> children;
  final List<bool> isSelected;
  final ValueChanged<int>? onPressed;
  final bool renderBorder;

  const MiToggleButtons({
    super.key,
    this.enabled = true,
    this.split,
    required this.children,
    required this.isSelected,
    this.onPressed,
    this.renderBorder = true,
  })  : assert(children.length == isSelected.length),
        assert(split == null || split >= 2);

  @override
  Widget build(BuildContext context) {
    if (split == null) {
      return ToggleButtons(
        isSelected: isSelected,
        onPressed: enabled ? onPressed : null,
        renderBorder: renderBorder,
        children: children,
      );
    }

    final n = split!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i += n)
          ToggleButtons(
            isSelected: isSelected.skip(i).take(n).toList(),
            onPressed: enabled ? (index) => onPressed?.call(index + i) : null,
            renderBorder: renderBorder,
            children: children.skip(i).take(n).toList(),
          ),
      ],
    );
  }
}

/// ラジオトグルボタン
class MiRadioToggleButtons extends StatelessWidget {
  final bool enabled;
  final int? split;
  final List<Widget> children;
  final int? initiallySelected;
  final ValueChanged<int>? onPressed;
  final bool renderBorder;

  const MiRadioToggleButtons({
    super.key,
    this.enabled = true,
    this.split,
    required this.children,
    this.initiallySelected,
    this.onPressed,
    this.renderBorder = true,
  })  : assert(initiallySelected == null ||
            (initiallySelected >= 0 && initiallySelected < children.length)),
        assert(split == null || split >= 2);

  @override
  Widget build(BuildContext context) {
    return MiToggleButtons(
      enabled: enabled,
      split: split,
      isSelected: iota(children.length).map((it) => it == initiallySelected).toList(),
      onPressed: onPressed,
      renderBorder: renderBorder,
      children: children,
    );
  }
}
