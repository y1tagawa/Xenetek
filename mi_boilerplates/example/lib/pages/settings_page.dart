// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/pages/ex_color_grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import '../main.dart';
import 'ex_app_bar.dart' as ex;

Future<bool> _showColorSelectDialog({
  required BuildContext context,
  Widget? title,
  required Color? initialColor,
  void Function(Color? value)? onChanged,
  bool nullable = false,
}) async {
  final ok = await mi.ColorGridHelper.showColorSelectDialog(
    context: context,
    title: title,
    initialColor: initialColor,
    onChanged: onChanged,
    builder: (_, onChanged) {
      return ColorGrid(
        onChanged: onChanged,
      );
    },
  );
  if (!ok) {
    onChanged?.call(initialColor);
  }
  return ok;
}

Future<bool> _showTextColorSelectDialog({
  required BuildContext context,
  Widget? title,
  required Color? initialColor,
  void Function(Color? value)? onChanged,
  bool nullable = false,
}) async {
  final colors = <Color?>[
    if (nullable) null,
    Colors.grey[800],
    Colors.blueGrey[800],
    Colors.grey[900],
    ...Colors.primaries.map((it) => it[900]),
  ];

  final tooltips = [
    if (nullable) 'null',
    'grey800',
    'blueGray800',
    'grey900',
    ...mi.primaryColorNames.map((it) => '${it}900'),
  ];

  final ok = await mi.ColorGridHelper.showColorSelectDialog(
    context: context,
    title: title,
    initialColor: initialColor,
    onChanged: (color) {
      onChanged?.call(color);
    },
    builder: (_, onChanged_) {
      return SingleChildScrollView(
        child: mi.ColorGrid(
          colors: colors,
          tooltips: tooltips,
          onChanged: (index) => onChanged_?.call(colors[index]),
        ),
      );
    },
  );
  if (!ok) {
    onChanged?.call(initialColor);
  }
  return ok;
}

Future<bool> _showBackgroundColorSelectDialog({
  required BuildContext context,
  Widget? title,
  required Color? initialColor,
  void Function(Color? value)? onChanged,
  bool nullable = false,
}) async {
  final colors = <Color?>[
    if (nullable) null,
    Colors.grey[50],
    ...Colors.primaries.map((it) => it[50]),
    Colors.grey[100],
    ...Colors.primaries.map((it) => it[100]),
  ];

  final tooltips = [
    if (nullable) 'null',
    'grey50',
    ...mi.primaryColorNames.map((it) => '${it}50'),
    'grey100',
    ...mi.primaryColorNames.map((it) => '${it}100'),
  ];

  final ok = await mi.ColorGridHelper.showColorSelectDialog(
    context: context,
    title: title,
    initialColor: initialColor,
    onChanged: (color) {
      onChanged?.call(color);
    },
    builder: (_, onChanged_) {
      return SingleChildScrollView(
        child: mi.ColorGrid(
          colors: colors,
          tooltips: tooltips,
          onChanged: (index) => onChanged_?.call(colors[index]),
        ),
      );
    },
  );
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
    assert(mi.x11Colors.length == mi.x11ColorNames.length);

    final primarySwatch = ref.watch(primarySwatchProvider);
    final secondaryColor = ref.watch(secondaryColorProvider);
    final textColor = ref.watch(textColorProvider);
    final backgroundColor = ref.watch(backgroundColorProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: ListView(
          children: <Widget>[
            // テーマ
            Center(
              child: Text('Theme', style: theme.textTheme.headline6),
            ),
            // primarySwatch
            ListTile(
              title: const Text('Primary swatch'),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: mi.ColorChip(color: primarySwatch),
              ),
              onTap: () async {
                final ok = await _showColorSelectDialog(
                  context: context,
                  title: const Text('Primary swatch'),
                  initialColor: primarySwatch,
                  onChanged: (value) {
                    ref.read(primarySwatchProvider.notifier).state = value!.toMaterialColor();
                  },
                );
                if (ok) {
                  await saveThemePreferences(ref);
                }
              },
            ),
            ListTile(
              title: const Text('Secondary color'),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: mi.ColorChip(color: secondaryColor),
              ),
              onTap: () async {
                final ok = await _showColorSelectDialog(
                  context: context,
                  title: const Text('Secondary color'),
                  initialColor: secondaryColor,
                  nullable: true,
                  onChanged: (value) {
                    ref.read(secondaryColorProvider.notifier).state = value;
                  },
                );
                if (ok) {
                  await saveThemePreferences(ref);
                }
              },
            ),
            ListTile(
              title: const Text('Text color'),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: mi.ColorChip(color: textColor),
              ),
              onTap: () async {
                final ok = await _showTextColorSelectDialog(
                  context: context,
                  title: const Text('Text color'),
                  initialColor: textColor,
                  nullable: true,
                  onChanged: (value) {
                    ref.read(textColorProvider.notifier).state = value;
                  },
                );
                if (ok) {
                  await saveThemePreferences(ref);
                }
              },
            ),
            ListTile(
              title: const Text('Background color'),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: mi.ColorChip(color: backgroundColor),
              ),
              onTap: () async {
                final ok = await _showBackgroundColorSelectDialog(
                  context: context,
                  title: const Text('Background color'),
                  initialColor: backgroundColor,
                  nullable: true,
                  onChanged: (value) {
                    ref.read(backgroundColorProvider.notifier).state = value;
                  },
                );
                if (ok) {
                  await saveThemePreferences(ref);
                }
              },
            ),
            CheckboxListTile(
              value: ref.watch(brightnessProvider).isDark,
              title: const Text('Dark'),
              onChanged: (value) async {
                ref.read(brightnessProvider.notifier).state =
                    value! ? Brightness.dark : Brightness.light;
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
              value: ref.watch(modifyThemeProvider),
              title: const Text('Modify theme'),
              onChanged: (value) {
                ref.read(modifyThemeProvider.notifier).state = value!;
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Reset preferences'),
              trailing: const Icon(Icons.navigate_next),
              onTap: () async {
                final ok = await mi.showWarningOkCancelDialog(
                  context: context,
                  content: const Text('Are you sure to reset theme preferences?'),
                );
                if (ok) {
                  await clearThemePreferences(ref);
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ex.BottomNavigationBar(),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
