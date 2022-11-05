// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

///
/// Lists example page.
///

const _listItems = <String, Icon>{
  'Sun': Icon(Icons.light_mode_outlined),
  'Moon': Icon(Icons.dark_mode_outlined),
  'Earth': Icon(Icons.landscape_outlined),
  'Water': Icon(Icons.water_drop_outlined),
  'Fire': Icon(Icons.local_fire_department_outlined),
  'Air': Icon(Icons.air),
  'Thunder': Icon(Icons.trending_down_outlined),
  'Cold': Icon(Icons.ac_unit_outlined),
  'Alchemy': Icon(Icons.science_outlined),
  'Sorcery': Icon(Icons.all_inclusive_outlined),
  'Rune magic': Icon(Icons.bluetooth),
  'Chaos magic': Icon(Icons.android),
};

class _ListTile extends ConsumerWidget {
  final String _key;
  const _ListTile(this._key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: _listItems[_key],
      title: Text(_key),
    );
  }
}

class ListsPage extends ConsumerWidget {
  static const icon = Icon(Icons.list);
  static const title = Text('Lists');

  static final _logger = Logger((ListsPage).toString());

  static const _tabs = <Widget>[
    MiTab(
      tooltip: 'Dismissible list',
      icon: Icon(Icons.segment),
    ),
    MiTab(
      tooltip: 'Reorderable list',
      icon: Icon(Icons.low_priority),
    ),
  ];

  const ListsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);

    return MiDefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
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
                _DismissibleListTab(),
                _ReorderableListTab(),
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
/// ListView tab.
/// TODO: AnimatedList
///

///
/// Dismissible list tab.
///

final _leftListProvider =
    StateProvider((ref) => _listItems.keys.whereIndexed((index, key) => index % 2 == 0).toList());
final _rightListProvider =
    StateProvider((ref) => _listItems.keys.whereIndexed((index, key) => index % 2 == 1).toList());

class _DismissibleListTab extends ConsumerWidget {
  static final _logger = Logger((_DismissibleListTab).toString());

  const _DismissibleListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(enableActionsProvider);

    final theme = Theme.of(context);

    void move(
      StateProvider<List<String>> fromProvider,
      int index,
      StateProvider<List<String>> toProvider,
    ) {
      final from = ref.read(fromProvider.state);
      final to = ref.read(toProvider.state);
      final value = from.state[index];
      from.state = from.state.removedAt(index);
      to.state = to.state.added(value);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MiTextButton(
              enabled: enabled,
              onPressed: () {
                ref.refresh(_leftListProvider);
                ref.refresh(_rightListProvider);
              },
              child: const MiIcon(
                icon: Icon(Icons.refresh_outlined),
                text: Text('Reset'),
              ),
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: MiRow(
            flexes: const [1, 0, 1],
            children: [
              ListView(
                children: ref.watch(_leftListProvider).mapIndexed((index, key) {
                  return Dismissible(
                    key: Key(key),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (_) {
                      move(_leftListProvider, index, _rightListProvider);
                    },
                    background: ColoredBox(color: theme.backgroundColor),
                    child: _ListTile(key),
                  );
                }).toList(),
              ),
              const VerticalDivider(),
              ListView(
                children: ref.watch(_rightListProvider).mapIndexed((index, key) {
                  return Dismissible(
                    key: Key(key),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) async {
                      move(_rightListProvider, index, _leftListProvider);
                    },
                    background: ColoredBox(color: theme.backgroundColor),
                    child: _ListTile(key),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

///
/// Reorderable list tab.
///

final _orderNotifier = ValueNotifier<List<String>>(List.unmodifiable(_listItems.keys));

class _ReorderableListTab extends ConsumerWidget {
  static final _logger = Logger((_ReorderableListTab).toString());

  const _ReorderableListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(enableActionsProvider);

    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MiTextButton(
              enabled: enabled,
              onPressed: () {
                _orderNotifier.value = List.unmodifiable(_listItems.keys);
              },
              child: const MiIcon(
                icon: Icon(Icons.refresh_outlined),
                text: Text('Reset'),
              ),
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: MiReorderableListView(
            enabled: enabled,
            notifier: _orderNotifier,
            dragHandleColor: theme.unselectedIconColor,
            itemBuilder: (context, index) {
              // ReorderableListViewの要請により、各widgetにはリスト内でユニークなキーを与える。
              final key = _orderNotifier.value[index];
              // widgetをDismissibleにすることで併用も可能。
              return Dismissible(
                key: Key(key),
                onDismissed: (direction) {
                  _orderNotifier.value = _orderNotifier.value.removedAt(index);
                },
                background: ColoredBox(color: theme.backgroundColor),
                child: _ListTile(key),
              );
            },
          ),
        ),
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
