// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

enum _Class { fighter, cleric, mage, thief }

class _RadioItem {
  final Widget Function(bool checked) iconBuilder;
  final Widget text;
  const _RadioItem({required this.iconBuilder, required this.text});
}

final _radioItems = <_Class, _RadioItem>{
  _Class.fighter: _RadioItem(
    iconBuilder: (_) => const Icon(Icons.shield_outlined),
    text: const Text('Fighter'),
  ),
  _Class.cleric: _RadioItem(
    iconBuilder: (_) => const Icon(Icons.emergency_outlined),
    text: const Text('Cleric'),
  ),
  _Class.mage: _RadioItem(
    iconBuilder: (_) => const Icon(Icons.auto_fix_normal_outlined),
    text: const Text('Mage'),
  ),
  _Class.thief: _RadioItem(
    iconBuilder: (checked) =>
        checked ? const Icon(Icons.lock_open) : const Icon(Icons.lock_outlined),
    text: const Text('Thief'),
  ),
};

final _classProvider = StateProvider((ref) => _Class.fighter);

class RadiosPage extends ConsumerWidget {
  static const icon = Icon(Icons.radio_button_checked_outlined);
  static const title = Text('Radios');

  static final _logger = Logger((RadiosPage).toString());

  static const _tabs = <Widget>[
    MiTab(
      tooltip: 'Radios',
      icon: icon,
    ),
    MiTab(
      tooltip: 'Toggle buttons',
      icon: Icon(Icons.more_horiz),
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

class _RadiosTab extends ConsumerWidget {
  static final _logger = Logger((_RadiosTab).toString());

  const _RadiosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final class_ = ref.watch(_classProvider);

    return Column(
      children: [
        ..._radioItems.keys.map(
          (key) {
            final item = _radioItems[key]!;
            return MiRadioListTile<_Class>(
              enabled: enableActions,
              value: key,
              groupValue: class_,
              title: MiIcon(
                icon: item.iconBuilder(key == class_),
                text: item.text,
              ),
              onChanged: (value) {
                ref.read(_classProvider.state).state = value!;
              },
            );
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: IconTheme(
            data: IconThemeData(
              color: Theme.of(context).disabledColor,
              size: 60,
            ),
            child: _radioItems[class_]!.iconBuilder(true),
          ),
        ),
      ],
    );
  }
}

//
// Toggle buttons tab
//

const _toggleItems = <Widget>[
  Text('Soda'),
  Text('Mint'),
  Text('Lemon'),
  Text('Orange'),
  Text('Straw\nberry'),
  Text('Grape'),
  Text('Milk'),
  Text('Cocoa'),
];

const _toggleItemColors = <Color>[
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.red,
  Colors.purple,
  Colors.white,
  Colors.brown,
];

final _selectdProvider = StateProvider((ref) => 0);

class _ToggleButtonsTab extends ConsumerWidget {
  const _ToggleButtonsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final selected = ref.watch(_selectdProvider);
    final flags = _toggleItems.mapIndexed((index, _) => index == selected).toList();

    return Column(
      children: [
        // 0..3
        ToggleButtons(
          isSelected: flags.take(4).toList(),
          fillColor: _toggleItemColors[selected].withAlpha(40),
          onPressed: enableActions
              ? (index) {
                  ref.read(_selectdProvider.state).state = index;
                }
              : null,
          children: _toggleItems.take(4).toList(),
        ),
        // 4..7
        Transform.translate(
          offset: const Offset(0, -1),
          child: ToggleButtons(
            isSelected: flags.skip(4).toList(),
            fillColor: _toggleItemColors[selected].withAlpha(64),
            onPressed: enableActions
                ? (index) {
                    ref.read(_selectdProvider.state).state = index + 4;
                  }
                : null,
            children: _toggleItems.skip(4).toList(),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(selected.toString()),
        ),
      ],
    );
  }
}
