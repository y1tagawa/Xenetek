// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

//
// Checkbox examples page.
//

class ChecksPage extends ConsumerWidget {
  static const icon = Icon(Icons.check_box_outlined);
  static const title = Text('Checks');

  static final _logger = Logger((ChecksPage).toString());

  static const _tabs = <Widget>[
    MiTab(
      tooltip: 'Checkbox',
      icon: icon,
    ),
    MiTab(
      tooltip: 'Toggle buttons',
      icon: Icon(Icons.more_horiz),
    ),
  ];

  const ChecksPage({super.key});

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
                _CheckboxTab(),
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
// Checkbox tab
//

// But see also https://pub.dev/packages/flutter_treeview ,
// https://pub.dev/packages/flutter_simple_treeview .

class _CheckItem {
  final StateProvider<bool> provider;
  final Widget icon;
  final Widget text;
  const _CheckItem({
    required this.provider,
    required this.icon,
    required this.text,
  });
}

final _boxCheckProvider = StateProvider((ref) => true);
final _textCheckProvider = StateProvider((ref) => true);
final _checkCheckProvider = StateProvider((ref) => true);

final _checkItems = [
  _CheckItem(
    provider: _boxCheckProvider,
    icon: const Icon(Icons.square_outlined),
    text: const Text('Box'),
  ),
  _CheckItem(
    provider: _textCheckProvider,
    icon: const Icon(Icons.subject),
    text: const Text('Text'),
  ),
  _CheckItem(
    provider: _checkCheckProvider,
    icon: const Icon(Icons.check),
    text: const Text('Check'),
  ),
];

const _tallyIcons = <Icon>[
  Icon(null),
  Icon(Icons.square_outlined), // 1
  Icon(Icons.subject), // 2
  Icon(Icons.article_outlined),
  Icon(Icons.check), // 4
  Icon(Icons.check_box_outlined),
  Icon(Icons.playlist_add_check_outlined),
  Icon(Icons.fact_check_outlined),
];

class _CheckboxTab extends ConsumerWidget {
  const _CheckboxTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final box = ref.watch(_boxCheckProvider);
    final text = ref.watch(_textCheckProvider);
    final check = ref.watch(_checkCheckProvider);

    final tallyIcon = _tallyIcons[(box ? 1 : 0) + (text ? 2 : 0) + (check ? 4 : 0)];

    void setTally(bool value) {
      ref.read(_boxCheckProvider.notifier).state = value;
      ref.read(_textCheckProvider.notifier).state = value;
      ref.read(_checkCheckProvider.notifier).state = value;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          MiExpansionTile(
            enabled: enableActions,
            initiallyExpanded: true,
            // ExpansionTileに他のウィジェットを入れるケースは稀だろうからカスタムウィジェットはまだ作らない
            leading: Checkbox(
              value: (box && text && check)
                  ? true
                  : (box || text || check)
                      ? null
                      : false,
              tristate: true,
              onChanged: enableActions
                  ? (value) {
                      setTally(value != null);
                    }
                  : null,
            ),
            title: MiIcon(
              icon: tallyIcon,
              text: const Text('Tally'),
            ),
            children: _checkItems.map(
              (item) {
                return CheckboxListTile(
                  enabled: enableActions,
                  value: ref.read(item.provider),
                  contentPadding: const EdgeInsets.only(left: 28),
                  title: MiIcon(
                    icon: item.icon,
                    text: item.text,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    ref.read(item.provider.notifier).state = value!;
                  },
                );
              },
            ).toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: IconTheme.merge(
              data: IconThemeData(
                size: 60,
                color: Theme.of(context).disabledColor,
              ),
              child: tallyIcon,
            ),
          ),
        ],
      ),
    );
  }
}

//
// Knight indicator
//

class KnightIndicator extends StatelessWidget {
  static const helmetIcon = Icon(Icons.balcony_outlined);
  static const armourIcon = MiScale(
    scale: 1.2,
    child: MiRotate(
      angleDegree: 90.0,
      child: Icon(Icons.bento_outlined),
    ),
  );
  static const _lGauntletIcon = Icon(Icons.thumb_up_outlined);
  static const _rGauntletIcon = MiScale(scaleX: -1, child: _lGauntletIcon);
  static const gauntletsIcon = MiRow(spacing: 0, children: [_rGauntletIcon, _lGauntletIcon]);
  static const _lBootIcon = Icon(Icons.roller_skating_outlined);
  static const _rBootIcon = MiScale(scaleX: -1, child: _lBootIcon);
  static const bootsIcon = MiRow(spacing: 0, children: [_rBootIcon, _lBootIcon]);
  static const shieldIcon = Icon(Icons.shield_outlined);

  static const _faceIcon = Icon(Icons.child_care_outlined);
  static const _rHandIcon = MiScale(scale: 0.8, child: Icon(Icons.front_hand_outlined));
  static const _lHandIcon = MiScale(scaleX: -1, child: _rHandIcon);
  static const _spaceIcon = Icon(null);

  static const items = <String, Widget>{
    'Boots': bootsIcon,
    'Armour': armourIcon,
    'Gauntlets': gauntletsIcon,
    'Helmet': helmetIcon,
    'Shield': shieldIcon,
  };

  final List<bool> checked;

  const KnightIndicator({
    super.key,
    required this.checked,
  }) : assert(checked.length == items.length);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (checked[3]) helmetIcon else _faceIcon,
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (checked[2])
              const MiTranslate(offset: Offset(0, -6), child: _rGauntletIcon)
            else
              const MiTranslate(offset: Offset(2, -6), child: _rHandIcon),
            if (checked[1]) armourIcon else _spaceIcon,
            if (checked[4])
              const MiTranslate(offset: Offset(-4, 0), child: shieldIcon)
            else if (checked[2])
              const MiTranslate(offset: Offset(-1, -6), child: _lGauntletIcon)
            else
              const MiTranslate(offset: Offset(-4, -6), child: _lHandIcon),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (checked[0]) ...[_rBootIcon, _lBootIcon] else _spaceIcon,
          ],
        ),
      ],
    );
  }
}

//
// Toggle buttons tab
//

final _toggleProvider =
    StateProvider<List<bool>>((ref) => List.filled(KnightIndicator.items.length, false));

class _ToggleButtonsTab extends ConsumerWidget {
  static final _logger = Logger((_ToggleButtonsTab).toString());

  const _ToggleButtonsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final toggle = ref.watch(_toggleProvider);
    _logger.fine(toggle.length);

    return SingleChildScrollView(
      child: Column(
        children: [
          ToggleButtons(
            isSelected: toggle,
            onPressed: enableActions
                ? (index) {
                    ref.read(_toggleProvider.notifier).state =
                        toggle.replaced(index, !toggle[index]);
                  }
                : null,
            children: KnightIndicator.items.entries
                .map(
                  (entry) => MiIcon(
                    icon: entry.value,
                    tooltip: entry.key,
                  ),
                )
                .toList(),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: IconTheme.merge(
              data: IconThemeData(
                color: Theme.of(context).disabledColor,
              ),
              child: KnightIndicator(checked: toggle),
            ),
          ),
        ],
      ),
    );
  }
}
