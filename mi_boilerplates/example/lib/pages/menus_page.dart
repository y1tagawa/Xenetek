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

///
/// Menus example page.
///

const _large = TextStyle(fontSize: 30);

const _menuItems = <String, Widget>{
  'White King': Text('\u2654', style: _large),
  'White Queen': Text('\u2655', style: _large),
  'White Rook': Text('\u2656', style: _large),
  'White Bishop': Text('\u2657', style: _large),
  'White Knight': Text('\u2658', style: _large),
  'White Pawn': Text('\u2659', style: _large),
};

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

final _checkedKeysProvider = StateProvider<Set<String>>((ref) => {});
final _selectedKeyProvider = StateProvider<String?>((ref) => null);

class _PopupMenuTab extends ConsumerWidget {
  static final _logger = Logger((_PopupMenuTab).toString());

  const _PopupMenuTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(enableActionsProvider);
    final checkedKeys = ref.watch(_checkedKeysProvider);
    final selectedKey = ref.watch(_selectedKeyProvider);

    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // Radio menu
        PopupMenuButton<String?>(
          enabled: enabled,
          tooltip: '',
          initialValue: selectedKey,
          itemBuilder: (context) {
            return _menuItems.keys.map((key) {
              return MiRadioPopupMenuItem<String?>(
                value: key,
                checked: key == selectedKey,
                child: MiIcon(
                  icon: _menuItems[key]!,
                  text: Text(key),
                ),
              );
            }).toList();
          },
          onSelected: (key) {
            ref.read(_selectedKeyProvider.notifier).state = key;
          },
          offset: const Offset(1, 0),
          child: ListTile(
            enabled: enabled,
            trailing: const Icon(Icons.more_vert),
            title: selectedKey != null
                ? DefaultTextStyle.merge(
                    style: TextStyle(color: theme.disabledColor),
                    child: _menuItems[selectedKey]!,
                  )
                : null,
          ),
        ),

        // Check menu
        PopupMenuButton<String?>(
          enabled: enabled,
          tooltip: '',
          itemBuilder: (context) {
            return _menuItems.keys.map((key) {
              return MiCheckPopupMenuItem<String?>(
                value: key,
                checked: checkedKeys.contains(key),
                child: MiIcon(
                  icon: _menuItems[key]!,
                  text: Text(key),
                ),
              );
            }).toList();
          },
          onSelected: (key) {
            ref.read(_checkedKeysProvider.notifier).state =
                checkedKeys.contains(key!) ? checkedKeys.removed(key) : checkedKeys.added(key);
          },
          offset: const Offset(1, 0),
          child: ListTile(
            enabled: enabled,
            trailing: const Icon(Icons.more_vert),
            title: DefaultTextStyle.merge(
              style: TextStyle(color: theme.disabledColor),
              child: Wrap(
                children: _menuItems.keys
                    .where((key) => checkedKeys.contains(key))
                    .map((key) => _menuItems[key]!)
                    .toList(),
              ),
            ),
          ),
        ),

        // Toggle buttons
        ToggleButtons(
          isSelected: _menuItems.keys.map((key) => checkedKeys.contains(key)).toList(),
          onPressed: (index) {
            final key = _menuItems.keys.elementAt(index);
            ref.read(_checkedKeysProvider.notifier).state =
                checkedKeys.contains(key) ? checkedKeys.removed(key) : checkedKeys.added(key);
          },
          constraints: BoxConstraints(maxWidth: width / (_menuItems.length + 1)),
          children: _menuItems.keys.map(
            (key) {
              return _menuItems[key]!;
            },
          ).toList(),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MiTextButton(
              enabled: enabled,
              onPressed: () {
                ref.refresh(_checkedKeysProvider);
                ref.refresh(_selectedKeyProvider);
              },
              child: const MiIcon(
                icon: Icon(Icons.refresh_outlined),
                text: Text('Reset'),
              ),
            ),
          ],
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
  SizedBox(width: 8),
  Icon(Icons.more_horiz),
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
        // Dropdown menu
        DropdownButton<int?>(
          value: dropdown,
          onChanged: enabled
              ? (index) {
                  ref.read(_dropdownProvider.notifier).state = index!;
                  _dropdownCancellableOperation?.cancel();
                  if (index == 3) {
                    _dropdownCancellableOperation = CancelableOperation<void>.fromFuture(
                      Future.delayed(const Duration(seconds: 2)),
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
