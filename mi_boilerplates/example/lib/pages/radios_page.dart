// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

enum _Class { fighter, cleric, mage, thief }

class _RadioItem {
  final Widget Function(bool checked) iconBuilder;
  final String text;
  const _RadioItem({required this.iconBuilder, required this.text});
}

final _radioItems = <_Class, _RadioItem>{
  _Class.fighter: _RadioItem(
    iconBuilder: (_) => const Icon(Icons.shield_outlined),
    text: 'Fighter',
  ),
  _Class.cleric: _RadioItem(
    iconBuilder: (_) => const Icon(Icons.emergency_outlined),
    text: 'Cleric',
  ),
  _Class.mage: _RadioItem(
    iconBuilder: (_) => const Icon(Icons.auto_fix_normal_outlined),
    text: 'Mage',
  ),
  _Class.thief: _RadioItem(
    iconBuilder: (checked) =>
        checked ? const Icon(Icons.lock_open) : const Icon(Icons.lock_outlined),
    text: 'Thief',
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

// Radios tab

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
                text: Text(item.text),
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

// Toggle buttons tab

class _ToggleButtonsTab extends ConsumerWidget {
  const _ToggleButtonsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final class_ = ref.watch(_classProvider);

    final selected = _radioItems.keys.map((key) => key == class_).toList();

    return Column(
      children: [
        ToggleButtons(
          isSelected: selected,
          onPressed: enableActions
              ? (index) {
                  ref.read(_classProvider.state).state = _radioItems.keys.toList()[index];
                }
              : null,
          children: _radioItems.entries
              .map(
                (item) => MiIcon(
                  icon: item.value.iconBuilder(item.key == class_),
                  tooltip: item.value.text,
                ),
              )
              .toList(),
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
