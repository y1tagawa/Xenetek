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

final _listItems = <String, Widget>{
  'Rat': mi.Scale(scaleX: -1, child: openMojiSvgRat),
  'Cow': mi.Scale(scaleX: -1, child: openMojiSvgOx),
  'Tiger': mi.Scale(scaleX: -1, child: openMojiSvgTiger),
  'Rabbit': mi.Scale(scaleX: -1, child: openMojiSvgRabbit),
  'Dragon': openMojiSvgDragon,
  'Snake': openMojiSvgSnake,
  'Horse': mi.Scale(scaleX: -1, child: openMojiSvgHorse),
  'Sheep': mi.Scale(scaleX: -1, child: openMojiSvgRam),
  'Monkey': mi.Scale(scaleX: -1, child: openMojiSvgMonkey),
  'Chicken': mi.Scale(scaleX: -1, child: openMojiSvgRooster),
  'Dog': mi.Scale(scaleX: -1, child: openMojiSvgDog),
  'Boar': mi.Scale(scaleX: -1, child: openMojiSvgBoar),
  'Cat': mi.Scale(scaleX: -1, child: openMojiSvgCat),
  //
  'Cat ': mi.Scale(scaleX: -1, child: openMojiSvgBlackCat),
  'Bat': mi.Scale(scaleX: -1, child: openMojiSvgBat),
  'Mouse': mi.Scale(scaleX: -1, child: openMojiSvgMouse),
  'Hare': mi.Scale(scaleX: -1, child: openMojiSvgHare),
  'Unicorn': mi.Scale(scaleX: -1, child: openMojiSvgHorseUnicorn),
  'Pegasus': mi.Scale(scaleX: -1, child: openMojiSvgPegasus),
  'Seahorse': mi.Scale(scaleX: -1, child: openMojiSvgSeaHorse),
  'Chicken ': mi.Scale(scaleX: -1, child: openMojiSvgWhiteRooster),
  'Pig': mi.Scale(scaleX: -1, child: openMojiSvgPig),
}.entries.toList();

class ListsPage extends ConsumerWidget {
  static const icon = Icon(Icons.format_list_bulleted);
  static const title = Text('Lists');

  static final _logger = Logger((ListsPage).toString());

  static const _tabs = <Widget>[
    mi.Tab(
      tooltip: 'Reorderable list',
      icon: Icon(Icons.low_priority),
    ),
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

final _initOrder = List<int>.unmodifiable(mi.iota(13));
final _orderNotifier = ValueNotifier<List<int>>(_initOrder);
final _orderProvider = ChangeNotifierProvider((ref) => _orderNotifier);
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
    final scrolled = ref.watch(_scrolledProvider);
    final selected = ref.watch(_selectedProvider);
    final changed = order != _initOrder || scrolled || selected != null;

    final theme = Theme.of(context);

    void replace(index, key) {
      final i = order.indexOf(index);
      assert(i >= 0);
      final ii = _listItems.indexWhere((item) => item.key == key);
      assert(ii >= 0);
      _logger.fine('replace $i $ii');
      _orderNotifier.value = order.replacedAt(i, ii);
    }

    return Column(
      children: [
        mi.Row(
          flexes: const [1, 1],
          children: [
            ex.ResetButtonListTile(
              enabled: enabled && changed,
              onPressed: () {
                _orderNotifier.value = _initOrder;
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
                return Container(
                  width: kToolbarHeight,
                  height: kToolbarHeight,
                  alignment: Alignment.center,
                  child: item.value,
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
                    leading: item.value,
                    title: Text(item.key),
                    selected: selected == index,
                    onTap: () {
                      ref.read(_selectedProvider.notifier).state = index;
                    },
                    onLongPress: () {
                      switch (item.key) {
                        case 'Rat':
                          replace(index, 'Bat');
                          break;
                        case 'Bat':
                          replace(index, 'Mouse');
                          break;
                        case 'Mouse':
                          replace(index, 'Rat');
                          break;

                        case 'Rabbit':
                          replace(index, 'Hare');
                          break;
                        case 'Hare':
                          replace(index, 'Rabbit');
                          break;

                        case 'Horse':
                          replace(index, 'Pegasus');
                          break;
                        case 'Pegasus':
                          replace(index, 'Seahorse');
                          break;
                        case 'Seahorse':
                          replace(index, 'Unicorn');
                          break;
                        case 'Unicorn':
                          replace(index, 'Horse');
                          break;

                        case 'Chicken':
                          replace(index, 'Chicken ');
                          break;
                        case 'Chicken ':
                          replace(index, 'Chicken');
                          break;

                        case 'Boar':
                          replace(index, 'Pig');
                          break;
                        case 'Pig':
                          replace(index, 'Boar');
                          break;

                        case 'Cat':
                          replace(index, 'Cat ');
                          break;
                        case 'Cat ':
                          replace(index, 'Cat');
                          break;
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
