// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// カスタム[Tab]
///
/// * [tooltip]追加

class MiTab extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final EdgeInsetsGeometry iconMargin;
  final double? height;
  final Widget? child;
  final String? tooltip;
  const MiTab({
    super.key,
    this.text,
    this.icon,
    this.iconMargin = const EdgeInsets.only(bottom: 10.0),
    this.height,
    this.child,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final tab = Tab(
      text: text,
      icon: icon,
      iconMargin: iconMargin,
      height: height,
      child: child,
    );
    final tooltip_ = tooltip ?? text;
    if (tooltip_ != null && tooltip_.isNotEmpty) {
      return Tooltip(
        message: tooltip_,
        child: tab,
      );
    } else {
      return tab;
    }
  }
}

/// カスタム[TabBar]
///
/// * [enabled]追加

class MiTabBar extends StatelessWidget implements PreferredSizeWidget {
  final bool enabled;
  final TabBar _tabBar;

  // TODO: 必要に応じて他の引数を追加
  MiTabBar({
    super.key,
    this.enabled = true,
    required List<Widget> tabs,
    bool isScrollable = false,
    void Function(int)? onTap,
  }) : _tabBar = TabBar(
          tabs: tabs,
          isScrollable: isScrollable,
          onTap: onTap,
        );

  @override
  Size get preferredSize => _tabBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    // TODO: disable時だけ生成
    final theme = Theme.of(context);
    final textColor =
        _tabBar.labelColor ?? theme.tabBarTheme.labelColor ?? theme.colorScheme.onSurface;
    final disabledTextColor = textColor.withAlpha(179);

    Decoration disabledIndicator() {
      final indicator = theme.tabBarTheme.indicator ?? const UnderlineTabIndicator();
      if (indicator is! UnderlineTabIndicator) {
        return indicator;
      }
      return UnderlineTabIndicator(
        borderSide: indicator.borderSide.copyWith(color: disabledTextColor),
        insets: indicator.insets,
      );
    }

    final disabledIconTheme = IconTheme.of(context).copyWith(
      color: theme.disabledColor,
    );
    final disabledTabBarTheme = TabBarTheme.of(context).copyWith(
      labelColor: enabled ? null : disabledTextColor,
      unselectedLabelColor: enabled ? null : theme.disabledColor,
      indicator: enabled ? null : disabledIndicator(),
    );

    return Theme(
      data: theme.copyWith(
        iconTheme: enabled ? null : disabledIconTheme,
        tabBarTheme: enabled ? null : disabledTabBarTheme,
      ),
      child: IgnorePointer(
        ignoring: !enabled,
        child: _tabBar,
      ),
    );
  }
}

/// カスタム[DefaultTabController]。
///
/// * [onIndexChanged]追加
///
/// s.a. https://api.flutter.dev/flutter/material/TabController-class.html
///   https://api.flutter.dev/flutter/material/DefaultTabController-class.html

class MiDefaultTabController extends StatelessWidget {
  final int length;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;
  final WidgetBuilder builder;
  final Duration? animationDuration;

  const MiDefaultTabController({
    super.key,
    required this.length,
    required this.initialIndex,
    this.onIndexChanged,
    required this.builder,
    this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: length,
      initialIndex: initialIndex,
      child: Builder(
        builder: (BuildContext context) {
          final tabController = DefaultTabController.of(context)!;
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              onIndexChanged?.call(tabController.index);
            }
          });
          return builder(context);
        },
      ),
    );
  }
}
