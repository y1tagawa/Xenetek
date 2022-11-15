// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../mi_boilerplates.dart';

/// カスタムポップアップメニューアイテム
///
/// * AppBar上の[PopupMenuButton]など、[IconTheme]が変更されている場合、
///   メニュー上のアイコン色が見づらい場合があるので修正する。
///   TODO: PopupMenuThemeData.colorを考慮する

class MiPopupMenuItem<T> extends PopupMenuItem<T> {
  // ウィジェットではStateにプロパティを渡すだけ
  const MiPopupMenuItem({
    super.key,
    super.value,
    super.onTap,
    super.enabled = true,
    super.padding,
    super.textStyle,
    super.mouseCursor,
    required super.child,
  });

  @override
  PopupMenuItemState<T, PopupMenuItem<T>> createState() => _MiPopupMenuItemState<T>();
}

class _MiPopupMenuItemState<T> extends PopupMenuItemState<T, MiPopupMenuItem<T>> {
  // StateでPopupMenuItemState#buildをIconThemeでラップする
  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;
    return IconTheme.merge(
      data: IconThemeData(color: iconColor),
      child: super.build(context),
    );
  }
}

/// チェックリストメニューアイテム
///
/// [CheckedPopupMenuItem]が大きいので代替。

class MiCheckPopupMenuItem<T> extends MiPopupMenuItem<T> {
  static const _checkSize = 15.0;

  final bool checked;
  final ValueChanged<bool>? onChanged;

  const MiCheckPopupMenuItem({
    super.key,
    super.enabled = true,
    super.value,
    required this.checked,
    this.onChanged,
    required super.child,
  });

  @override
  Widget? get child {
    return MiIcon(
      icon: SizedBox.square(
        dimension: 24,
        child: checked ? const Icon(Icons.check_rounded, size: _checkSize) : null,
      ),
      text: super.child!,
    );
  }

  @override
  VoidCallback? get onTap => () => onChanged?.call(!checked);
}

/// ラジオメニューアイテム

class MiRadioPopupMenuItem<T> extends MiPopupMenuItem<T> {
  static const _radioSize = 12.0;

  final bool checked;
  final ValueChanged<bool>? onChanged;

  const MiRadioPopupMenuItem({
    super.key,
    super.enabled = true,
    super.value,
    required this.checked,
    this.onChanged,
    required super.child,
  });

  @override
  Widget? get child {
    return MiIcon(
      icon: SizedBox.square(
        dimension: 24,
        child: checked ? const Icon(Icons.circle, size: _radioSize) : null,
      ),
      text: super.child!,
    );
  }

  @override
  VoidCallback? get onTap => () => onChanged?.call(!checked);
}

/// グリッドポップアップメニューボタン
///
class MiGridPopupMenuButton extends StatelessWidget {
  // https://github.com/flutter/flutter/blob/f5205b15c8da52fd172b27b03e7b85a068ef3bf4/packages/flutter/lib/src/material/popup_menu.dart#L37
  static const double kMenuItemWidth = 56.0 * 2;

  final double? width;
  final double? height;
  final double spacing;
  final double runSpacing;
  final List<Widget> items;
  final List<String>? tooltips;
  final ValueChanged<int>? onSelected;
  final Widget? child;
  final Offset offset;

  const MiGridPopupMenuButton({
    super.key,
    this.width,
    this.height,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    required this.items,
    this.tooltips,
    this.onSelected,
    this.child,
    this.offset = Offset.zero,
  }) : assert(tooltips == null || tooltips.length == items.length);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: offset,
      itemBuilder: (context) {
        return [
          PopupMenuItem<int>(
            child: SingleChildScrollView(
              child: SizedBox(
                width: width ?? kMenuItemWidth,
                height: height ?? MediaQuery.of(context).size.height * 0.3,
                child: Wrap(
                  spacing: spacing,
                  runSpacing: runSpacing,
                  children: items
                      .mapIndexed(
                        (index, item) => InkWell(
                          child: item,
                          onTap: () {
                            onSelected?.call(index);
                            Navigator.of(context).pop();
                          },
                        ).let(
                          (it) => tooltips != null
                              ? Tooltip(
                                  message: tooltips![index],
                                  child: it,
                                )
                              : it,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          )
        ];
      },
      child: child,
    );
  }
}
