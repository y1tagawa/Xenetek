// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:example/pages/knight_indicator.dart';
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
      tooltip: 'Reorderable list',
      icon: Icon(Icons.low_priority),
    ),
    MiTab(
      tooltip: 'Dismissible list',
      icon: Icon(Icons.segment),
    ),
    MiTab(
      tooltip: 'Stepper list',
      icon: Icon(Icons.onetwothree_outlined),
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
                _ReorderableListTab(),
                _DismissibleListTab(),
                _StepperTab(),
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
      final from = ref.read(fromProvider).toList();
      final to = ref.read(toProvider).toList();
      to.add(from.removeAt(index));
      ref.read(fromProvider.notifier).state = from;
      ref.read(toProvider.notifier).state = to;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MiTextButton(
              enabled: enabled,
              onPressed: () {
                ref.invalidate(_leftListProvider);
                ref.invalidate(_rightListProvider);
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

final _initOrder = List<String>.unmodifiable(_listItems.keys);
final _orderNotifier = ValueNotifier<List<String>>(_initOrder);

class _ReorderableListTab extends ConsumerWidget {
  static final _logger = Logger((_ReorderableListTab).toString());

  static final _keys = <String, GlobalKey>{
    for (var key in _listItems.keys) key: GlobalKey(),
  };

  const _ReorderableListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(enableActionsProvider);
    final order = _orderNotifier.value;

    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MiTextButton(
              enabled: enabled,
              onPressed: () {
                _orderNotifier.value = _initOrder;
              },
              child: const MiIcon(
                icon: Icon(Icons.refresh_outlined),
                text: Text('Reset'),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: '',
              itemBuilder: (_) => order
                  .map(
                    (key) => PopupMenuItem<String>(
                      value: key,
                      child: _listItems[key]!,
                    ),
                  )
                  .toList(),
              onSelected: (key) {
                _keys[key]!.currentContext?.let((it) => Scrollable.ensureVisible(it));
              },
              child: const MiIcon(
                icon: Icon(Icons.more_vert),
                text: Text('Ensure visible'),
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
              // (ここではensureVisibleの関係でGlobalKeyだがKeyでも良い)
              final key = _keys[order[index]]!;
              // widgetをDismissibleにすることで併用も可能。
              return Dismissible(
                key: key,
                onDismissed: (direction) {
                  _orderNotifier.value = order.removedAt(index);
                },
                background: ColoredBox(color: theme.backgroundColor),
                child: _ListTile(_listItems.keys.toList()[index]),
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

///
/// Stepper tab.
///

final _stepIndexProvider = StateProvider((ref) => -1);

class _StepperTab extends ConsumerWidget {
  static final _logger = Logger((_StepperTab).toString());

  const _StepperTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(enableActionsProvider);
    final index = ref.watch(_stepIndexProvider);

    final steps = <Step>[
      Step(
        title: const Text('Boots'),
        content: const MiIcon(
          icon: Text('Put the boots on.'),
          text: KnightIndicator.kBootsIcon,
        ),
        isActive: enabled,
      ),
      Step(
        title: const Text('Armour'),
        content: const MiIcon(
          icon: Text('Put the armour on.'),
          text: KnightIndicator.kArmourIcon,
        ),
        isActive: enabled && index > 0,
      ),
      Step(
        title: const Text('Gauntlets'),
        content: const MiIcon(
          icon: Text('Put the gauntlets on.'),
          text: KnightIndicator.kGauntletsIcon,
        ),
        isActive: enabled && index > 1,
      ),
      Step(
        title: const Text('Helmet'),
        content: const MiIcon(
          icon: Text('Wear the helmet.'),
          text: KnightIndicator.kHelmetIcon,
        ),
        isActive: enabled && index > 2,
      ),
      Step(
        title: const Text('Shield'),
        content: const MiIcon(
          icon: Text('Have the shield.'),
          text: KnightIndicator.kShieldIcon,
        ),
        isActive: enabled && index > 3,
      ),
    ];

    return Column(
      children: [
        KnightIndicator(
          equipped: iota(steps.length).map((i) => i < index).toList(),
        ),
        const Divider(),
        if (index < 0)
          ListTile(
            title: MiTextButton(
              enabled: enabled,
              child: const MiIcon(
                icon: Icon(Icons.play_arrow_outlined),
                text: Text('Start'),
              ),
              onPressed: () {
                ref.read(_stepIndexProvider.notifier).state = 0;
              },
            ),
          )
        else if (index >= 0 && index < steps.length)
          Expanded(
            child: SingleChildScrollView(
              child: Stepper(
                steps: steps,
                currentStep: index,
                onStepContinue: enabled
                    ? () {
                        ref.read(_stepIndexProvider.notifier).state = index + 1;
                      }
                    : null,
                onStepCancel: enabled
                    ? () {
                        ref.read(_stepIndexProvider.notifier).state = index - 1;
                      }
                    : null,
                onStepTapped: enabled
                    ? (value) {
                        if (value < index) {
                          ref.read(_stepIndexProvider.notifier).state = value;
                        }
                      }
                    : null,
              ),
            ),
          )
        else
          ListTile(
            enabled: enabled,
            title: const Center(child: Text('OK.')),
            subtitle: MiTextButton(
              enabled: enabled,
              child: const MiIcon(
                icon: Icon(Icons.refresh_outlined),
                text: Text('Restart'),
              ),
              onPressed: () {
                ref.read(_stepIndexProvider.notifier).state = 0;
              },
            ),
          ),
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
