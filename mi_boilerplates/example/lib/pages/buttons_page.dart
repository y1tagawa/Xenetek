// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

///
/// buttons example page.
///

final _tabIndexProvider = StateProvider((ref) => 0);
final _pingProvider = StateProvider((ref) => 0);

void _ping(WidgetRef ref) async {
  ref.read(_pingProvider.state).state += 1;
  await Future.delayed(
    const Duration(milliseconds: 500),
    () => ref.read(_pingProvider.state).state -= 1,
  );
}

class ButtonsPage extends ConsumerWidget {
  static const icon = Icon(Icons.dialpad_outlined);
  static const title = Text('Buttons');

  static final _logger = Logger((ButtonsPage).toString());

  static const _tabs = <Widget>[
    MiTab(
      tooltip: 'Push buttons',
      icon: Text(
        '[OK]',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    ),
    MiTab(
      tooltip: 'Menu buttons',
      icon: Icon(Icons.more_vert),
    ),
  ];

  const ButtonsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);

    // final pfbStyle = ref.watch(_persistentBottomButtonsProvider);

    final tabIndexState = ref.watch(_tabIndexProvider.state);
    final tabIndex = tabIndexState.state;

    return MiDefaultTabController(
      length: _tabs.length,
      initialIndex: tabIndex,
      onIndexChanged: (value) {
        // タブ切り替えによりFABの状態を変更するため
        tabIndexState.state = value;
      },
      builder: (context) {
        return Scaffold(
          appBar: ExAppBar(
            prominent: ref.watch(prominentProvider),
            icon: icon,
            title: title,
            actions: [
              IconButton(
                onPressed: enabled ? () => _ping(ref) : null,
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'IconButton',
              ),
            ],
            bottom: ExTabBar(
              enabled: enabled,
              tabs: _tabs,
            ),
          ),
          body: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 8),
            child: TabBarView(
              physics: enabled ? null : const NeverScrollableScrollPhysics(),
              children: const [
                _PushButtonsTab(),
                _MonospaceTab(),
              ],
            ),
          ),
          // FABはdisable禁止なので代わりに非表示にする。
          // https://material.io/design/interaction/states.html#disabled
          floatingActionButton: (enabled && tabIndex == 0)
              ? FloatingActionButton(
                  onPressed: enabled ? () => _ping(ref) : null,
                  child: const Icon(Icons.notifications_outlined),
                )
              : null,
          bottomNavigationBar: const ExBottomNavigationBar(),
        );
      },
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

///
/// TextButton, OutlinedButton, ElevatedButton, IconButton tab.
///

final _tProvider = StateProvider((ref) => false);
final _toggleProvider = StateProvider((ref) => List<bool>.filled(5, false));

class _PushButtonsTab extends ConsumerWidget {
  static final _logger = Logger((_PushButtonsTab).toString());

  const _PushButtonsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);
    final toggle = ref.watch(_toggleProvider);
    final t = ref.watch(_tProvider);

    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: TextButton(
              onPressed: enabled ? () => _ping(ref) : null,
              child: const MiIcon(
                icon: Icon(Icons.title),
                spacing: 0,
                text: Text('extButton'),
              ),
            ),
          ),
          ListTile(
            leading: TextButton.icon(
              onPressed: enabled ? () => _ping(ref) : null,
              icon: const MiIcon(
                icon: Text('TextButton.'),
                spacing: 0,
                text: Icon(Icons.info_outline),
              ),
              label: const Text('con'),
            ),
          ),
          ListTile(
            leading: OutlinedButton(
              onPressed: enabled ? () => _ping(ref) : null,
              child: const MiIcon(
                icon: Icon(Icons.center_focus_strong_outlined),
                spacing: 0,
                text: Text('utlinedButton'),
              ),
            ),
          ),
          ListTile(
            leading: ElevatedButton(
              onPressed: enabled ? () => _ping(ref) : null,
              child: const MiIcon(
                icon: Icon(
                  Icons.explicit,
                ),
                spacing: 0,
                text: Text('levatedButton'),
              ),
            ),
          ),
          ListTile(
            iconColor: theme.colorScheme.onSurface,
            leading: IconButton(
              onPressed: enabled ? () => _ping(ref) : null,
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'IconButton',
            ),
          ),
          ListTile(
            leading: ToggleButtons(
              isSelected: toggle,
              onPressed: (index) {
                ref.read(_toggleProvider.state).state = toggle.replaced(index, !toggle[index]);
              },
              children: const [
                MiIcon(
                  icon: Icon(Icons.flood_outlined),
                  tooltip: 'Flood',
                ),
                MiIcon(
                  icon: Icon(Icons.tsunami_outlined),
                  tooltip: 'Tsunami',
                ),
                MiIcon(
                  icon: Icon(Icons.tornado_outlined),
                  tooltip: 'Tornado',
                ),
                MiIcon(
                  icon: Icon(Icons.landslide_outlined),
                  tooltip: 'Landslide',
                ),
                MiIcon(
                  icon: Icon(Icons.volcano_outlined),
                  tooltip: 'Volcano',
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
              child: ref.watch(_pingProvider) > 0
                  ? Icon(
                      Icons.notifications_active_outlined,
                      size: 48,
                      color: theme.unselectedIconColor,
                    )
                  : const Icon(
                      Icons.notifications_outlined,
                      size: 48,
                      color: Colors.transparent,
                    ),
            ),
          ),
        ],
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
//
//

class _MonospaceTab extends ConsumerWidget {
  static final _logger = Logger((_MonospaceTab).toString());

  const _MonospaceTab();

  static const _data = '''
Some say the world will end in fire,
Some say in ice.
From what I’ve tasted of desire
I hold with those who favor fire.

But if it had to perish twice,
I think I know enough of hate
To say that for destruction ice
Is also great
And would suffice.

abcdefghijklmnopqrstuvwxyz
ABCDEFGHIJKLMNOPQRSTUVWXYZ
0123456789 (){}[]
+-*/= .,;:!? #&\$%@|^
  ''';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);

    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._data.split('\n').map(
                (line) => Text(
                  line,
                  softWrap: false,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Courier New',
                  ),
                ),
              ),
          const Divider(),
        ],
      ),
    );
  }
}
