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
                _ToastTab(),
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
// 本来スナックバーにアイコンを載せるのはご法度であるが
// https://m2.material.io/components/snackbars
// WotWでは平気で載せている。
// https://api.flutter.dev/flutter/material/SnackBar-class.html
// しかし_SnackBarStateの派生が出来ないので、カスタムStatusBarは作成できなかったため、個別対応する。

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

    void showSnackBar() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: MiRow(
            children: [
              const Text('Ping'),
              IconTheme.merge(
                data: IconThemeData(color: theme.colorScheme.surface),
                child: MiRingingIcon(
                  origin: const Offset(0, -10),
                  onInitialized: (controller) {
                    controller.forward();
                  },
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'CLOSE',
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
            },
          ),
        ),
      );
    }

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
            leading: MiRow(
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle(
                  style: theme.snackBarTheme.contentTextStyle ??
                      theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.surface) ??
                      TextStyle(color: theme.colorScheme.surface),
                  child: const Text('Ping'),
                ),
                IconTheme.merge(
                  data: IconThemeData(color: theme.colorScheme.surface),
                  child: const Icon(Icons.notifications_outlined),
                ),
              ],
            ),
            trailing: DefaultTextStyle(
              style: theme.snackBarTheme.contentTextStyle?.copyWith(color: actionTextColor) ??
                  theme.textTheme.bodyMedium?.copyWith(color: actionTextColor) ??
                  TextStyle(color: actionTextColor),
              child: const Text('ACTION'),
            ),
            onTap: () {
              showSnackBar();
            },
          ),
          const Text('Note: Material Design demands not to use icons in snackbars.'),
        ],
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Overlay tab
//

class _ToastTab extends ConsumerWidget {
  static final _logger = Logger((_ToastTab).toString());

  const _ToastTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(enableActionsProvider);

    Future<void> showToast(BuildContext context) async {
      final overlay = Overlay.of(context);
      final theme = Theme.of(context);
      // TODO: AnimatedOpacity-ed StatefulWidget
      final toast = OverlayEntry(
        builder: (context) {
          return Align(
            alignment: const Alignment(0, 0.75),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(4),
                color: theme.colorScheme.onSurface,
              ),
              child: DefaultTextStyle(
                style: theme.textTheme.titleMedium!.merge(
                  TextStyle(color: theme.colorScheme.surface),
                ),
                child: const Text('Toast'),
              ),
            ),
          );
        },
      );
      overlay!.insert(toast);
      Future.delayed(
        const Duration(seconds: 3),
        () => toast.remove(),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          MiButtonListTile(
              enabled: enabled,
              icon: const Icon(Icons.breakfast_dining_outlined),
              text: const Text('Toast!'),
              onPressed: () async {
                await showToast(context);
              }),
        ],
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
