// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

// s.a. https://github.com/flutter/flutter/blob/24dfdec3e2b5fc7675d6f576d6231be107f65bef/packages/flutter/lib/src/material/tabs.dart#L26
const double _kTabHeight = 46.0;
const double _kTextAndIconTabHeight = 72.0;

/// カスタム[Tab]
///
/// * [tooltip]追加

class MiTab extends StatelessWidget implements PreferredSizeWidget {
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

  // s.a. https://github.com/flutter/flutter/blob/24dfdec3e2b5fc7675d6f576d6231be107f65bef/packages/flutter/lib/src/material/tabs.dart#L153
  @override
  Size get preferredSize {
    if (height != null) {
      return Size.fromHeight(height!);
    } else if ((text != null || child != null) && icon != null) {
      return const Size.fromHeight(_kTextAndIconTabHeight);
    } else {
      return const Size.fromHeight(_kTabHeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tab = Tab(
      text: text,
      icon: icon,
      iconMargin: iconMargin,
      height: height,
      child: child,
    );
    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(
        message: tooltip,
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
  // s.a. https://github.com/flutter/flutter/blob/24dfdec3e2b5fc7675d6f576d6231be107f65bef/packages/flutter/lib/src/material/tabs.dart#L885
  static double preferredHeight({
    required List<Widget> tabs,
    double indicatorWeight = 2.0,
  }) {
    double maxHeight = _kTabHeight;
    for (final Widget item in tabs) {
      if (item is PreferredSizeWidget) {
        final double itemHeight = item.preferredSize.height;
        maxHeight = math.max(itemHeight, maxHeight);
      }
    }
    return maxHeight + indicatorWeight;
  }

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
  Size get preferredSize =>
      Size.fromHeight(preferredHeight(tabs: tabs, indicatorWeight: indicatorWeight));

  @override
  Widget build(BuildContext context) {
    // TODO: テーマ変更点ドキュメント
    final theme = Theme.of(context);
    final indicatorColor_ = indicatorColor ??
        (embedded
            ? theme.useMaterial3
                ? theme.colorScheme.onSurface
                : theme.isDark
                    ? theme.colorScheme.secondary
                    : theme.primaryColorDark
            : theme.useMaterial3
                ? theme.colorScheme.onSurface
                : theme.isDark
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onPrimary);
    final disabledIndicatorColor = indicatorColor_.withAlpha(179);

    final labelColor_ = labelColor ??
        (embedded
            ? theme.useMaterial3
                ? theme.colorScheme.onSurface
                : theme.isDark
                    ? theme.colorScheme.onSurface
                    : theme.primaryColorDark
            : theme.useMaterial3
                ? theme.colorScheme.onSurface
                : theme.isDark
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onPrimary);
    final disabledLabelColor = theme.disabledColor;

    return Theme(
      data: theme.copyWith(
        tabBarTheme: TabBarTheme.of(context).copyWith(
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: enabled ? indicatorColor_ : disabledIndicatorColor,
              width: indicatorWeight,
            ),
          ),
          labelColor: enabled ? labelColor_ : disabledLabelColor,
        ),
      ),
      child: IgnorePointer(
        ignoring: !enabled,
        child: TabBar(
          tabs: tabs,
          isScrollable: isScrollable,
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
  static final _logger = Logger((MiDefaultTabController).toString());

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
          _logger.fine('[i] builder');
          final tabController = DefaultTabController.of(context)!;
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              onIndexChanged?.call(tabController.index);
            }
          });
          return builder(context).also((it) {
            _logger.fine('[o] builder');
          });
        },
      ),
    );
  }
}

/// AppBarのbottom以外用[TabBarView]
///
/// https://m2.material.io/components/tabs#placement

class MiEmbeddedTabView extends StatelessWidget {
  final List<Widget> tabs;
  final int initialIndex;
  final List<Widget> children;
  final double? spacing;

  const MiEmbeddedTabView({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    required this.children,
    this.spacing,
  }) : assert(tabs.length == children.length);

  @override
  Widget build(BuildContext context) {
    return MiDefaultTabController(
      length: tabs.length,
      initialIndex: initialIndex,
      builder: (context) {
        return Column(
          children: [
            MiTabBar(
              embedded: true,
              tabs: tabs,
            ),
            SizedBox(height: spacing ?? 4.0),
            Expanded(
              child: TabBarView(
                children: children,
              ),
            ),
          ],
        );
      },
    );
  }
}
