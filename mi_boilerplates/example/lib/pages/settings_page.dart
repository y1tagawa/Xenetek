// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:example/data/jis_common_colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import '../data/primary_color_names.dart';
import '../data/x11_colors.dart';
import '../main.dart';
import 'ex_app_bar.dart';

Future<bool> _showColorSelectDialog({
  required BuildContext context,
  Widget? title,
  Color? initialColor,
  required List<Widget> tabs,
  required List<List<Color?>> colors,
  required List<List<String>> tooltips,
  void Function(int tabIndex, int colorIndex)? onChanged,
}) async {
  Color? color = initialColor;

  return await showDialog<bool>(
    context: context,
    builder: (context) => MiOkCancelDialog<bool>(
      icon: MiColorChip(color: color),
      title: title,
      getValue: (ok) => ok,
      content: SizedBox(
        width: MediaQuery.of(context).size.height * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: StatefulBuilder(
          builder: (context, setState) {
            return MiEmbeddedTabView(
              tabs: tabs,
              initialIndex: 0,
              children: colors
                  .mapIndexed(
                    (tabIndex, colors_) => SingleChildScrollView(
                      child: MiColorGrid(
                        colors: colors_,
                        tooltips: tooltips[tabIndex],
                        onChanged: (colorIndex) {
                          setState(() => color = colors_[colorIndex]);
                          onChanged?.call(tabIndex, colorIndex);
                        },
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    ),
  ).then((value) => value ?? false);
}

Future<bool> showColorSelectDialog({
  required BuildContext context,
  Widget? title,
  required Color? initialColor,
  void Function(Color? value)? onChanged,
  bool nullable = false,
}) async {
  const tabs = <Widget>[
    MiTab(icon: Icon(Icons.flutter_dash)),
    MiTab(text: 'X11'),
    MiTab(text: 'JIS'),
  ];

  final colors = <List<Color?>>[
    [if (nullable) null, ...Colors.primaries],
    x11Colors,
    jisCommonColors,
  ];

  final tooltips = [
    [if (nullable) 'null', ...primaryColorNames],
    x11ColorNames,
    jisCommonColorNames,
  ];

  final ok = await _showColorSelectDialog(
      context: context,
      title: title,
      initialColor: initialColor,
      tabs: tabs,
      colors: colors,
      tooltips: tooltips,
      onChanged: (tabIndex, colorIndex) {
        onChanged?.call(colors[tabIndex][colorIndex]);
      });
  if (!ok) {
    onChanged?.call(initialColor);
  }
  return ok;
}

///
/// Exampleアプリの設定ページ
///

class SettingsPage extends ConsumerWidget {
  static const icon = Icon(Icons.settings_outlined);
  static const title = Text('Settings');

  static final _logger = Logger((SettingsPage).toString());

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    assert(x11Colors.length == x11ColorNames.length);

    final preferences = ref.watch(preferencesProvider);

    final theme = Theme.of(context);

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
            // primarySwatch
            ListTile(
              enabled: preferences.hasValue,
              title: const Text('Primary swatch'),
              trailing: MiIconButton(
                icon: MiColorChip(
                  color: ref.watch(primarySwatchProvider),
                ),
                onPressed: () async {
                  final ok = await showColorSelectDialog(
                    context: context,
                    title: const Text('Primary swatch'),
                    initialColor: ref.watch(primarySwatchProvider),
                    onChanged: (value) {
                      ref.read(primarySwatchProvider.notifier).state = value!.toMaterialColor();
                    },
                  );
                  if (ok) {
                    final it = ref.read(primarySwatchProvider).value.toString();
                    _logger.fine('setting preferences primary_swatch=$it');
                    preferences.value?.setString('primary_swatch', it);
                  }
                },
              ),
            ),
            ListTile(
              enabled: preferences.hasValue,
              title: const Text('Secondary color'),
              trailing: MiIconButton(
                icon: MiColorChip(
                  color: ref.watch(secondaryColorProvider),
                ),
                onPressed: () async {
                  final ok = await showColorSelectDialog(
                    context: context,
                    title: const Text('Secondary color'),
                    initialColor: ref.watch(secondaryColorProvider),
                    nullable: true,
                    onChanged: (value) {
                      ref.read(secondaryColorProvider.notifier).state = value;
                    },
                  );
                  if (ok) {
                    final secondaryColor = ref.read(secondaryColorProvider);
                    // Dartがnullableをまともに扱えるようになるまで、null値と省略は区別しない事にする。
                    if (secondaryColor != null) {
                      final it = secondaryColor.value.toString();
                      _logger.fine('setting preferences secondary_color=$it');
                      preferences.value?.setString('secondary_color', it);
                    } else {
                      _logger.fine('removing preferences secondary_color');
                      await preferences.value?.remove('secondary_color');
                    }
                  }
                },
              ),
            ),
            CheckboxListTile(
              enabled: preferences.hasValue,
              value: ref.watch(brightnessProvider).isDark,
              title: const Text('Dark'),
              onChanged: (value) {
                final it = value! ? Brightness.dark : Brightness.light;
                ref.read(brightnessProvider.notifier).state = it;
                _logger.fine('setting preferences brightness=$it');
                preferences.value?.setString('brightness', it.toString());
              },
            ),
            CheckboxListTile(
              value: ref.watch(useM3Provider),
              title: const Text('Use material 3'),
              onChanged: (value) {
                ref.read(useM3Provider.notifier).state = value!;
              },
            ),
            CheckboxListTile(
              value: ref.watch(themeAdjustmentProvider),
              title: const Text('Adjust theme'),
              onChanged: (value) {
                ref.read(themeAdjustmentProvider.notifier).state = value!;
              },
            ),
            ListTile(
              leading: MiTextButton(
                enabled: preferences.hasValue,
                onPressed: () async {
                  // TODO: yes/no
                  _logger.fine('clearing preferences.');
                  await preferences.value?.clear();
                  ref.invalidate(preferencesProvider);
                  // TODO: reload
                },
                child: const Text('Reset preferences'),
              ),
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
