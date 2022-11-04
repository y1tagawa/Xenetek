// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

///
/// Snack bar example & toast experiment page.
///

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
              isScrollable: true,
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

///
/// Snack bar tab
///

/// [IconTheme]を設定する[SnackBar]。
///
/// マテリアルデザイン上はSnackBarにアイコンを出すの禁止ではあるのだが……
/// https://material.io/components/snackbars#anatomy
ScaffoldFeatureController _showMySnackBar({
  required BuildContext context,
  required Widget content,
  SnackBarAction? action,
  Duration duration = const Duration(milliseconds: 4000),
}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: IconTheme(
        data: IconTheme.of(context).merge(
          IconThemeData(
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        child: content,
      ),
      action: action,
      duration: duration,
    ),
  );
}

void _ping({
  required BuildContext context,
  required WidgetRef ref,
  String? content,
}) async {
//  final enableTransitionState = ref.watch(enableTransitionProvider.state);

//  enableTransitionState.state = false;
  await _showMySnackBar(
    context: context,
    action: SnackBarAction(
      label: 'CLOSE',
      onPressed: () {
        ScaffoldMessenger.of(context).clearSnackBars();
      },
    ),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.notifications_active_outlined,
        ),
        const SizedBox(width: 8),
        Text(content ?? 'Ping!'),
      ],
    ),
    duration: const Duration(milliseconds: 500),
  ); //.closed.then((_) => enableTransitionState.state = true);
}

class _SnackBarTab extends ConsumerWidget {
  static final _logger = Logger((_SnackBarTab).toString());

  const _SnackBarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    //final enabled = ref.watch(enableActionsProvider);

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
              child: const Text('Snack bar text'),
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
                    duration: const Duration(seconds: 4),
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
