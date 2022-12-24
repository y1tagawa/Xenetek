// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/data/open_moji_svgs.dart';
import 'package:example/pages/knight_indicator.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;
import 'ex_widgets.dart' as ex;

//
// Lists example page.
//

class _ListItem {
  final Widget icon;
  final String name;
  final Widget? alternativeIcon;
  final String? alternativeName;
  const _ListItem({
    required this.icon,
    required this.name,
    this.alternativeIcon,
    this.alternativeName,
  });
}

final _listItems = <_ListItem>[
  _ListItem(
    icon: mi.Scale(scaleX: -1, child: openMojiSvgRat),
    name: 'Rat',
    alternativeIcon: mi.Scale(scaleX: -1, child: openMojiSvgMouse),
    alternativeName: 'Mouse',
  ),
  _ListItem(
    icon: mi.Scale(scaleX: -1, child: openMojiSvgOx),
    name: 'Cow',
  ),
  _ListItem(
    icon: mi.Scale(scaleX: -1, child: openMojiSvgTiger),
    name: 'Tiger',
  ),
  _ListItem(
    icon: mi.Scale(scaleX: -1, child: openMojiSvgRabbit),
    name: 'Rabbit',
    alternativeIcon: mi.Scale(scaleX: -1, child: openMojiSvgHare),
    alternativeName: 'Hare',
  ),
  _ListItem(
    icon: openMojiSvgDragon,
    name: 'Dragon',
  ),
  _ListItem(
    icon: openMojiSvgSnake,
    name: 'Snake',
  ),
  _ListItem(
    icon: mi.Scale(scaleX: -1, child: openMojiSvgHorse),
    name: 'Horse',
    alternativeIcon: mi.Scale(scaleX: -1, child: openMojiSvgHorseUnicorn),
    alternativeName: 'Unicorn',
  ),
  _ListItem(
    icon: mi.Scale(scaleX: -1, child: openMojiSvgRam),
    name: 'Sheep',
  ),
  _ListItem(
    icon: mi.Scale(scaleX: -1, child: openMojiSvgMonkey),
    name: 'Monkey',
  ),
  _ListItem(
    icon: mi.Scale(scaleX: -1, child: openMojiSvgRooster),
    name: 'Chicken',
    alternativeIcon: mi.Scale(scaleX: -1, child: openMojiSvgWhiteRooster),
  ),
  _ListItem(
    icon: mi.Scale(scaleX: -1, child: openMojiSvgDog),
    name: 'Dog',
  ),
  _ListItem(
    icon: mi.Scale(scaleX: -1, child: openMojiSvgBoar),
    name: 'Boar',
    alternativeIcon: mi.Scale(scaleX: -1, child: openMojiSvgPig),
    alternativeName: 'Pig',
  ),
  _ListItem(
    icon: mi.Scale(scaleX: -1, child: openMojiSvgCat),
    name: 'Cat',
    alternativeIcon: mi.Scale(scaleX: -1, child: openMojiSvgBlackCat),
  ),
];

class ListsPage extends ConsumerWidget {
  static const icon = Icon(Icons.format_list_bulleted);
  static const title = Text('Lists');

  static final _logger = Logger((ListsPage).toString());

  static const _tabs = <Widget>[
    mi.Tab(
      tooltip: 'Reorderable list',
      icon: Icon(Icons.low_priority),
    ),
    // mi.MiTab(
    //   tooltip: 'Dismissible list',
    //   icon: Icon(Icons.segment),
    // ),
    mi.Tab(
      tooltip: 'Stepper list',
      icon: Icon(Icons.onetwothree_outlined),
    ),
  ];

  const ListsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);

    return mi.DefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
      builder: (context) {
        return Scaffold(
          appBar: ex.AppBar(
            prominent: ref.watch(ex.prominentProvider),
            icon: icon,
            title: title,
            bottom: ex.TabBar(
              enabled: enabled,
              tabs: _tabs,
            ),
          ),
          body: const SafeArea(
            minimum: EdgeInsets.all(8),
            child: TabBarView(
              children: [
                _ReorderableListTab(),
                //_DismissibleListTab(),
                _StepperTab(),
              ],
            ),
          ),
          bottomNavigationBar: const ex.BottomNavigationBar(),
        );
      },
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Reorderable list tab.
//

final _initOrder = List<int>.unmodifiable(mi.iota(_listItems.length));
final _initFlags = List<bool>.filled(_listItems.length, false);

final _orderNotifier = ValueNotifier<List<int>>(_initOrder);
final _orderProvider = ChangeNotifierProvider((ref) => _orderNotifier);
final _flagsProvider = StateProvider((ref) => _initFlags);
final _scrolledProvider = StateProvider((ref) => false);
final _selectedProvider = StateProvider<int?>((ref) => null);

final _scrollController = ScrollController();

class _ReorderableListTab extends ConsumerWidget {
  static final _logger = Logger((_ReorderableListTab).toString());

  const _ReorderableListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(ex.enableActionsProvider);
    final order = ref.watch(_orderProvider).value;
    final flags = ref.watch(_flagsProvider);
    final scrolled = ref.watch(_scrolledProvider);
    final selected = ref.watch(_selectedProvider);
    final changed = order != _initOrder || scrolled || selected != null;

    final theme = Theme.of(context);

    return Column(
      children: [
        mi.Row(
          flexes: const [1, 1],
          children: [
            ex.ResetButtonListTile(
              enabled: enabled && changed,
              onPressed: () {
                _orderNotifier.value = _initOrder;
                ref.read(_flagsProvider.notifier).state = _initFlags;
                ref.read(_selectedProvider.notifier).state = null;
                _scrollController.jumpTo(0);
              },
            ),
            mi.GridPopupMenuButton(
              tooltip: '',
              offset: const Offset(0, kToolbarHeight),
              onSelected: (index) {
                // ensureVisibleは当てにならない事があるようだ。そこでScrollControllerを使ってみる。
                // https://stackoverflow.com/questions/49153087/flutter-scrolling-to-a-widget-in-listview
                // TODO: リストビュー中央に寄せる・より確実に
                _scrollController.animateTo(
                  index * kToolbarHeight - kToolbarHeight * 0.5,
                  duration: kTabScrollDuration,
                  curve: Curves.easeInOut,
                );
                ref.read(_selectedProvider.notifier).state = index;
              },
              items: order.map((index) {
                final item = _listItems[index];
                final flag = flags[index];
                return Container(
                  width: kToolbarHeight,
                  height: kToolbarHeight,
                  alignment: Alignment.center,
                  child: flag ? item.alternativeIcon ?? item.icon : item.icon,
                );
              }).toList(),
              child: mi.ButtonListTile(
                enabled: enabled,
                icon: const Icon(Icons.more_vert),
                text: const Text('Scroll\nto'), // TODO: constrain width.
                iconPosition: TextDirection.rtl,
              ),
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: mi.ReorderableListView(
            enabled: enabled,
            scrollController: _scrollController,
            orderNotifier: _orderNotifier,
            onScroll: (controller) {
              ref.read(_scrolledProvider.notifier).state = (controller.offset != 0);
            },
            dragHandleColor: theme.unselectedIconColor,
            children: order.map(
              (index) {
                final item = _listItems[index];
                final flag = flags[index];
                // ReorderableListViewの要請により、各widgetにはListView内でユニークなキーを与える。
                final key = Key(index.toString());
                // widgetをDismissibleにすることで併用も可能なことが分かった。
                return Dismissible(
                  key: key,
                  onDismissed: (direction) {
                    _orderNotifier.value = order.removed(index);
                  },
                  background: ColoredBox(color: theme.backgroundColor),
                  child: ListTile(
                    leading: flag ? item.alternativeIcon ?? item.icon : item.icon,
                    title: Text(flag ? item.alternativeName ?? item.name : item.name),
                    selected: selected == index,
                    onTap: () {
                      ref.read(_selectedProvider.notifier).state = index;
                    },
                    onLongPress: () {
                      if (item.alternativeIcon != null) {
                        ref.read(_flagsProvider.notifier).state = flags.replaced(index, !flag);
                      }
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

//<editor-fold>

final _stepIndexProvider = StateProvider((ref) => -1);

class _StepperTab extends ConsumerWidget {
  static final _logger = Logger((_StepperTab).toString());

  const _StepperTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(ex.enableActionsProvider);
    final index = ref.watch(_stepIndexProvider);

    // TODO: Stepが開いた時にensureVisible
    final steps = <Step>[
      Step(
        title: const Text('Boots'),
        content: const mi.Label(
          icon: Text('Put the boots on.'),
          text: KnightIndicator.kBootsIcon,
        ),
        isActive: enabled,
      ),
      Step(
        title: const Text('Armour'),
        content: const mi.Label(
          icon: Text('Put the armour on.'),
          text: KnightIndicator.kArmourIcon,
        ),
        isActive: enabled && index > 0,
      ),
      Step(
        title: const Text('Gauntlets'),
        content: const mi.Label(
          icon: Text('Put the gauntlets on.'),
          text: KnightIndicator.kGauntletsIcon,
        ),
        isActive: enabled && index > 1,
      ),
      Step(
        title: const Text('Helmet'),
        content: const mi.Label(
          icon: Text('Wear the helmet.'),
          text: KnightIndicator.kHelmetIcon,
        ),
        isActive: enabled && index > 2,
      ),
      Step(
        title: const Text('Weapon'),
        content: const mi.Label(
          icon: Text('Wield the weapon.'),
          text: KnightIndicator.kWeaponIcon,
        ),
        isActive: enabled && index > 3,
      ),
      Step(
        title: const Text('Shield'),
        content: const mi.Label(
          icon: Text('Wield the shield.'),
          text: KnightIndicator.kShieldIcon,
        ),
        isActive: enabled && index > 3,
      ),
    ];

    return Column(
      children: [
        KnightIndicator(
          equipped: mi.iota(steps.length).map((i) => i < index).toList(),
        ),
        const Divider(),
        if (index < 0)
          mi.ButtonListTile(
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
          mi.ButtonListTile(
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

//</editor-fold>
