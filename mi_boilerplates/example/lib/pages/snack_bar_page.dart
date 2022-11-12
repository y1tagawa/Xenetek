// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

//
// Snack bar example & toast experiment page.
//

var _tabIndex = 0;

class SnackBarPage extends ConsumerWidget {
  static const icon = Icon(Icons.notifications_outlined);
  static const title = Text('Snack bar');

  static final _logger = Logger((SnackBarPage).toString());

  static const _tabs = <Widget>[
    MiTab(
      tooltip: 'Snack bar',
      icon: Icon(Icons.notifications_outlined),
    ),
    MiTab(
      tooltip: 'Toast',
      icon: Icon(Icons.breakfast_dining_outlined),
    ),
  ];

  const SnackBarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);

    return MiDefaultTabController(
      length: _tabs.length,
      initialIndex: _tabIndex,
      builder: (context) {
        return Scaffold(
          appBar: ExAppBar(
            prominent: ref.watch(prominentProvider),
            icon: icon,
            title: title,
            bottom: ExTabBar(
              enabled: enabled,
              tabs: _tabs,
            ),
          ),
          body: const SafeArea(
            minimum: EdgeInsets.symmetric(horizontal: 8),
            child: TabBarView(
              children: [
                _SnackBarTab(),
                _SnackBarTab(),
              ],
            ),
          ),
          bottomNavigationBar: const ExBottomNavigationBar(),
        );
      },
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Snack bar tab
//

class _SnackBarTab extends ConsumerWidget {
  static final _logger = Logger((_SnackBarTab).toString());

  const _SnackBarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(enableActionsProvider);

    final theme = Theme.of(context);
    // https://github.com/flutter/flutter/blob/55e8cd1786211af87a7c660292c8f449c6072924/packages/flutter/lib/src/material/snack_bar.dart#L446
    final actionTextColor = theme.snackBarTheme.actionTextColor ??
        (theme.isDark ? theme.colorScheme.primary : theme.colorScheme.secondary);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SnackBarエミュレーション
          ListTile(
            // https://github.com/flutter/flutter/blob/55e8cd1786211af87a7c660292c8f449c6072924/packages/flutter/lib/src/material/snack_bar.dart#L235
            // https://github.com/flutter/flutter/blob/55e8cd1786211af87a7c660292c8f449c6072924/packages/flutter/lib/src/material/snack_bar.dart#L451
            tileColor: theme.snackBarTheme.backgroundColor ??
                (theme.isDark
                    ? theme.colorScheme.onSurface
                    : Color.alphaBlend(
                        theme.colorScheme.onSurface.withOpacity(0.80), theme.colorScheme.surface)),
            leading: DefaultTextStyle(
              style: theme.snackBarTheme.contentTextStyle ??
                  theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.surface) ??
                  TextStyle(color: theme.colorScheme.surface),
              child: const Text('Snack bar emulation'),
            ),
            trailing: DefaultTextStyle(
              style: theme.snackBarTheme.contentTextStyle?.copyWith(color: actionTextColor) ??
                  theme.textTheme.titleMedium?.copyWith(color: actionTextColor) ??
                  TextStyle(color: actionTextColor),
              child: const Text('ACTION'),
            ),
          ),
          // SnackBar表示
          ListTile(
            leading: MiTextButton(
              enabled: enabled,
              child: const MiIcon(
                icon: Icon(Icons.notifications_outlined),
                text: Text('Ping'),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Ping'),
                    action: SnackBarAction(
                      label: 'CLOSE',
                      onPressed: () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
