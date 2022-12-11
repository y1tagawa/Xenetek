// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide PopupMenuButton, PopupMenuItem;
import 'package:flutter/material.dart' as material show PopupMenuButton, PopupMenuItem;

import '../mi_boilerplates.dart' as mi;

/// カスタムポップアップメニューアイテム
///
/// * AppBar上の[PopupMenuButton]など、[IconTheme]が変更されている場合、
///   メニュー上のアイコン色が見づらい場合があるので修正する。
///   TODO: PopupMenuThemeData.colorを考慮する

// TODO: 名前
class PopupMenuItem<T> extends material.PopupMenuItem<T> {
  // ウィジェットではStateにプロパティを渡すだけ
  const PopupMenuItem({
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
  PopupMenuItemState<T, PopupMenuItem<T>> createState() => _PopupMenuItemState<T>();
}

class _PopupMenuItemState<T> extends PopupMenuItemState<T, PopupMenuItem<T>> {
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

class CheckPopupMenuItem<T> extends PopupMenuItem<T> {
  static const _checkSize = 15.0;

  final bool checked;
  final ValueChanged<bool>? onChanged;

  const CheckPopupMenuItem({
    super.key,
    super.enabled = true,
    super.value,
    required this.checked,
    this.onChanged,
    required super.child,
  });

  @override
  Widget? get child {
    return mi.MiIcon(
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

class RadioPopupMenuItem<T> extends PopupMenuItem<T> {
  static const _radioSize = 12.0;

  final bool checked;
  final ValueChanged<bool>? onChanged;

  const RadioPopupMenuItem({
    super.key,
    super.enabled = true,
    super.value,
    required this.checked,
    this.onChanged,
    required super.child,
  });

  @override
  Widget? get child {
    return mi.MiIcon(
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

/// グリッドポップアップメニューアイテム

class GridPopupMenuItem extends PopupMenuItem<int> {
  final List<Widget> items;
  final List<String>? tooltips;
  final double? spacing;
  final double? runSpacing;

  const GridPopupMenuItem({
    super.key,
    super.enabled,
    required this.items,
    this.tooltips,
    this.spacing,
    this.runSpacing,
  })  : assert(tooltips == null || tooltips.length == items.length),
        super(child: null);

  @override
  PopupMenuItemState<int, PopupMenuItem<int>> createState() => _GridPopupMenuItemState();
}

class _GridPopupMenuItemState extends PopupMenuItemState<int, GridPopupMenuItem> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: widget.spacing ?? 0.0,
      runSpacing: widget.runSpacing ?? 0.0,
      children: widget.items
          .mapIndexed(
            (index, item) => InkWell(
              child: item,
              onTap: () {
                Navigator.of(context).pop(index);
              },
            ).let(
              (it) => widget.tooltips != null
                  ? Tooltip(
                      message: widget.tooltips![index],
                      child: it,
                    )
                  : it,
            ),
          )
          .toList(),
    );
  }
}

/// グリッドポップアップメニューボタン
///
/// ポップアップに[items]をグリッド状に並べ、選択されたアイテムのインデックスを[onSelected]で通知する。

class GridPopupMenuButton extends StatelessWidget {
  final bool enabled;
  final List<Widget> items;
  final List<String>? tooltips;
  final ValueChanged<int>? onSelected;
  final double spacing;
  final double runSpacing;
  final Widget? child;
  final Offset offset;
  final String? tooltip;

  const GridPopupMenuButton({
    super.key,
    this.enabled = true,
    required this.items,
    this.tooltips,
    this.onSelected,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    this.child,
    this.offset = Offset.zero,
    this.tooltip,
  }) : assert(tooltips == null || tooltips.length == items.length);

  @override
  Widget build(BuildContext context) {
    return material.PopupMenuButton<int>(
      enabled: enabled,
      onSelected: onSelected,
      offset: offset,
      tooltip: tooltip,
      itemBuilder: (context) {
        return [
          GridPopupMenuItem(
            items: items,
            tooltips: tooltips,
            spacing: spacing,
            runSpacing: runSpacing,
          ),
        ];
      },
      child: child,
    );
  }
}

/// グリッドアイテム
///
/// [GridView]や[Wrap]のアイテムとして、一定サイズの中でアライメントしたら結構大変だったのでウィジェットとする。

class GridItem extends StatelessWidget {
  final Widget? child;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final MainAxisAlignment? mainAxisAlignment;
  final MainAxisSize? mainAxisSize;
  final CrossAxisAlignment? crossAxisAlignment;

  const GridItem({
    super.key,
    this.child,
    this.constraints,
    this.margin,
    this.mainAxisAlignment,
    this.mainAxisSize,
    this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints ??
          const BoxConstraints(
            minWidth: kToolbarHeight,
            minHeight: kToolbarHeight,
          ),
      child: Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        mainAxisSize: mainAxisSize ?? MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: [
          Padding(
            padding: margin ?? const EdgeInsets.symmetric(horizontal: 8),
            child: child,
          ),
        ],
      ),
    );
  }
}
