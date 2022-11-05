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

// But see also https://pub.dev/packages/flutter_treeview ,
// https://pub.dev/packages/flutter_simple_treeview .

class _CheckItem {
  final StateProvider<bool> provider;
  final Widget icon;
  final String text;
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
    text: 'Box',
  ),
  _CheckItem(
    provider: _textCheckProvider,
    icon: const Icon(Icons.subject),
    text: 'Text',
  ),
  _CheckItem(
    provider: _checkCheckProvider,
    icon: const Icon(Icons.check),
    text: 'Check',
  ),
];

Widget _tallyIcon(WidgetRef ref) {
  const tallyIcons = <Icon>[
    Icon(null),
    Icon(Icons.square_outlined), // 1
    Icon(Icons.subject), // 2
    Icon(Icons.article_outlined),
    Icon(Icons.check), // 4
    Icon(Icons.check_box_outlined),
    Icon(Icons.playlist_add_check_outlined),
    Icon(Icons.fact_check_outlined),
  ];

  final box = ref.read(_boxCheckProvider);
  final text = ref.read(_textCheckProvider);
  final check = ref.read(_checkCheckProvider);
  return tallyIcons[(box ? 1 : 0) + (text ? 2 : 0) + (check ? 4 : 0)];
}

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

// Checkbox tab

class _CheckboxTab extends ConsumerWidget {
  const _CheckboxTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final box = ref.watch(_boxCheckProvider);
    final text = ref.watch(_textCheckProvider);
    final check = ref.watch(_checkCheckProvider);

    final tallyIcon = _tallyIcon(ref);

    void setTally(bool value) {
      ref.read(_boxCheckProvider.state).state = value;
      ref.read(_textCheckProvider.state).state = value;
      ref.read(_checkCheckProvider.state).state = value;
    }

    return Column(
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
                  text: Text(item.text),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  ref.read(item.provider.state).state = value!;
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
    );
  }
}

// Toggle buttons tab

class _ToggleButtonsTab extends ConsumerWidget {
  const _ToggleButtonsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);

    final selected = <bool>[
      ref.watch(_boxCheckProvider),
      ref.watch(_textCheckProvider),
      ref.watch(_checkCheckProvider),
    ];

    final tallyIcon = _tallyIcon(ref);

    return Column(
      children: [
        ToggleButtons(
          isSelected: selected,
          onPressed: enableActions
              ? (index) {
                  ref.read(_checkItems[index].provider.state).state = !selected[index];
                }
              : null,
          children: _checkItems
              .map(
                (item) => MiIcon(
                  icon: item.icon,
                  tooltip: item.text,
                ),
              )
              .toList(),
        ),
        const Divider(),
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
    );
  }
}
