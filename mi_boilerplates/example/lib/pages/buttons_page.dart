// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart';
import 'ex_widgets.dart';
import 'knight_indicator.dart';

//
// Buttons example page.
//

final _tabIndexProvider = StateProvider((ref) => 0);
final _toasterNotifier = ValueNotifier(false);

final _pingNotifier = mi.SinkNotifier<mi.AnimationControllerCallback>();

void _ping(WidgetRef ref) async {
  _pingNotifier.add((controller) {
    controller.reset();
    controller.forward();
  });
  _toasterNotifier.value = true;
}

class ButtonsPage extends ConsumerWidget {
  static const icon = Icon(Icons.dialpad_outlined);
  static const title = Text('Buttons');

  static final _logger = Logger((ButtonsPage).toString());

  static const _tabs = <Widget>[
    mi.Tab(
      tooltip: 'Push buttons',
      icon: Text(
        '[OK]',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    ),
    mi.Tab(
      tooltip: 'Dropdown button',
      icon: Icon(Icons.arrow_drop_down),
    ),
    mi.Tab(
      tooltip: 'Toggle buttons',
      icon: Icon(Icons.more_horiz),
    ),
    mi.Tab(
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

    return mi.DefaultTabController(
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
                      _ToggleButtonsTab(),
                      _MonospaceTab(),
                    ],
                  ),
                ),
                mi.PageIndicator(
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
              child: const mi.MiIcon(
                icon: Icon(Icons.title),
                spacing: 0,
                text: Text('extButton'),
              ),
            ),
          ),
          ListTile(
            leading: TextButton.icon(
              onPressed: enabled ? () => _ping(ref) : null,
              icon: const mi.MiIcon(
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
              child: const mi.MiIcon(
                icon: Icon(Icons.center_focus_strong_outlined),
                spacing: 0,
                text: Text('utlinedButton'),
              ),
            ),
          ),
          ListTile(
            leading: ElevatedButton(
              onPressed: enabled ? () => _ping(ref) : null,
              child: const mi.MiIcon(
                icon: Icon(
                  Icons.explicit,
                ),
                spacing: 0,
                text: Text('levatedButton'),
              ),
            ),
          ),
          mi.ButtonListTile(
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
              child: mi.RingBell(
                callbackNotifier: _pingNotifier,
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
              ),
            ),
          ),
          mi.Toaster(
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

//<editor-fold>

const _lightColors = <Color>[
  Colors.blue,
  Colors.cyan,
  Colors.green,
  Colors.amber,
  Colors.orange,
  Colors.red,
  Colors.purple,
];

final _darkColors = <Color>[
  Colors.blue[200]!,
  Colors.cyan[200]!,
  Colors.green[200]!,
  Colors.yellow[200]!,
  Colors.orange[200]!,
  Colors.red[200]!,
  Colors.purple[200]!,
];

class _FootPrint {
  final math.Point<double> position;
  final double angle;
  final int colorIndex;
  const _FootPrint({
    required this.position,
    required this.angle,
    required this.colorIndex,
  });
}

final _footPrintsProvider = StateProvider((ref) => <_FootPrint>[]);
final _menuIndexProvider = StateProvider<int?>((ref) => 4);

class _DropdownButtonTab extends ConsumerWidget {
  static final _logger = Logger((_DropdownButtonTab).toString());

  const _DropdownButtonTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(_lightColors.length == _darkColors.length);
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);
    final menuIndex = ref.watch(_menuIndexProvider);
    final footPrints = ref.watch(_footPrintsProvider);

    final theme = Theme.of(context);
    final colors = theme.isDark ? _darkColors : _lightColors;

    return Column(
      children: [
        mi.Row(
          flexes: const [4, 1],
          children: [
            ExClearButtonListTile(
              enabled: enabled && (footPrints.isNotEmpty || menuIndex != null),
              onPressed: () {
                ref.read(_menuIndexProvider.notifier).state = null;
                ref.read(_footPrintsProvider.notifier).state = <_FootPrint>[];
              },
            ),
            DropdownButton<int?>(
              value: menuIndex,
              hint: mi.ImageIcon(
                image: Image.asset('assets/worker_cat2.png'),
                color: enabled ? theme.unselectedIconColor : theme.disabledColor,
              ),
              onChanged: enabled
                  ? (value) {
                      ref.read(_menuIndexProvider.notifier).state = value!;
                    }
                  : null,
              items: [
                ..._lightColors.mapIndexed((index, value) {
                  return DropdownMenuItem<int?>(
                    value: index,
                    alignment: AlignmentDirectional.center,
                    child: Icon(
                      Icons.pets,
                      color: enabled ? colors[index] : theme.disabledColor,
                    ),
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
                    final color = colors[footPrint.colorIndex];
                    return Positioned(
                      left: footPrint.position.x - 12,
                      top: footPrint.position.y - 18,
                      child: Transform.rotate(
                        angle: footPrint.angle,
                        child: Icon(
                          Icons.pets,
                          color: enabled ? color : color.withAlpha(128),
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
                          colorIndex: menuIndex,
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

//</editor-fold>

//
// Toggle buttons tab.
//

//<editor-fold>

const _shieldItems = <String, Widget>{
  'Shield': Icon(Icons.shield_outlined),
  'Shield+1': Icon(Icons.gpp_good_outlined),
  'Shield of Snake': Icon(Icons.monetization_on_outlined),
};

final _armourProvider =
    StateProvider((ref) => List.filled(KnightIndicator.items.length - 1, false));
final _shieldProvider = StateProvider<int?>((ref) => null);

class _ToggleButtonsTab extends ConsumerWidget {
  static final _logger = Logger((_ToggleButtonsTab).toString());

  const _ToggleButtonsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);
    final armour = ref.watch(_armourProvider);
    final shield = ref.watch(_shieldProvider);

    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 8),
        // Armours
        ToggleButtons(
          color: theme.unselectedIconColor,
          isSelected: armour,
          onPressed: enabled
              ? (index) {
                  ref.read(_armourProvider.notifier).state = armour.replaced(index, !armour[index]);
                }
              : null,
          children: KnightIndicator.items.entries
              .take(KnightIndicator.items.length - 1)
              .mapIndexed((index, item) {
            return Tooltip(
              message: item.key,
              child: item.value,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        mi.Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shields
            ToggleButtons(
              color: theme.unselectedIconColor,
              isSelected: List.filled(_shieldItems.length, false)
                  .let((it) => shield != null ? it.replaced(shield, true) : it),
              onPressed: enabled
                  ? (index) {
                      _logger.fine('$index $shield');
                      ref.read(_shieldProvider.notifier).state = (index == shield ? null : index);
                    }
                  : null,
              children: _shieldItems.entries.mapIndexed((index, item) {
                return Tooltip(
                  message: item.key,
                  child: item.value,
                );
              }).toList(),
            ),

            // Clear button
            ToggleButtons(
              color: theme.unselectedIconColor,
              isSelected: [
                armour.any((value) => value) || shield != null,
              ],
              onPressed: enabled
                  ? (_) {
                      final _ = ref.refresh(_armourProvider.notifier);
                      ref.read(_shieldProvider.notifier).state = null;
                    }
                  : null,
              children: const [
                Tooltip(
                  message: 'Clear',
                  child: Icon(Icons.clear),
                ),
              ],
            ),
          ],
        ),
        const Divider(),
        Center(
          child: KnightIndicator(
            color: enabled ? theme.unselectedIconColor : theme.disabledColor,
            shieldIcon: shield != null ? _shieldItems.values.skip(shield).first : null,
            equipped: [
              ...armour,
              shield != null,
            ],
          ),
        )
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//</editor-fold>

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

    final theme = Theme.of(context);
    String? fontFamily;
    switch (theme.platform) {
      case TargetPlatform.windows:
        fontFamily = 'Courier New';
        break;
      case TargetPlatform.android:
        // デフォルトでは入ってないみたい
        fontFamily = 'Roboto Mono';
        break;
      default:
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ..._data.split('\n').map(
                (line) => Text(
                  line,
                  softWrap: true,
                  maxLines: 3,
                  style: TextStyle(
                    color: theme.isDark ? theme.unselectedIconColor : null,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
          const Divider(),
        ],
      ),
    );
  }
}
