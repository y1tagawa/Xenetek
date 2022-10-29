// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
