// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter/material.dart' as material show AppBar;

import 'mi_themes.dart';

/// カスタム[AppBar]

class AppBar extends StatelessWidget implements PreferredSizeWidget {
  static const _kProminentTitleHeight = 48.0; // dense listTile height

  final bool prominent;
  final Widget? leading;
  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final Color? foregroundColor;
  final bool? centerTitle;
  final double? titleSpacing;
  final double? toolbarHeight;
  final double prominentTitleHeight;

  const AppBar({
    super.key,
    this.prominent = false,
    this.leading,
    required this.title,
    this.actions,
    this.bottom,
    this.flexibleSpace,
    this.foregroundColor,
    this.centerTitle,
    this.titleSpacing,
    this.toolbarHeight,
    this.prominentTitleHeight = _kProminentTitleHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        preferredHeight(
          prominent: prominent,
          toolbarHeight: toolbarHeight,
          bottom: bottom,
          prominentTitleHeight: prominentTitleHeight,
        ),
      );

  static double preferredHeight({
    required bool prominent,
    double? toolbarHeight,
    PreferredSizeWidget? bottom,
    double? prominentTitleHeight,
  }) {
    return (toolbarHeight ?? kToolbarHeight) +
        (prominent ? (prominentTitleHeight ?? _kProminentTitleHeight) : 0) +
        (bottom?.preferredSize.height ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color resolveFillColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return theme.disabledColor;
      } else {
        return theme.useMaterial3
            ? theme.colorScheme.onSurface
            : theme.isDark
                ? theme.colorScheme.onBackground
                : theme.colorScheme.onPrimary;
      }
    }

    Color resolveCheckColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return theme.disabledColor;
      } else {
        return theme.useMaterial3
            ? theme.colorScheme.surface
            : theme.isDark
                ? theme.colorScheme.background
                : theme.colorScheme.primary;
      }
    }

    final checkBoxTheme = theme.checkboxTheme.copyWith(
      fillColor: MaterialStateProperty.resolveWith(resolveFillColor),
      checkColor: MaterialStateProperty.resolveWith(resolveCheckColor),
    );

    final switchTheme = theme.switchTheme.modify(
      thumbColor: theme.useMaterial3
          ? theme.colorScheme.onSurface
          : theme.isDark
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onPrimary,
      brightness: theme.brightness,
    );

    return CheckboxTheme(
      data: checkBoxTheme,
      child: SwitchTheme(
        data: switchTheme,
        child: material.AppBar(
          leading: leading,
          title: prominent ? null : title,
          actions: actions,
          bottom: prominent
              ? PreferredSize(
                  preferredSize:
                      Size.fromHeight(prominentTitleHeight + (bottom?.preferredSize.height ?? 0)),
                  child: Column(
                    children: [
                      Container(
                        height: prominentTitleHeight,
                        alignment: (centerTitle ?? theme.appBarTheme.centerTitle ?? false)
                            ? Alignment.bottomCenter
                            : Alignment.bottomLeft,
                        padding: EdgeInsets.symmetric(
                          horizontal: titleSpacing ??
                              theme.appBarTheme.titleSpacing ??
                              NavigationToolbar.kMiddleSpacing,
                          vertical: 8.0,
                        ),
                        child: DefaultTextStyle.merge(
                          style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.headline6)!
                              .copyWith(
                            color: foregroundColor ??
                                theme.appBarTheme.foregroundColor ??
                                (theme.useMaterial3
                                    ? theme.colorScheme.onSurface
                                    : theme.isDark
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onPrimary),
                          ),
                          child: title,
                        ),
                      ),
                      if (bottom != null) bottom!
                    ],
                  ),
                )
              : bottom,
          flexibleSpace: flexibleSpace,
          foregroundColor: foregroundColor,
          centerTitle: centerTitle,
          titleSpacing: titleSpacing,
          toolbarHeight: toolbarHeight,
        ),
      ),
    );
  }
}
