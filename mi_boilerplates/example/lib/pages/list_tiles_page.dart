// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import '../main.dart';
import 'ex_app_bar.dart';
import 'ex_bottom_navigation_bar.dart';

//
// List tiles examples page.
//

final _checkProvider = StateProvider((ref) => true);
final _radioProvider = StateProvider((ref) => 0);
final _switchProvider = StateProvider((ref) => true);
final _selectedProvider = StateProvider((ref) => 0);

bool _expanded = true;

class ListTilesPage extends ConsumerWidget {
  static const icon = Icon(Icons.dns_outlined);
  static const title = Text('List tiles');

  static final _logger = Logger((ListTilesPage).toString());

  const ListTilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final useMiThemes = ref.watch(adjustThemeProvider);
    final check = ref.watch(_checkProvider);
    final radio = ref.watch(_radioProvider);
    final switch_ = ref.watch(_switchProvider);
    final selected = ref.watch(_selectedProvider);

    const expansionTileChild = Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: MiIcon(
        icon: Icon(Icons.child_care_outlined),
        text: Text('Child'),
      ),
    );

    return Scaffold(
      appBar: ExAppBar(
        prominent: ref.watch(prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                enabled: enableActions,
                selected: selected == 0,
                onTap: () {
                  ref.read(_selectedProvider.state).state = 0;
                },
                title: const MiIcon(
                  icon: Icon(Icons.person_outline),
                  text: Text('ListTile'),
                ),
              ),
              CheckboxListTile(
                enabled: enableActions,
                selected: selected == 1,
                value: check,
                onChanged: (value) {
                  ref.read(_checkProvider.state).state = value!;
                  ref.read(_selectedProvider.state).state = 1;
                },
                title: const MiIcon(
                  icon: Icon(Icons.person_outline),
                  text: Text('CheckboxListTile'),
                ),
              ),
              MiRadioListTile<int>(
                enabled: enableActions,
                selected: selected == 2,
                groupValue: radio,
                toggleable: true,
                value: 0,
                onChanged: (_) {
                  ref.read(_radioProvider.state).state = radio == 0 ? 1 : 0;
                  ref.read(_selectedProvider.state).state = 2;
                },
                title: const MiIcon(
                  icon: Icon(Icons.person_outline),
                  text: Text('RadioListTile'),
                ),
              ),
              MiSwitchListTile(
                enabled: enableActions,
                selected: selected == 3,
                value: switch_,
                onChanged: (value) {
                  ref.read(_switchProvider.state).state = value;
                  ref.read(_selectedProvider.state).state = 3;
                },
                title: const MiIcon(
                  icon: Icon(Icons.person_outline),
                  text: Text('SwitchListTile'),
                ),
              ),
              if (useMiThemes)
                MiExpansionTile(
                  enabled: enableActions,
                  title: const MiIcon(
                    icon: Icon(Icons.person_outline),
                    text: Text('MiExpansionTile'),
                  ),
                  initiallyExpanded: _expanded,
                  onExpansionChanged: (value) {
                    _expanded = value;
                  },
                  dividerColor: Colors.transparent,
                  children: const [expansionTileChild],
                )
              else
                ExpansionTile(
                  title: const MiIcon(
                    icon: Icon(Icons.person_outline),
                    text: Text('ExpansionTile'),
                  ),
                  initiallyExpanded: _expanded,
                  onExpansionChanged: (value) {
                    _expanded = value;
                  },
                  children: const [expansionTileChild],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ExBottomNavigationBar(),
    );
  }
}
