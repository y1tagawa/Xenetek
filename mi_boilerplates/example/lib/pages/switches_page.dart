// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

class _SwitchItem {
  final Widget checkIcon;
  final Widget uncheckIcon;
  final Widget title;
  const _SwitchItem({required this.checkIcon, required this.uncheckIcon, required this.title});
}

const _switchItems = [
  _SwitchItem(
    checkIcon: Icon(Icons.visibility_outlined),
    uncheckIcon: Icon(Icons.disabled_visible_outlined),
    title: Text('Eye health'),
  ),
  _SwitchItem(
    checkIcon: Icon(Icons.hearing_outlined),
    uncheckIcon: MiScale(scaleX: -1, child: Icon(Icons.hearing_disabled_outlined)),
    title: Text('Ear health'),
  ),
  _SwitchItem(
    checkIcon: Icon(Icons.cloud_outlined),
    uncheckIcon: Icon(Icons.cloud_circle_outlined),
    title: Text('Mental health'),
  ),
  _SwitchItem(
    checkIcon: Icon(Icons.calendar_view_month_outlined),
    uncheckIcon: Icon(Icons.widgets_outlined),
    title: Text('Dental health'),
  ),
  _SwitchItem(
    checkIcon: Icon(Icons.directions_run),
    uncheckIcon: Icon(Icons.airline_seat_flat_outlined),
    title: Text('Physical health'),
  ),
  _SwitchItem(
    checkIcon: Icon(Icons.attach_money_outlined),
    uncheckIcon: Icon(Icons.money_off_outlined),
    title: Text('Money'),
  ),
  _SwitchItem(
    checkIcon: Icon(Icons.air_outlined),
    uncheckIcon: Icon(Icons.thermostat),
    title: Text('Air conditioning'),
  ),
  _SwitchItem(
    checkIcon: Icon(Icons.bathroom_outlined),
    uncheckIcon: Icon(Icons.format_color_reset_outlined),
    title: Text('Bath'),
  ),
  _SwitchItem(
    checkIcon: Icon(Icons.hourglass_top_outlined),
    uncheckIcon: Icon(Icons.hourglass_empty_outlined),
    title: Text('Life time'),
  ),
];

final _switchProvider = StateProvider((ref) => List.filled(_switchItems.length, true));

class SwitchesPage extends ConsumerWidget {
  static const icon = Icon(Icons.toggle_on_outlined);
  static const title = Text('Switches');

  const SwitchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final switches = ref.watch(_switchProvider);

    final theme = Theme.of(context);

    final myHp = switches.where((value) => value).length;

    void reset(bool value) {
      ref.read(_switchProvider.notifier).state = List.filled(_switchItems.length, value);
    }

    return Scaffold(
      appBar: ExAppBar(
        prominent: ref.watch(prominentProvider),
        icon: MiToggleIcon(
          checked: enableActions,
          checkIcon: icon,
          uncheckIcon: const Icon(Icons.toggle_off_outlined),
        ),
        title: title,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Column(
          children: [
            MiRow(
              flexes: const [1, 1],
              children: [
                MiButtonListTile(
                  enabled: enableActions,
                  onPressed: () => reset(true),
                  icon: const Icon(Icons.refresh),
                  text: const Text('Reset'),
                ),
                MiButtonListTile(
                  enabled: enableActions,
                  onPressed: () => reset(false),
                  icon: const Icon(Icons.clear),
                  text: const Text('Clear'),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: _switchItems.mapIndexed(
                  (index, item) {
                    final switchValue = switches[index];
                    return MiSwitchListTile(
                        enabled: enableActions,
                        value: switchValue,
                        title: MiIcon(
                          icon: MiToggleIcon(
                            checked: switchValue,
                            checkIcon: item.checkIcon,
                            uncheckIcon: item.uncheckIcon,
                          ),
                          text: item.title,
                        ),
                        onChanged: (value) {
                          ref.read(_switchProvider.notifier).state =
                              switches.replaced(index, value);
                        });
                  },
                ).toList(),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                children: [
                  AnimatedOpacity(
                    opacity: myHp.toDouble() / _switchItems.length,
                    duration: const Duration(milliseconds: 500),
                    child: Icon(
                      Icons.person_outline_outlined,
                      size: 48,
                      color: theme.disabledColor,
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: myHp > 0 ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Icon(
                      Icons.portrait_outlined,
                      size: 48,
                      color: theme.disabledColor,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ExBottomNavigationBar(),
    );
  }
}
