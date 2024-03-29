// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import '../main.dart';
import 'ex_app_bar.dart' as ex;

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

  const ListTilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(ex.enableActionsProvider);
    final themeAdjustment = ref.watch(colorSettingsProvider).when(
          data: (data) => data.doModify,
          error: (error, stackTrace) {
            debugPrintStack(stackTrace: stackTrace, label: error.toString());
            return true;
          },
          loading: () => true,
        );
    final check = ref.watch(_checkProvider);
    final radio = ref.watch(_radioProvider);
    final switch_ = ref.watch(_switchProvider);
    final selected = ref.watch(_selectedProvider);

    const expansionTileChild = Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: mi.Label(
        icon: Icon(Icons.child_care_outlined),
        text: Text('Child'),
      ),
    );

    return ex.Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              enabled: enableActions,
              selected: selected == 0,
              onTap: () {
                ref.read(_selectedProvider.notifier).state = 0;
              },
              title: const mi.Label(
                icon: Icon(Icons.person_outline),
                text: Text('ListTile'),
              ),
            ),
            CheckboxListTile(
              enabled: enableActions,
              selected: selected == 1,
              value: check,
              onChanged: (value) {
                ref.read(_checkProvider.notifier).state = value!;
                ref.read(_selectedProvider.notifier).state = 1;
              },
              title: const mi.Label(
                icon: Icon(Icons.person_outline),
                text: Text('CheckboxListTile'),
              ),
            ),
            RadioListTile<int>(
              selected: selected == 2,
              groupValue: radio,
              toggleable: true,
              value: 0,
              onChanged: enableActions
                  ? (_) {
                      ref.read(_radioProvider.notifier).state = radio == 0 ? 1 : 0;
                      ref.read(_selectedProvider.notifier).state = 2;
                    }
                  : null,
              title: const mi.Label(
                icon: Icon(Icons.person_outline),
                text: Text('RadioListTile'),
              ),
            ),
            SwitchListTile(
              selected: selected == 3,
              value: switch_,
              onChanged: enableActions
                  ? (value) {
                      ref.read(_switchProvider.notifier).state = value;
                      ref.read(_selectedProvider.notifier).state = 3;
                    }
                  : null,
              title: const mi.Label(
                icon: Icon(Icons.person_outline),
                text: Text('SwitchListTile'),
              ),
            ),
            if (themeAdjustment)
              mi.ExpansionTile(
                enabled: enableActions,
                title: const mi.Label(
                  icon: Icon(Icons.person_outline),
                  text: Text('mi.ExpansionTile'),
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
                title: const mi.Label(
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
      bottomNavigationBar: const ex.BottomNavigationBar(),
    );
  }
}
