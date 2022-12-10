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
import 'ex_widgets.dart';

class RadiosPage extends ConsumerWidget {
  static const icon = Icon(Icons.radio_button_checked_outlined);
  static const title = Text('Radios');

  static final _logger = Logger((RadiosPage).toString());

  static final _tabs = <Widget>[
    const MiTab(
      tooltip: 'Radio buttons',
      icon: icon,
    ),
    const MiTab(
      tooltip: 'Radio menu',
      icon: Icon(Icons.more_vert),
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
                _RadioButtonsTab(),
                _RadioMenuTab(),
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

//<editor-fold>

final _radioItems = <String, Widget Function(bool checked)>{
  'Fighter': (_) => const Icon(Icons.shield_outlined),
  'Cleric': (_) => const Icon(Icons.emergency_outlined),
  'Mage': (_) => const Icon(Icons.auto_fix_normal_outlined),
  'Thief': (checked) => MiToggleIcon(
        checked: checked,
        checkIcon: const Icon(Icons.lock_open),
        uncheckIcon: const Icon(Icons.lock_outlined),
      ),
};

final _radioProvider = StateProvider((ref) => _radioItems.keys.first);

class _RadioButtonsTab extends ConsumerWidget {
  // ignore: unused_field
  static final _logger = Logger((_RadioButtonsTab).toString());

  const _RadioButtonsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final radioKey = ref.watch(_radioProvider);

    return Column(
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: _radioItems.entries.map(
              (item) {
                return RadioListTile<String>(
                  value: item.key,
                  groupValue: radioKey,
                  title: MiIcon(
                    icon: item.value(item.key == radioKey),
                    text: Text(item.key),
                  ),
                  onChanged: enableActions
                      ? (value) {
                          ref.read(_radioProvider.notifier).state = value!;
                        }
                      : null,
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
            child: MiFade(
              child: _radioItems[radioKey]!.call(false),
            ),
          ),
        ),
      ],
    );
  }
}

//</editor-fold>

//
// Radio menu tab
//

//<editor-fold>

// https://lottiefiles.com/301-search-location
const _rippleLottieUrl =
    'https://assets7.lottiefiles.com/datafiles/bef3daa39adedbe065d5efad0ae5ccb3/search.json';
// https://lottiefiles.com/94-soda-loader
const _sodaLottieUrl = 'https://assets1.lottiefiles.com/datafiles/cFpiJtSizfCSZyW/data.json';

const _menuItems = <String, Color>{
  'Soda': Colors.blue,
  'Mint': Colors.green,
  'Lemon': Colors.yellow,
  'Orange': Colors.orange,
  'Strawberry': Colors.red,
  'Grape': Colors.purple,
  'Milk': Color(0xFFEEEEEE),
  'Cola': Colors.brown,
};

final _menuIndexProvider = StateProvider<int?>((ref) => 0);

class _RadioMenuTab extends ConsumerWidget {
  // ignore: unused_field
  static final _logger = Logger((_RadioMenuTab).toString());

  const _RadioMenuTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(enableActionsProvider);
    final menuIndex = ref.watch(_menuIndexProvider);

    return Column(
      children: [
        MiRow(
          flexes: const [2, 3],
          children: [
            ExClearButtonListTile(
              enabled: enabled && menuIndex != null,
              onPressed: () {
                ref.read(_menuIndexProvider.notifier).state = null;
              },
            ),
            PopupMenuButton<int?>(
              enabled: enabled,
              tooltip: '',
              initialValue: menuIndex,
              itemBuilder: (context) {
                return [
                  ..._menuItems.entries.mapIndexed(
                    (index, item) => MiRadioPopupMenuItem<int?>(
                      value: index,
                      checked: index == menuIndex,
                      child: MiIcon(
                        icon: MiColorChip(color: item.value),
                        text: Text(item.key),
                      ),
                    ),
                  ),
                ];
              },
              onSelected: (index) {
                ref.read(_menuIndexProvider.notifier).state = index!;
              },
              offset: const Offset(1, 0),
              child: ListTile(
                enabled: enabled,
                title: menuIndex != null
                    ? _menuItems.keys.skip(menuIndex).first.let(
                          (it) => Center(
                            child: Text(it),
                          ),
                        )
                    : null,
                trailing: const Icon(Icons.more_vert),
              ),
            ),
          ],
        ),
        const Divider(),
        if (menuIndex != null) ...[
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(1),
            color: Colors.white,
            child: ColoredBox(
              color: _menuItems.values.skip(menuIndex).first.withAlpha(128),
              child: MiAnimationController(
                builder: (_, controller, __) {
                  return Lottie.network(
                    menuIndex == 6 ? _rippleLottieUrl : _sodaLottieUrl,
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
          const Text(
            'Animations by LottieFiles\nfrom lottiefiles.com.',
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

//</editor-fold>
