// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';
import 'ex_widgets.dart';

//
// Buttons example page.
//

final _tabIndexProvider = StateProvider((ref) => 0);
final _toasterNotifier = ValueNotifier(false);

AnimationController? _pingController;

void _ping(WidgetRef ref) async {
  _pingController?.reset();
  _pingController?.forward();

  _toasterNotifier.value = true;
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
      tooltip: 'Dropdown button',
      icon: Icon(Icons.arrow_drop_down),
    ),
    MiTab(
      tooltip: UnderConstruction.title,
      icon: UnderConstruction.icon,
    ),
  ];

  const ButtonsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);

    final tabIndex = ref.watch(_tabIndexProvider);

    return MiDefaultTabController(
      length: _tabs.length,
      initialIndex: tabIndex,
      onIndexChanged: (value) {
        // タブ切り替えによりFABの状態を変更するため
        ref.read(_tabIndexProvider.notifier).state = value;
      },
      builder: (context) {
        return Scaffold(
          appBar: ExAppBar(
            prominent: ref.watch(prominentProvider),
            icon: icon,
            title: title,
            actions: [
              if (tabIndex == 0)
                IconButton(
                  onPressed: () => _ping(ref),
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
            child: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    physics: enabled ? null : const NeverScrollableScrollPhysics(),
                    children: const [
                      _PushButtonsTab(),
                      _DropdownButtonTab(),
                      _MonospaceTab(),
                    ],
                  ),
                ),
                MiPageIndicator(
                  index: tabIndex,
                  length: _tabs.length,
                  onSelected: (index) {
                    DefaultTabController.of(context)?.index = index;
                  },
                ),
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

//
// Push buttons tab
//

class _PushButtonsTab extends ConsumerWidget {
  static final _logger = Logger((_PushButtonsTab).toString());

  const _PushButtonsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);

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
          MiButtonListTile(
            enabled: enabled,
            alignment: MainAxisAlignment.start,
            leading: const Icon(Icons.mode_standby),
            text: const Text('ListTile'),
            onPressed: () => _ping(ref),
          ),
          ListTile(
            iconColor: theme.colorScheme.onSurface,
            leading: IconButton(
              onPressed: enabled ? () => _ping(ref) : null,
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'IconButton',
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: MiRingingIcon(
                icon: Icon(
                  Icons.notifications_outlined,
                  size: 48,
                  color: theme.disabledColor,
                ),
                ringingIcon: Icon(
                  Icons.notifications_active_outlined,
                  size: 48,
                  color: theme.disabledColor,
                ),
                origin: const Offset(0, -20),
                onInitialized: (controller) => _pingController = controller,
                onDispose: () => _pingController = null,
              ),
            ),
          ),
          MiToaster(
            visibleNotifier: _toasterNotifier,
            child: InkWell(
              onTap: () {
                _toasterNotifier.value = false;
              },
              child: const Text('Toast'),
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
// Dropdown button tab.
//

final _menuItems = <MaterialColor>[
  Colors.blue,
  Colors.cyan,
  Colors.green,
  Colors.amber,
  Colors.orange,
  Colors.red,
  Colors.purple,
];

class _FootPrint {
  final math.Point<double> position;
  final double angle;
  final MaterialColor color;
  const _FootPrint({
    required this.position,
    required this.angle,
    required this.color,
  });
}

final _footPrintsProvider = StateProvider((ref) => <_FootPrint>[]);
final _menuIndexProvider = StateProvider<int?>((ref) => 4);

class _DropdownButtonTab extends ConsumerWidget {
  static final _logger = Logger((_DropdownButtonTab).toString());

  const _DropdownButtonTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);
    final menuIndex = ref.watch(_menuIndexProvider);
    final footPrints = ref.watch(_footPrintsProvider);

    final theme = Theme.of(context);

    Color color(MaterialColor value) => theme.isDark ? value[200]! : value;

    return Column(
      children: [
        MiRow(
          flexes: const [4, 1],
          children: [
            ExClearButtonListTile(
              enabled: enabled,
              onPressed: () {
                ref.read(_menuIndexProvider.notifier).state = null;
                ref.read(_footPrintsProvider.notifier).state = <_FootPrint>[];
              },
            ),
            DropdownButton<int?>(
              value: menuIndex,
              hint: MiImageIcon(
                image: Image.asset('assets/worker_cat2.png'),
                color: enabled ? theme.unselectedIconColor : theme.disabledColor,
              ),
              onChanged: enabled
                  ? (value) {
                      ref.read(_menuIndexProvider.notifier).state = value!;
                    }
                  : null,
              items: [
                ..._menuItems.mapIndexed((index, value) {
                  return DropdownMenuItem<int?>(
                    value: index,
                    child: Icon(Icons.pets, color: enabled ? color(value) : theme.disabledColor),
                  );
                }),
              ],
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: Container(
            decoration: (menuIndex != null)
                ? BoxDecoration(
                    border: Border.all(color: theme.disabledColor),
                    color: theme.isDark ? null : const Color(0xFFEEEEEE),
                  )
                : null,
            child: Stack(
              children: [
                ...footPrints.map(
                  (footPrint) {
                    return Positioned(
                      left: footPrint.position.x - 12,
                      top: footPrint.position.y - 18,
                      child: Transform.rotate(
                        angle: footPrint.angle,
                        child: Icon(
                          Icons.pets,
                          color: enabled ? color(footPrint.color) : footPrint.color.withAlpha(128),
                        ),
                      ),
                    );
                  },
                ).toList(),
                GestureDetector(
                  onTapDown: (detail) {
                    _logger.fine(detail.localPosition);
                    if (menuIndex != null) {
                      final position = math.Point(
                        detail.localPosition.dx,
                        detail.localPosition.dy,
                      );
                      final angle = footPrints.isEmpty
                          ? 0.0
                          : (position - footPrints.last.position).let(
                              (it) => math.atan2(it.x, -it.y),
                            );
                      ref.read(_footPrintsProvider.notifier).state = [
                        ...footPrints,
                        _FootPrint(
                          position: position,
                          angle: angle,
                          color: _menuItems[menuIndex],
                        ),
                      ];
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._data.split('\n').map(
                (line) => Text(
                  line,
                  softWrap: true,
                  maxLines: 3,
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
