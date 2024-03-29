// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audioplayers/audioplayers.dart';
import 'package:example/data/open_moji_svgs.dart';
import 'package:example/pages/knight_indicator.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:lottie/lottie.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;
import 'ex_widgets.dart' as ex;

//
// Lists example page.
//

class _Icon extends StatelessWidget {
  final double scaleX;
  final double scaleY;
  final Widget child;
  const _Icon({this.scaleX = 1.0, this.scaleY = 1.0, required this.child});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: mi.Scale(scaleX: scaleX, scaleY: scaleY, child: child),
    );
  }
}

const _threeWiseMonkeys = '\u{1F648}\u{1F64A}\u{1F649}';

final _listItems = <String, Widget>{
  'Rat': _Icon(scaleX: -0.7, scaleY: 0.7, child: openMojiSvgWhiteRat),
  'Cow': _Icon(scaleX: -1, child: openMojiSvgOx),
  'Tiger': _Icon(scaleX: -1, child: openMojiSvgTiger),
  'Rabbit': _Icon(scaleX: -0.7, scaleY: 0.7, child: openMojiSvgWhiteRabbit),
  'Dragon': _Icon(child: openMojiSvgDragon),
  'Snake': _Icon(scaleX: 0.7, scaleY: 0.7, child: openMojiSvgSnake),
  'Horse': _Icon(scaleX: -1, child: openMojiSvgHorse),
  'Sheep': _Icon(scaleX: -1, child: openMojiSvgRam),
  'Monkey': _Icon(scaleX: -1, child: openMojiSvgMonkey),
  'Chicken': _Icon(scaleX: -1, child: openMojiSvgWhiteRooster),
  'Dog': _Icon(scaleX: -1, child: openMojiSvgDog),
  'Boar': _Icon(scaleX: -1, child: openMojiSvgBoar),
  'Cat': _Icon(scaleX: -1, child: openMojiSvgCat),
  //
  'Bat': _Icon(scaleX: -0.7, scaleY: 0.7, child: openMojiSvgBat),
  'Mouse': _Icon(scaleX: -1, child: openMojiSvgMouse),
  'Rat ': _Icon(scaleX: -1, child: openMojiSvgRat),
  'Hare': _Icon(scaleX: -1, child: openMojiSvgHare),
  'Snake ': _Icon(
    scaleX: 0.7,
    scaleY: 0.7,
    child: Image.asset('assets/snake.webp', width: 72, height: 72),
  ),
  'Dark horse': _Icon(scaleX: -1, child: openMojiSvgDarkHorse),
  'Invisible pink unicorn': _Icon(scaleX: -1, child: openMojiSvgInvisiblePinkUnicorn),
  'Pegasus': _Icon(scaleX: -1, child: openMojiSvgPegasus),
  'Sea horse': _Icon(scaleX: -1, child: openMojiSvgSeaHorse),
  'Unicorn': _Icon(scaleX: -1, child: openMojiSvgHorseUnicorn),
  'Goat': _Icon(scaleX: -1, child: openMojiSvgGoat),
  _threeWiseMonkeys: _Icon(scaleX: -1, child: openMojiSvgMonkey),
  'Egg': SizedBox(
    width: 72,
    height: 72,
    child: mi.Translate(
      offset: const Offset(0, 5),
      child: mi.Scale(scale: 0.5, child: openMojiSvgEgg),
    ),
  ),
  'Pig': _Icon(scaleX: -1, child: openMojiSvgPig),
  'Cat ': _Icon(scaleX: -1, child: Image.asset('assets/worker_cat1.png')),
};

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
        return ex.Scaffold(
          appBar: ex.AppBar(
            prominent: ref.watch(ex.prominentProvider),
            icon: icon,
            title: title,
            bottom: ex.TabBar(
              enabled: enabled,
              tabs: _tabs,
            ),
          ),
          body: const TabBarView(
            children: [
              _ReorderableListTab(),
              //_DismissibleListTab(),
              _StepperTab(),
            ],
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
final _ghostScriptTigerProvider = StateProvider((ref) => false);
final _greenDragonProvider = StateProvider((ref) => false);

final _scrollController = ScrollController();
final _player = AudioPlayer()..setReleaseMode(ReleaseMode.release);

class _ReorderableListTab extends ConsumerWidget {
  static final _logger = Logger((_ReorderableListTab).toString());

  static final _items = _listItems.entries.toList();
  // Long pressで起こす置換イベント
  static final _replaceList = <String, String>{
    'Rat': 'Bat',
    'Bat': 'Rat',
    'Rabbit': 'Hare',
    'Hare': 'Rabbit',
    'Snake': 'Snake ',
    'Snake ': 'Snake',
    'Sheep': 'Goat',
    'Goat': 'Sheep',
    'Monkey': _threeWiseMonkeys,
    _threeWiseMonkeys: 'Monkey',
    'Chicken': 'Egg',
    'Egg': 'Chicken',
    'Boar': 'Pig',
    'Pig': 'Boar',
    'Cat': 'Cat ',
    'Cat ': 'Cat',
  };
  // 馬s
  static const _horses = <String>{
    'Horse',
    'Dark horse',
    'Pegasus',
    'Sea horse',
    'Unicorn',
    'Invisible pink unicorn',
  };
  static final _horsePopupMenuItems =
      _horses.map((it) => PopupMenuItem<String>(value: it, child: Text(it))).toList();

  const _ReorderableListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final enabled = ref.watch(ex.enableActionsProvider);
    final order = ref.watch(_orderProvider).value;
    final scrolled = ref.watch(_scrolledProvider);
    final selected = ref.watch(_selectedProvider);
    final changed = order != _initOrder || scrolled || selected != null;
    final ghostScriptTiger = ref.watch(_ghostScriptTigerProvider);
    final greenDragon = ref.watch(_greenDragonProvider);

    final theme = Theme.of(context);

    void play(String url) async {
      if (_player.state == PlayerState.playing) {
        await _player.stop();
        await _player.release();
      }
      try {
        await _player.play(UrlSource(url));
      } catch (e) {
        _logger.info('caught exception: $e');
        rethrow;
      }
    }

    void replace(int i, int j) {
      assert(i >= 0);
      assert(j >= 0);
      _orderNotifier.value = order.replacedAt(i, j);
    }

    void action(int index) async {
      final item = _items[index];
      // 置換リストにあったら置換
      _replaceList[item.key]?.let((value) {
        replace(order.indexOf(index), _items.indexWhere((it) => it.key == value));
        // TODO: 一般化
        if (item.key == 'Snake') {
          Future.delayed(const Duration(milliseconds: 3000), () {
            final order_ = ref.watch(_orderProvider).value;
            final i = order_.indexWhere((it) => _items[it].key == 'Snake ');
            if (i >= 0) {
              final ii = _items.indexWhere((it) => it.key == 'Snake');
              _orderNotifier.value = order_.replacedAt(i, ii);
            }
          });
        }
        return;
      });
      // 他のアクション
      switch (item.key) {
        case 'Cow':
          play('https://upload.wikimedia.org/wikipedia/commons/4/48/Mudchute_cow_1.ogg');
          break;
        case 'Tiger':
          if (!ghostScriptTiger) {
            ref.read(_ghostScriptTigerProvider.notifier).state = true;
            Future.delayed(const Duration(milliseconds: 1200), () {
              ref.read(_ghostScriptTigerProvider.notifier).state = false;
            });
          }
          break;
        case 'Dragon':
          if (!greenDragon) {
            ref.read(_greenDragonProvider.notifier).state = true;
            Future.delayed(const Duration(milliseconds: 2400), () {
              ref.read(_greenDragonProvider.notifier).state = false;
            });
          }
          break;
        case 'Dog':
          play('https://upload.wikimedia.org/wikipedia/commons/a/a2/Barking_of_a_dog.ogg');
          break;
      }
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
                final item = _items[index];
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
          child: Stack(
            children: [
              mi.ReorderableListView(
                enabled: enabled,
                scrollController: _scrollController,
                orderNotifier: _orderNotifier,
                onScroll: (controller) {
                  ref.read(_scrolledProvider.notifier).state = (controller.offset != 0);
                },
                dragHandleColor: theme.unselectedIconColor,
                children: order.map(
                  (index) {
                    final item = _items[index];
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
                        leading: _horses.contains(item.key)
                            ? PopupMenuButton<String>(
                                tooltip: '',
                                itemBuilder: (_) => _horsePopupMenuItems,
                                onSelected: (value) {
                                  replace(
                                    order.indexOf(index),
                                    _items.indexWhere((it) => it.key == value),
                                  );
                                },
                                child: item.value,
                              )
                            : InkWell(
                                onTap: () {
                                  action(index);
                                },
                                child: item.value,
                              ),
                        title: item.key == _threeWiseMonkeys
                            ? Text(item.key, style: const TextStyle(fontSize: 24))
                            : Text(item.key),
                        selected: selected == index,
                        onTap: () {
                          ref.read(_selectedProvider.notifier).state = index;
                        },
                      ),
                    );
                  },
                ).toList(),
              ),
              Visibility(
                visible: greenDragon,
                child: SizedBox.expand(
                  child: Lottie.asset(
                    'assets/lottie/green_dragon.json',
                    fit: BoxFit.contain,
                    repeat: false,
                  ),
                ),
              ),
              Visibility(
                visible: ghostScriptTiger,
                child: SizedBox.expand(
                  child: Lottie.asset(
                    'assets/lottie/ghost_script_tiger.json',
                    fit: BoxFit.contain,
                    repeat: false,
                  ),
                ),
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
