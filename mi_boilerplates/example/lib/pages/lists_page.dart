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

final _listItems = <String, Widget>{
  // 'Lion': SizedBox.square(dimension: 24, child: openMojiSvg1f981),
  // 'Tiger': openMojiSvg1f42f,
  // 'Dragon': openMojiSvg1f409,
  // 'Unicorn': openMojiSvg1f984,
  'Sun': const Icon(Icons.light_mode_outlined),
  'Moon': const Icon(Icons.dark_mode_outlined),
  'Earth': const Icon(Icons.landscape_outlined),
  'Water': const Icon(Icons.water_drop_outlined),
  'Phlogiston': const Icon(Icons.local_fire_department_outlined),
  'Air': const Icon(Icons.air),
  'Thunder': const Icon(Icons.trending_down_outlined),
  'Cold': const Icon(Icons.ac_unit_outlined),
  'Caloric': const Icon(Icons.hot_tub_outlined),
  'Alchemy': const Icon(Icons.science_outlined),
  'Weak force': const Icon(Icons.filter_vintage_outlined),
  'Sorcery': const Icon(Icons.all_inclusive_outlined),
  'Rune magic': const Icon(Icons.bluetooth),
  'Chaos magic': const Icon(Icons.android),
};

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

//
// ListView tab.
// TODO: AnimatedList
//

//
// Dismissible list tab.
//

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
        MiButtonListTile(
          enabled: enabled,
          icon: const Icon(Icons.refresh_outlined),
          text: const Text('Reset'),
          onPressed: () {
            ref.invalidate(_leftListProvider);
            ref.invalidate(_rightListProvider);
          },
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
                    child: ListTile(
                      leading: _listItems[key],
                      title: Text(key),
                    ),
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
                    child: ListTile(
                      leading: _listItems[key],
                      title: Text(key),
                    ),
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

//
// Reorderable list tab.
//

final _initOrder = List<String>.unmodifiable(_listItems.keys);
final _orderNotifier = ValueNotifier<List<String>>(_initOrder);
final _orderProvider = ChangeNotifierProvider((ref) => _orderNotifier);
final _selectedProvider = StateProvider<String?>((ref) => null);

final _scrollController = ScrollController();

class _ReorderableListTab extends ConsumerWidget {
  static final _logger = Logger((_ReorderableListTab).toString());

  const _ReorderableListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(enableActionsProvider);
    final order = ref.watch(_orderProvider).value;
    final selected = ref.watch(_selectedProvider);
    _logger.fine('order=$order');

    final theme = Theme.of(context);

    return Column(
      children: [
        MiRow(
          flexes: const [1, 1],
          children: [
            MiButtonListTile(
              enabled: enabled,
              icon: const Icon(Icons.refresh_outlined),
              text: const Text('Reset'),
              onPressed: () {
                _orderNotifier.value = _initOrder;
                ref.read(_selectedProvider.notifier).state = null;
              },
            ),
            MiGridPopupMenuButton(
              offset: const Offset(0, kToolbarHeight),
              onSelected: (index) {
                final key = order[index];
                // ensureVisibleは当てにならない事があるようだ。そこでScrollControllerを使ってみる。
                // https://stackoverflow.com/questions/49153087/flutter-scrolling-to-a-widget-in-listview
                // TODO: リストビュー中央に寄せる・より確実に
                _scrollController.animateTo(
                  index * kToolbarHeight - kToolbarHeight * 0.5,
                  duration: kTabScrollDuration,
                  curve: Curves.easeInOut,
                );
                ref.read(_selectedProvider.notifier).state = key;
              },
              items: order
                  .mapIndexed(
                    (index, key) => Container(
                      width: kToolbarHeight,
                      height: kToolbarHeight,
                      alignment: Alignment.center,
                      child: _listItems[key]!,
                    ),
                  )
                  .toList(),
              child: MiButtonListTile(
                enabled: enabled,
                icon: const Icon(Icons.more_vert),
                text: const Text('Scroll to'),
                iconPosition: MiIconPosition.end,
              ),
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: MiReorderableListView(
            enabled: enabled,
            scrollController: _scrollController,
            orderNotifier: _orderNotifier,
            dragHandleColor: theme.unselectedIconColor,
            children: order.mapIndexed(
              (index, key) {
                // ReorderableListViewの要請により、各widgetにはListView内でユニークなキーを与える。
                final key_ = Key(key);
                // widgetをDismissibleにすることで併用も可能なことが分かった。
                return Dismissible(
                  key: key_,
                  onDismissed: (direction) {
                    _orderNotifier.value = order.removedAt(index);
                  },
                  background: ColoredBox(color: theme.backgroundColor),
                  child: ListTile(
                    leading: _listItems[key]!,
                    title: Text(key),
                    selected: selected == key,
                    onTap: () {
                      ref.read(_selectedProvider.notifier).state = key;
                    },
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Stepper tab.
//

final _stepIndexProvider = StateProvider((ref) => -1);

class _StepperTab extends ConsumerWidget {
  static final _logger = Logger((_StepperTab).toString());

  const _StepperTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(enableActionsProvider);
    final index = ref.watch(_stepIndexProvider);

    // TODO: Stepが開いた時にensureVisible
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
          MiButtonListTile(
            enabled: enabled,
            icon: const Icon(Icons.play_arrow_outlined),
            text: const Text('Start'),
            onPressed: () {
              ref.read(_stepIndexProvider.notifier).state = 0;
            },
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
        else ...[
          MiButtonListTile(
            enabled: enabled,
            title: const Text('OK.'),
            icon: const Icon(Icons.refresh_outlined),
            text: const Text('Restart'),
            onPressed: () {
              ref.read(_stepIndexProvider.notifier).state = 0;
            },
          ),
        ]
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
