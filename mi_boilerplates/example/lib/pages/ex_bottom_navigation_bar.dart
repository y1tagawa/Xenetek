// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

class ExBottomNavigationBar extends ConsumerWidget {
  static final _logger = Logger((ExBottomNavigationBar).toString());

  const ExBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.help_outline),
        label: 'About',
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

    return MiBottomNavigationBar(
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
              context.go('/settings');
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
