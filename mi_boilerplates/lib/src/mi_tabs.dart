// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

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
  final List<Widget> tabs;
  final bool isScrollable;
  final Color? indicatorColor;
  final double indicatorWeight;
  final Color? labelColor;
  final ValueChanged<int>? onTap;
  final bool embedded;

  // TODO: 必要に応じて他の引数を追加
  const MiTabBar({
    super.key,
    this.enabled = true,
    required this.tabs,
    this.isScrollable = false,
    this.indicatorColor,
    this.indicatorWeight = 2.0,
    this.labelColor,
    this.onTap,
    this.embedded = false,
  });

  @override
  Size get preferredSize {
    // s.a. https://github.com/flutter/flutter/blob/24dfdec3e2b5fc7675d6f576d6231be107f65bef/packages/flutter/lib/src/material/tabs.dart#L26
    // https://github.com/flutter/flutter/blob/24dfdec3e2b5fc7675d6f576d6231be107f65bef/packages/flutter/lib/src/material/tabs.dart#L885
    double maxHeight = 46.0;
    for (final Widget item in tabs) {
      if (item is PreferredSizeWidget) {
        final double itemHeight = item.preferredSize.height;
        maxHeight = math.max(itemHeight, maxHeight);
      }
    }
    return Size.fromHeight(maxHeight + indicatorWeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor_ = indicatorColor ??
        (embedded
            ? theme.useMaterial3
                ? theme.colorScheme.onSurface
                : theme.isDark
                    ? theme.colorScheme.onSurface
                    : theme.primaryColorDark
            : theme.colorScheme.onPrimary);
    final disabledColor = indicatorColor_.withAlpha(179);

    return Theme(
      data: theme.copyWith(
        tabBarTheme: TabBarTheme.of(context).copyWith(
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: enabled ? indicatorColor_ : disabledColor,
              width: indicatorWeight,
            ),
          ),
          labelColor: enabled ? indicatorColor_ : disabledColor,
        ),
      ),
      child: IgnorePointer(
        ignoring: !enabled,
        child: TabBar(
          tabs: tabs,
          onTap: onTap,
        ),
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
