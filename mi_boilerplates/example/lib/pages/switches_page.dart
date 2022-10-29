// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';
import 'ex_bottom_navigation_bar.dart';

class _SwitchItem {
  final Icon iconOn;
  final Icon iconOff;
  final Widget title;
  const _SwitchItem({required this.iconOn, required this.iconOff, required this.title});
}

const _switchItems = [
  _SwitchItem(
    iconOn: Icon(Icons.visibility_outlined),
    iconOff: Icon(Icons.visibility_off_outlined),
    title: Text('Vision'),
  ),
  _SwitchItem(
    iconOn: Icon(Icons.hearing_outlined),
    iconOff: Icon(Icons.hearing_disabled_outlined),
    title: Text('Hearing'),
  ),
  _SwitchItem(
    iconOn: Icon(Icons.psychology_outlined),
    iconOff: Icon(Icons.question_mark),
    title: Text('Memory'),
  ),
  _SwitchItem(
    iconOn: Icon(Icons.directions_run),
    iconOff: Icon(Icons.airline_seat_flat_outlined),
    title: Text('Health'),
  ),
  _SwitchItem(
    iconOn: Icon(Icons.attach_money_outlined),
    iconOff: Icon(Icons.money_off_outlined),
    title: Text('Money'),
  ),
  _SwitchItem(
    iconOn: Icon(Icons.air_outlined),
    iconOff: Icon(Icons.thermostat),
    title: Text('Air conditioning'),
  ),
  _SwitchItem(
    iconOn: Icon(Icons.bathroom_outlined),
    iconOff: Icon(Icons.format_color_reset_outlined),
    title: Text('Bath'),
  ),
  _SwitchItem(
    iconOn: Icon(Icons.hourglass_top_outlined),
    iconOff: Icon(Icons.hourglass_bottom_outlined),
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
    final switchValueStates = ref.watch(_switchProvider.state);
    final switchValues = switchValueStates.state;

    final loVisColor = Theme.of(context).disabledColor;

    final MyHp = switchValues.where((value) => value).length;

    void reset(bool value) {
      switchValueStates.state = List.filled(_switchItems.length, value);
    }

    return Scaffold(
      appBar: ExAppBar(
        prominent: ref.watch(prominentProvider),
        leading: enableActions ? icon : const Icon(Icons.toggle_off_outlined),
        title: title,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MiTextButton(
                  enabled: enableActions && MyHp < _switchItems.length,
                  onPressed: () => reset(true),
                  child: const MiIcon(
                    icon: Icon(Icons.refresh),
                    text: Text('Reset'),
                  ),
                ),
                MiTextButton(
                  enabled: enableActions && MyHp > 0,
                  onPressed: () => reset(false),
                  child: const MiIcon(
                    icon: Icon(Icons.clear),
                    text: Text('Clear'),
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: _switchItems.mapIndexed(
                  (index, item) {
                    final switchValue = switchValues[index];
                    return MiSwitchListTile(
                      enabled: enableActions,
                      value: switchValue,
                      title: MiIcon(
                        icon: switchValue ? item.iconOn : item.iconOff,
                        text: item.title,
                      ),
                      onChanged: (value) =>
                          switchValueStates.state = switchValues.replaced(index, value),
                    );
                  },
                ).toList(),
              ),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(10),
              child: MyHp > 0
                  ? Icon(
                      Icons.person_outline_outlined,
                      size: 48,
                      color: loVisColor,
                    )
                  : MiRotate(
                      angleDegree: 90,
                      child: Icon(
                        Icons.crop_7_5,
                        size: 48,
                        color: loVisColor,
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ExBottomNavigationBar(),
    );
  }
}
