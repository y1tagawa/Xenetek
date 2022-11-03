// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import '../data/primary_color_names.dart';
import '../data/x11_colors.dart';
import '../main.dart';
import 'ex_app_bar.dart';

///
/// Exampleアプリの設定ページ。
///

final _useX11ColorProvider = StateProvider((ref) => false);

class SettingsPage extends ConsumerWidget {
  static const icon = Icon(Icons.settings_outlined);
  static const title = Text('Settings');

  static final _logger = Logger((SettingsPage).toString());

  const SettingsPage({super.key});

  ///
  //bool showColorGridDialog()

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    assert(x11Colors.length == x11ColorNames.length);

    final useX11ColorState = ref.watch(_useX11ColorProvider.state);
    final useX11Color = useX11ColorState.state;

    final theme = Theme.of(context);

    final primarySwatchItems = [
      ...Colors.primaries.mapIndexed(
        (index, color) => DropdownMenuItem<MaterialColor>(
          value: color,
          child: MiColorChip(
            color: color,
            tooltip: primaryColorNames[index],
          ),
        ),
      ),
      if (useX11Color)
        ...x11Colors.mapIndexed(
          (index, color) => DropdownMenuItem<MaterialColor>(
            value: color.toMaterialColor(),
            child: MiColorChip(
              color: color,
              tooltip: x11ColorNames[index],
            ),
          ),
        ),
    ];

    final secondaryColorItems = <DropdownMenuItem<Color?>>[
      const DropdownMenuItem<Color?>(
        value: null,
        child: MiColorChip(color: null, tooltip: 'null'),
      ),
      ...primarySwatchItems,
    ];

    return Scaffold(
      appBar: ExAppBar(
        prominent: ref.watch(prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // テーマ
            Text('Theme', style: theme.textTheme.headline6),
            CheckboxListTile(
              value: useX11Color,
              title: const Text('X11 colors'),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) => useX11ColorState.state = value!,
            ),
            ListTile(
              title: const Text('Primary swatch'),
              trailing: DropdownButton<MaterialColor>(
                value: ref.watch(primarySwatchProvider),
                items: primarySwatchItems,
                onChanged: (value) {
                  ref.read(primarySwatchProvider.state).state = value!;
                },
              ),
            ),
            ListTile(
              title: const Text('Secondary color'),
              trailing: DropdownButton<Color?>(
                value: ref.watch(secondaryColorProvider),
                items: secondaryColorItems,
                onChanged: (value) {
                  ref.read(secondaryColorProvider.state).state = value;
                },
              ),
            ),
            CheckboxListTile(
              value: ref.watch(brightnessProvider).isDark,
              title: const Text('Dark'),
              onChanged: (value) {
                ref.read(brightnessProvider.state).state =
                    value! ? Brightness.dark : Brightness.light;
              },
            ),
            CheckboxListTile(
              value: ref.watch(useM3Provider),
              title: const Text('Use material 3'),
              onChanged: (value) {
                ref.read(useM3Provider.state).state = value!;
              },
            ),
            CheckboxListTile(
              value: ref.watch(themeAdjustmentProvider),
              title: const Text('Use mi themes'),
              onChanged: (value) {
                ref.read(themeAdjustmentProvider.state).state = value!;
              },
            ),
            const Divider(),
          ],
        ),
      ),
      bottomNavigationBar: const ExBottomNavigationBar(),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
