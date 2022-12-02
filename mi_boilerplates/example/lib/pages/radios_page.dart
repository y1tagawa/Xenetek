// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:lottie/lottie.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

class RadiosPage extends ConsumerWidget {
  static const icon = Icon(Icons.radio_button_checked_outlined);
  static const title = Text('Radios');

  static final _logger = Logger((RadiosPage).toString());

  static final _tabs = <Widget>[
    const MiTab(
      tooltip: 'Radios',
      icon: icon,
    ),
    MiTab(
      tooltip: 'Toggle buttons',
      icon: MiImageIcon(
        image: Image.asset('assets/more_grid.png'),
      ),
    ),
  ];

  const RadiosPage({super.key});

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
                _RadiosTab(),
                _ToggleButtonsTab(),
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
// Radios tab
//

class Fade extends StatelessWidget {
  static final _logger = Logger((Fade).toString());

  final double startOpacity;
  final double finalOpacity;
  final Widget child;
  const Fade({
    super.key,
    required this.startOpacity,
    required this.finalOpacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MiAnimationController(
      onInitialized: (controller) {
        controller.reset();
        controller.forward();
      },
      builder: (_, controller, __) {
        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            _logger.fine(controller.value);
            return Opacity(
              opacity: (finalOpacity - startOpacity) * controller.value + startOpacity,
              child: child,
            );
          },
        );
      },
    );
  }
}

enum _Class { fighter, cleric, mage, thief }

class _RadioItem {
  final Widget Function(bool checked) iconBuilder;
  final Widget text;
  const _RadioItem({required this.iconBuilder, required this.text});
}

final _radioItems = <_Class, _RadioItem>{
  _Class.fighter: _RadioItem(
    iconBuilder: (checked) => const Icon(Icons.shield_outlined),
    text: const Text('Fighter'),
  ),
  _Class.cleric: _RadioItem(
    iconBuilder: (checked) => const Icon(Icons.emergency_outlined),
    text: const Text('Cleric'),
  ),
  _Class.mage: _RadioItem(
    //iconBuilder: (_) => const Icon(Icons.auto_fix_normal_outlined),
    iconBuilder: (_) => MiImageIcon(
      image: Image.asset('assets/mage_hat.png'),
    ),
    text: const Text('Mage'),
  ),
  _Class.thief: _RadioItem(
    iconBuilder: (checked) => MiToggleIcon(
      checked: checked,
      checkIcon: const Icon(Icons.lock_open),
      uncheckIcon: const Icon(Icons.lock_outlined),
    ),
    text: const Text('Thief'),
  ),
};

final _radioIndexProvider = StateProvider((ref) => _Class.fighter);

Widget? _icon1;
Widget? _icon2;
int _id = 0;

class _RadiosTab extends ConsumerWidget {
  // ignore: unused_field
  static final _logger = Logger((_RadiosTab).toString());

  const _RadiosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final radioIndex = ref.watch(_radioIndexProvider);

    return Column(
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: _radioItems.keys.map(
              (key) {
                final item = _radioItems[key]!;
                return MiRadioListTile<_Class>(
                  enabled: enableActions,
                  value: key,
                  groupValue: radioIndex,
                  title: MiIcon(
                    icon: item.iconBuilder(key == radioIndex),
                    text: item.text,
                  ),
                  onChanged: (value) {
                    _icon1 = Fade(
                      key: Key(_id.toString()),
                      startOpacity: 0.0,
                      finalOpacity: 1.0,
                      child: _radioItems[value!]!.iconBuilder(false),
                    );
                    ++_id;
                    _icon2 = Fade(
                      key: Key(_id.toString()),
                      startOpacity: 1.0,
                      finalOpacity: 0.0,
                      child: _radioItems[radioIndex]!.iconBuilder(false),
                    );
                    ++_id;
                    ref.read(_radioIndexProvider.notifier).state = value!;
                  },
                );
              },
            ).toList(),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: IconTheme(
            data: IconThemeData(
              color: Theme.of(context).disabledColor,
              size: 60,
            ),
            child: Stack(
              children: [
                if (_icon1 != null) _icon1!,
                if (_icon2 != null) _icon2!,
              ],
            ),
            //child: _radioItems[radioIndex]!.iconBuilder(false),
          ),
        ),
      ],
    );
  }
}

//
// Toggle buttons tab
//

// https://lottiefiles.com/301-search-location
const _rippleLottieUrl =
    'https://assets7.lottiefiles.com/datafiles/bef3daa39adedbe065d5efad0ae5ccb3/search.json';
// https://lottiefiles.com/94-soda-loader
const _sodaLottieUrl = 'https://assets1.lottiefiles.com/datafiles/cFpiJtSizfCSZyW/data.json';

const _toggleItems = <Widget>[
  Text('Soda'),
  Text('Mint'),
  Text('Lemon'),
  Text('Orange'),
  Text('Straw\nberry'),
  Text('Grape'),
  Text('Milk'),
  Text('Cola'),
];

const _toggleItemColors = <Color>[
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.red,
  Colors.purple,
  Color(0xFFEEEEEE),
  Colors.brown,
];

final _toggleIndexProvider = StateProvider((ref) => 0);

class _ToggleButtonsTab extends ConsumerWidget {
  static final _logger = Logger((_toggleIndexProvider).toString());

  const _ToggleButtonsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final toggleIndex = ref.watch(_toggleIndexProvider);

    return MiDefaultTabController(
      length: _toggleItems.length,
      initialIndex: toggleIndex,
      builder: (context) {
        return Column(
          children: [
            MiRadioToggleButtons(
              enabled: enableActions,
              initiallySelected: toggleIndex,
              split: MediaQuery.of(context).orientation == Orientation.landscape ? null : 3,
              renderBorder: false,
              onPressed: (index) {
                ref.read(_toggleIndexProvider.notifier).state = index;
                DefaultTabController.of(context)?.index = index;
              },
              children: _toggleItems,
            ),
            const Divider(),
            Expanded(
              child: TabBarView(
                children: _toggleItemColors.mapIndexed(
                  (index, color) {
                    final url = index == 6 ? _rippleLottieUrl : _sodaLottieUrl;
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(1),
                        child: ColoredBox(
                          color: color.withAlpha(128),
                          child: MiAnimationController(
                            builder: (_, controller, __) {
                              return Lottie.network(
                                url,
                                controller: controller,
                                repeat: true,
                                onLoaded: (composition) {
                                  _logger.fine('onLoaded: ${composition.duration}');
                                  controller.duration = composition.duration;
                                  controller.reset();
                                  controller.forward();
                                },
                              );
                            },
                            onCompleted: (controller) {
                              controller.reset();
                              controller.forward();
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
