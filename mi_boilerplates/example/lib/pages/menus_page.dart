// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';
import 'knight_indicator.dart';

///
/// Menus example page.
///

// const _large = TextStyle(fontSize: 30);

// const _menuItems = <String, Widget>{
//   'White King': Text('\u2654', style: _large),
//   'White Queen': Text('\u2655', style: _large),
//   'White Rook': Text('\u2656', style: _large),
//   'White Bishop': Text('\u2657', style: _large),
//   'White Knight': Text('\u2658', style: _large),
//   'White Pawn': Text('\u2659', style: _large),
// };

var _tabIndex = 0;

class MenusPage extends ConsumerWidget {
  static const icon = Icon(Icons.more_vert);
  static const title = Text('Menus');

  static final _logger = Logger((MenusPage).toString());

  static const _tabs = <Widget>[
    MiTab(
      tooltip: 'Popup menu',
      icon: Icon(Icons.more_vert),
    ),
    MiTab(
      tooltip: 'Dropdown menu',
      icon: Icon(Icons.arrow_drop_down),
    ),
  ];

  const MenusPage({super.key});

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
            minimum: EdgeInsets.all(8),
            child: TabBarView(
              children: [
                _PopupMenuTab(),
                _DropdownTab(),
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
// Popup menu tab
//

const _shieldItems = <String, Widget?>{
  'None': null,
  'Shield': Icon(Icons.shield_outlined),
  'Shield+1': Icon(Icons.gpp_good_outlined),
  'Shield of Snake': Icon(Icons.monetization_on_outlined),
};

final _equippedProvider = StateProvider((ref) => List<bool>.filled(5, false));
final _shieldProvider = StateProvider<String>((ref) => 'None');

class _PopupMenuTab extends ConsumerWidget {
  static final _logger = Logger((_PopupMenuTab).toString());

  const _PopupMenuTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(enableActionsProvider);
    final equipped = ref.watch(_equippedProvider);
    final shield = ref.watch(_shieldProvider);

    final theme = Theme.of(context);

    return Column(
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: IconTheme(
                data: IconThemeData(color: theme.disabledColor),
                child: KnightIndicator(
                  equipped: equipped,
                  shieldIcon: _shieldItems[shield],
                ),
              ),
            ),
            Column(
              children: [
                // Check menu
                PopupMenuButton<int>(
                  enabled: enabled,
                  tooltip: '',
                  itemBuilder: (context) =>
                      ['Boots', 'Armour', 'Gauntlets', 'Helmet'].mapIndexed((index, key) {
                    final icon = KnightIndicator.items[key];
                    return MiCheckPopupMenuItem<int>(
                      value: index,
                      checked: equipped[index],
                      child: MiIcon(
                        icon: icon ?? const Icon(Icons.block_outlined),
                        text: Text(key),
                      ),
                    );
                  }).toList(),
                  onSelected: (index) {
                    ref.read(_equippedProvider.notifier).state =
                        equipped.replaced(index, !equipped[index]);
                  },
                  offset: const Offset(1, 0),
                  child: ListTile(
                    enabled: enabled,
                    title: const Text('Check items\nto put on.'),
                    trailing: const Icon(Icons.more_vert),
                  ),
                ),
                // Radio menu
                PopupMenuButton<String>(
                  enabled: enabled,
                  tooltip: '',
                  initialValue: shield,
                  itemBuilder: (context) {
                    return _shieldItems.entries.map((entry) {
                      return MiRadioPopupMenuItem<String>(
                        value: entry.key,
                        checked: entry.key == shield,
                        child: MiIcon(
                          icon: entry.value ?? const Icon(Icons.block_outlined),
                          text: Text(entry.key),
                        ),
                      );
                    }).toList();
                  },
                  onSelected: (key) {
                    ref.read(_shieldProvider.notifier).state = key;
                    ref.read(_equippedProvider.notifier).state =
                        equipped.replaced(4, _shieldItems[key] != null);
                  },
                  offset: const Offset(1, 0),
                  child: ListTile(
                    enabled: enabled,
                    title: const Text('Choose a\nshield to have.'),
                    trailing: const Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(),
        MiButtonListTile(
          enabled: enabled,
          icon: const Icon(Icons.refresh_outlined),
          text: const Text('Reset'),
          onPressed: () {
            ref.refresh(_equippedProvider).also((_) {});
            ref.refresh(_shieldProvider).also((_) {});
          },
        ),
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Dropdown tab
//

final _dropdownHint = Row(children: const [
  Icon(Icons.dark_mode_outlined),
  Icon(Icons.home_outlined),
]);

final _dropdownItems = <Widget>[
  Row(children: const [
    Icon(Icons.breakfast_dining_outlined),
    Icon(Icons.local_cafe_outlined),
    SizedBox(width: 8),
    Text('Breakfast'),
  ]),
  Row(children: const [
    Icon(Icons.set_meal_outlined),
    Icon(Icons.soup_kitchen_outlined),
    SizedBox(width: 8),
    Text('Lunch'),
  ]),
  Row(children: const [
    Icon(Icons.bakery_dining_outlined),
    Icon(Icons.coffee_outlined),
    SizedBox(width: 8),
    Text('Snack'),
  ]),
  Row(children: const [
    Icon(Icons.dinner_dining_outlined),
    Icon(Icons.sports_bar_outlined),
    SizedBox(width: 8),
    Text('Supper'),
  ]),
];

const _dropdownIcons = <int?, Widget>{
  null: Icon(Icons.hotel_outlined),
  0: Icon(Icons.accessibility_new_outlined),
  1: Icon(Icons.directions_run_outlined),
  2: MiScale(scaleX: -1, child: Icon(Icons.directions_run_outlined)),
  3: Icon(Icons.self_improvement_outlined),
};

final _dropdownProvider = StateProvider<int?>((ref) => null);

CancelableOperation<void>? _dropdownCancellableOperation;

class _DropdownTab extends ConsumerWidget {
  static final _logger = Logger((_DropdownTab).toString());

  const _DropdownTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(enableActionsProvider);
    final dropdown = ref.watch(_dropdownProvider);

    return Column(
      children: [
        const Text('Have a meal, and action!'),
        // Dropdown menu
        DropdownButton<int?>(
          value: dropdown,
          onChanged: enabled
              ? (index) {
                  ref.read(_dropdownProvider.notifier).state = index!;
                  _dropdownCancellableOperation?.cancel();
                  if (index == 3) {
                    _dropdownCancellableOperation = CancelableOperation<void>.fromFuture(
                      Future.delayed(const Duration(seconds: 4)),
                      onCancel: () {
                        _logger.fine('canceled.');
                      },
                    ).then(
                      (_) {
                        _logger.fine('completed.');
                        ref.read(_dropdownProvider.notifier).state = null;
                      },
                    );
                  }
                }
              : null,
          hint: _dropdownHint,
          items: _dropdownItems.mapIndexed((index, item) {
            return DropdownMenuItem<int?>(
              value: index,
              child: item,
            );
          }).toList(),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: IconTheme.merge(
            data: IconThemeData(
              size: 60,
              color: Theme.of(context).disabledColor,
            ),
            child: _dropdownIcons[dropdown]!,
          ),
        ),
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
