// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;
import 'ex_widgets.dart' as ex;

class SwitchesPage extends ConsumerWidget {
  static const icon = Icon(Icons.toggle_on_outlined);
  static const title = Text('Switches');

  static final _logger = Logger((SwitchesPage).toString());

  static const _tabs = <Widget>[
    mi.Tab(
      tooltip: 'Switches',
      icon: icon,
    ),
    mi.Tab(
      tooltip: 'Switch theme',
      icon: Icon(Icons.more_horiz),
    ),
  ];

  const SwitchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);

    return mi.DefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
      builder: (context) {
        return ex.Scaffold(
          appBar: ex.AppBar(
            prominent: ref.watch(ex.prominentProvider),
            icon: icon,
            title: title,
            bottom: ex.TabBar(
              enabled: enabled,
              tabs: _tabs,
            ),
          ),
          body: const TabBarView(
            children: [
              _SwitchesTab(),
              _SwitchThemeTab(),
            ],
          ),
          bottomNavigationBar: const ex.BottomNavigationBar(),
        );
      },
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Switches tab
//

//<editor-fold>

class _SwitchItem {
  final Widget checkIcon;
  final Widget uncheckIcon;
  final Widget title;
  const _SwitchItem({required this.checkIcon, required this.uncheckIcon, required this.title});
}

final _switchItems = [
  _SwitchItem(
    checkIcon: const Icon(Icons.visibility_outlined),
    uncheckIcon: mi.ImageIcon(image: Image.asset('assets/eye_close.png')),
    //uncheckIcon: Icon(Icons.disabled_visible_outlined),
    title: const Text('Eye health'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.hearing_outlined),
    uncheckIcon: mi.Scale(scaleX: -1, child: Icon(Icons.hearing_disabled_outlined)),
    title: Text('Ear health'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.cloud_outlined),
    uncheckIcon: Icon(Icons.cloud_circle_outlined),
    title: Text('Mental health'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.calendar_view_month_outlined),
    uncheckIcon: Icon(Icons.widgets_outlined),
    title: Text('Dental health'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.directions_run),
    uncheckIcon: Icon(Icons.airline_seat_flat_outlined),
    title: Text('Physical health'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.attach_money_outlined),
    uncheckIcon: Icon(Icons.money_off_outlined),
    title: Text('Money'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.air_outlined),
    uncheckIcon: Icon(Icons.thermostat),
    title: Text('Air conditioning'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.bathroom_outlined),
    uncheckIcon: Icon(Icons.format_color_reset_outlined),
    title: Text('Bath'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.hourglass_top_outlined),
    uncheckIcon: Icon(Icons.hourglass_empty_outlined),
    title: Text('Life time'),
  ),
];

final _switchProvider = StateProvider((ref) => List.filled(_switchItems.length, true));

class _SwitchesTab extends ConsumerWidget {
  const _SwitchesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(ex.enableActionsProvider);
    final switches = ref.watch(_switchProvider);

    final theme = Theme.of(context);

    final myHp = switches.where((value) => value).length;

    void reset(bool value) {
      ref.read(_switchProvider.notifier).state = List.filled(_switchItems.length, value);
    }

    return Column(
      children: [
        mi.Row(
          flexes: const [1, 1],
          children: [
            ex.ResetButtonListTile(
              enabled: enableActions && switches.any((value) => !value),
              onPressed: () => reset(true),
            ),
            ex.ClearButtonListTile(
              enabled: enableActions && switches.any((value) => value),
              onPressed: () => reset(false),
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: ListView(
            children: _switchItems.mapIndexed(
              (index, item) {
                final switchValue = switches[index];
                return SwitchListTile(
                  value: switchValue,
                  title: mi.Label(
                    icon: mi.ToggleIcon(
                      checked: switchValue,
                      checkIcon: item.checkIcon,
                      uncheckIcon: item.uncheckIcon,
                    ),
                    text: item.title,
                  ),
                  onChanged: enableActions
                      ? (value) {
                          ref.read(_switchProvider.notifier).state =
                              switches.replacedAt(index, value);
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
    );
  }
}

//</editor-fold>

//
// Switch theme tab
//

// TODO: activeColors

final _thumbColorCoordinator = ex.ColorSlider.coordinatorFromPosition(1.0);
final _trackColorCoordinator = ex.ColorSlider.coordinatorFromPosition(0.0);
final _cupertinoProvider = StateProvider((ref) => false);
final _switchValueProvider = StateProvider((ref) => true);

class _SwitchThemeTab extends ConsumerWidget {
  static final _logger = Logger((SwitchesPage).toString());

  const _SwitchThemeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(ex.enableActionsProvider);
    final cupertino = ref.watch(_cupertinoProvider);
    final thumbColor = ref.watch(_thumbColorCoordinator.provider);
    final trackColor = ref.watch(_trackColorCoordinator.provider);
    final value = ref.watch(_switchValueProvider);

    void onChanged(bool value) {
      ref.read(_switchValueProvider.notifier).state = value;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: const Text('Style'),
            trailing: ToggleButtons(
              onPressed: enabled
                  ? (int index) {
                      ref.read(_cupertinoProvider.notifier).state = index == 0;
                    }
                  : null,
              isSelected: <bool>[cupertino, !cupertino],
              children: const [
                mi.SizedCenter(width: 80, child: Text('Cupertino')),
                mi.SizedCenter(width: 80, child: Text('Material')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Thumb color'),
            trailing: SizedBox(
              width: 140,
              child: thumbColor.when(
                data: (value) => ex.ColorSlider(
                  value: value,
                  onChanged: enabled
                      ? (value) {
                          _thumbColorCoordinator.controller.sink.add(value);
                        }
                      : null,
                ),
                error: (error, _) => Text(error.toString()),
                loading: () => const CircularProgressIndicator(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Track color'),
            trailing: SizedBox(
              width: 140,
              child: trackColor.when(
                data: (value) => ex.ColorSlider(
                  value: value,
                  trackHeight: 8,
                  onChanged: enabled
                      ? (value) {
                          _trackColorCoordinator.controller.sink.add(value);
                        }
                      : null,
                ),
                error: (error, _) => Text(error.toString()),
                loading: () => const CircularProgressIndicator(),
              ),
            ),
          ),
          const Divider(),
          cupertino
              ? CupertinoSwitch(
                  value: value,
                  thumbColor: thumbColor.value?.color,
                  trackColor: trackColor.value?.color,
                  onChanged: enabled ? onChanged : null,
                )
              : SwitchTheme(
                  data: SwitchTheme.of(context).copyWith(
                    thumbColor: MaterialStateProperty.resolveWith((states) =>
                        states.contains(MaterialState.disabled) ? null : thumbColor.value?.color),
                    trackColor: MaterialStateProperty.resolveWith((states) =>
                        states.contains(MaterialState.disabled) ? null : trackColor.value?.color),
                  ),
                  child: Switch(
                    value: value,
                    onChanged: enabled ? onChanged : null,
                  ),
                ),
        ],
      ),
    );
  }
}
