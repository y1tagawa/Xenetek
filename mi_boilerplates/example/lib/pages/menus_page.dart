// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';
import 'ex_widgets.dart';
import 'knight_indicator.dart';

///
/// Menus example page.
///

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

final _armourProvider = StateProvider((ref) => List<bool>.filled(5, false));
final _shieldProvider = StateProvider<String>((ref) => 'None');

class _PopupMenuTab extends ConsumerWidget {
  static final _logger = Logger((_PopupMenuTab).toString());

  const _PopupMenuTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(enableActionsProvider);
    final armour = ref.watch(_armourProvider);
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
                  equipped: armour,
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
                      checked: armour[index],
                      child: MiIcon(
                        icon: icon ?? const Icon(Icons.block_outlined),
                        text: Text(key),
                      ),
                    );
                  }).toList(),
                  onSelected: (index) {
                    ref.read(_armourProvider.notifier).state =
                        armour.replaced(index, !armour[index]);
                  },
                  offset: const Offset(1, 0),
                  child: ListTile(
                    enabled: enabled,
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
                    ref.read(_armourProvider.notifier).state =
                        armour.replaced(4, _shieldItems[key] != null);
                  },
                  offset: const Offset(1, 0),
                  child: ListTile(
                    enabled: enabled,
                    trailing: const Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(),
        if (armour.every((it) => it) && shield != 'None')
          ExResetButtonListTile(
            enabled: enabled,
            onPressed: () {
              ref.refresh(_armourProvider).also((_) {});
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

const _dropdownItems = <String, Widget>{
  'White King': Text('\u2654'),
  'White Queen': Text('\u2655'),
  'White Rook': Text('\u2656'),
  'White Bishop': Text('\u2657'),
  'White Knight': Text('\u2658'),
  'White Pawn': Text('\u2659'),
};

// const _dropdownItems = <Widget>[
//   MiRow(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Icon(Icons.breakfast_dining_outlined),
//       Icon(Icons.local_cafe_outlined),
//     ],
//   ),
//   MiRow(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Icon(Icons.set_meal_outlined),
//       Icon(Icons.soup_kitchen_outlined),
//     ],
//   ),
//   MiRow(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Icon(Icons.bakery_dining_outlined),
//       Icon(Icons.coffee_outlined),
//     ],
//   ),
//   MiRow(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Icon(Icons.dinner_dining_outlined),
//       Icon(Icons.sports_bar_outlined),
//     ],
//   ),
// ];

final _dropdownProvider = StateProvider<String?>((ref) => null);

class _DropdownTab extends ConsumerWidget {
  static final _logger = Logger((_DropdownTab).toString());

  const _DropdownTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(enableActionsProvider);
    final dropdown = ref.watch(_dropdownProvider);

    final theme = Theme.of(context);

    return Column(
      children: [
        DropdownButton<String?>(
          value: dropdown,
          onChanged: enabled
              ? (key) {
                  ref.read(_dropdownProvider.notifier).state = key!;
                  // _dropdownCancellableOperation?.cancel();
                  // _dropdownCancellableOperation = CancelableOperation<void>.fromFuture(
                  //   Future.delayed(const Duration(seconds: 4)),
                  //   onCancel: () {
                  //     _logger.fine('canceled.');
                  //   },
                  // ).then(
                  //   (_) {
                  //     _logger.fine('completed.');
                  //     ref.read(_dropdownProvider.notifier).state = null;
                  //   },
                  // );
                }
              : null,
          items: _dropdownItems.entries
              .map(
                (item) => DropdownMenuItem<String?>(
                  value: item.key,
                  child: MiIcon(
                    icon: DefaultTextStyle.merge(
                      style: const TextStyle(fontSize: 27),
                      child: item.value,
                    ),
                    text: Text(item.key),
                  ),
                ),
              )
              .toList(),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.shield_outlined,
                  size: 60,
                  color: theme.disabledColor,
                ),
              ),
              if (dropdown != null)
                DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: theme.disabledColor,
                  ),
                  child: Transform.translate(
                    offset: const Offset(0, 6),
                    child: Center(child: _dropdownItems[dropdown]!),
                  ),
                ),
            ],
          ),
        ),
        if (dropdown != null)
          ExResetButtonListTile(
            enabled: enabled,
            onPressed: () {
              ref.refresh(_dropdownProvider).also((_) {});
            },
          ),
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
