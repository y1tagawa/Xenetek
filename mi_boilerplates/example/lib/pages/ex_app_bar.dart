// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import '../main.dart';

// Exampleアプリでウィジェットの[enable]を切り替えて動作を見る情況が頻出するので、一個フラグを設ける。
// 各ウィジェットの対応はそれぞれのページで行う。
final enableActionsProvider = StateProvider((ref) => true);

final prominentProvider = StateProvider((ref) => false);

class _EnableActionsSwitch extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);

    return Tooltip(
      message: enableActions ? 'Enable actions: ON' : 'Enable actions: OFF',
      child: Switch(
        value: enableActions,
        onChanged: (value) => ref.read(enableActionsProvider.notifier).state = value,
      ),
    );
  }
}

class _ThemeAdjustmentCheckbox extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(enableActionsProvider);
    final themeAdjustment = ref.watch(modifyThemeProvider);

    return Tooltip(
      message: themeAdjustment ? 'Theme adjustment: ON' : 'Theme adjustment: OFF',
      child: Checkbox(
        value: themeAdjustment,
        onChanged:
            enabled ? (value) => ref.read(modifyThemeProvider.notifier).state = value! : null,
      ),
    );
  }
}

class _OverflowMenu extends ConsumerWidget {
  static final _logger = Logger((_OverflowMenu).toString());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(enableActionsProvider);
    final brightness = ref.watch(brightnessProvider);

    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          mi.CheckPopupMenuItem(
            checked: enabled,
            child: const Text('Enable actions'),
            onChanged: (value) {
              ref.read(enableActionsProvider.notifier).state = value;
            },
          ),
          mi.CheckPopupMenuItem(
            enabled: enabled,
            checked: ref.watch(modifyThemeProvider),
            child: const Text('Adjust theme'),
            onChanged: (value) {
              ref.read(modifyThemeProvider.notifier).state = value;
            },
          ),
          mi.CheckPopupMenuItem(
            enabled: enabled,
            checked: ref.watch(useM3Provider),
            child: const Text('Use M3'),
            onChanged: (value) {
              ref.read(useM3Provider.notifier).state = value;
            },
          ),
          mi.CheckPopupMenuItem(
            enabled: enabled,
            checked: brightness.isDark,
            child: const Text('Dark mode'),
            onChanged: (value) => ref.read(brightnessProvider.notifier).state =
                value ? Brightness.dark : Brightness.light,
          ),
          mi.PopupMenuItem(
            enabled: enabled,
            child: const mi.MiIcon(
              text: Text('Color settings...'),
            ),
            onTap: () {
              _logger.fine('tap!');
            },
          ),
        ];
      },
      offset: const Offset(0, 40),
      tooltip: <String>[
        if (ref.read(enableActionsProvider)) 'Enabled',
        if (ref.read(modifyThemeProvider)) 'Adjusted',
        ref.read(useM3Provider) ? 'M3' : 'M2',
        if (ref.read(brightnessProvider).isDark) 'Dark',
      ].join(', '),
      //icon: const Icon(Icons.square),
    );
  }
}

// Exampleアプリ用AppBar
//
// テーマ調整ON/OFFによりTabBarを切り替える

class ExAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool prominent;
  final Widget? leading;
  final Widget title;
  final Widget? icon;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final List<Widget>? actions;
  final bool? centerTitle;
  final double? toolbarHeight;

  const ExAppBar({
    super.key,
    this.prominent = false,
    this.leading,
    required this.title,
    this.icon,
    this.bottom,
    this.flexibleSpace,
    this.actions,
    this.centerTitle,
    this.toolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        mi.AppBar.preferredHeight(
          prominent: prominent,
          bottom: bottom,
          toolbarHeight: toolbarHeight,
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(enableActionsProvider);
    final brightness = ref.watch(brightnessProvider);
    final theme = Theme.of(context);

    final flexibleSpace_ = flexibleSpace ??
        icon?.let((it) {
          return IconTheme(
            data: IconThemeData(
                color: theme.isDark
                    ? theme.colorScheme.onSurface.withAlpha(36)
                    : theme.colorScheme.onPrimary.withAlpha(36),
                size: 240),
            child: FittedBox(
              fit: BoxFit.none,
              clipBehavior: Clip.hardEdge,
              child: it,
            ),
          );
        });

    if (ref.watch(modifyThemeProvider)) {
      return mi.AppBar(
        prominent: prominent,
        leading: leading,
        title: InkWell(
          onTap: () {
            ref.read(prominentProvider.notifier).state = !prominent;
          },
          child: title,
        ),
        bottom: bottom,
        flexibleSpace: flexibleSpace_,
        actions: <Widget>[
          if (actions != null) ...actions!,
          if (prominent) ...[
            _ThemeAdjustmentCheckbox(),
            mi.CheckIconButton(
              enabled: enabled,
              checked: ref.watch(useM3Provider),
              onChanged: (value) {
                ref.read(useM3Provider.notifier).state = value;
              },
              checkIcon: const Icon(Icons.filter_3_outlined),
              uncheckIcon: const Icon(Icons.filter_2_outlined),
            ),
            mi.CheckIconButton(
              enabled: enabled,
              checked: brightness.isDark,
              onChanged: (value) async {
                ref.read(brightnessProvider.notifier).state =
                    value ? Brightness.dark : Brightness.light;
              },
              checkIcon: const Icon(Icons.dark_mode_outlined),
              uncheckIcon: const Icon(Icons.light_mode_outlined),
            ),
            _EnableActionsSwitch(),
          ] else
            _OverflowMenu(),
        ],
        centerTitle: centerTitle,
      );
    } else {
      return AppBar(
        leading: leading,
        title: title,
        bottom: bottom,
        flexibleSpace: flexibleSpace_,
        actions: <Widget>[
          if (actions != null) ...actions!,
          _ThemeAdjustmentCheckbox(),
          _EnableActionsSwitch(),
          _OverflowMenu(),
        ],
        centerTitle: centerTitle,
      );
    }
  }
}

// Exampleアプリ用TabBar
//
// テーマ調整ON/OFFによりTabBarを切り替える

class ExTabBar extends ConsumerWidget with PreferredSizeWidget {
  final bool enabled;
  final List<Widget> tabs;
  final bool isScrollable;
  final double indicatorWeight;
  final ValueChanged<int>? onTap;
  final bool embedded;

  const ExTabBar({
    super.key,
    this.enabled = true,
    required this.tabs,
    this.isScrollable = false,
    this.indicatorWeight = 2.0,
    this.onTap,
    this.embedded = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        mi.TabBar.preferredHeight(
          tabs: tabs,
          indicatorWeight: indicatorWeight,
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(modifyThemeProvider)
        ? mi.TabBar(
            enabled: enabled,
            tabs: tabs,
            isScrollable: isScrollable,
            embedded: embedded,
          )
        : TabBar(
            tabs: tabs,
            isScrollable: isScrollable,
          );
  }
}

// Exampleアプリ用BottomNavigationBar
//
// TODO: 横画面でNavigationRail

class ExBottomNavigationBar extends ConsumerWidget {
  // ignore: unused_field
  static final _logger = Logger((ExBottomNavigationBar).toString());

  const ExBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Home',
        tooltip: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
        tooltip: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.help_outline),
        label: 'About',
        tooltip: '',
      ),
    ];

    final currentIndex = GoRouter.of(context).location.let((it) {
      switch (it) {
        case '/':
          return 0;
        case '/settings':
          return 1;
        default:
          return -1;
      }
    });

    return mi.BottomNavigationBar(
      enabled: ref.watch(enableActionsProvider),
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      items: items,
      onTap: (index) {
        switch (index) {
          case 0:
            if (currentIndex != 0) {
              context.go('/');
            }
            break;
          case 1:
            if (currentIndex != 1) {
              context.push('/settings');
            }
            break;
          case 2:
            showAboutDialog(
              context: context,
              applicationName: 'Mi example',
              applicationVersion: 'Ever unstable',
              children: [
                const Text('An example for Mi boilerplates.'),
              ],
            );
            break;
        }
      },
    );
  }
}
