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

Future<bool> _showTabbedColorSelectDialog({
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
        height: MediaQuery.of(context).size.height * 0.4,
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

Future<bool> _showSimpleColorSelectDialog({
  required BuildContext context,
  Widget? title,
  Color? initialColor,
  required List<Color?> colors,
  required List<String> tooltips,
  void Function(int colorIndex)? onChanged,
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
        height: MediaQuery.of(context).size.height * 0.4,
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: MiColorGrid(
                colors: colors,
                tooltips: tooltips,
                onChanged: (colorIndex) {
                  setState(() => color = colors[colorIndex]);
                  onChanged?.call(colorIndex);
                },
              ),
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

  final ok = await _showTabbedColorSelectDialog(
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

Future<bool> showTextColorSelectDialog({
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
    ...primaryColorNames.map((it) => '${it}900'),
  ];

  final ok = await _showSimpleColorSelectDialog(
      context: context,
      title: title,
      initialColor: initialColor,
      colors: colors,
      tooltips: tooltips,
      onChanged: (colorIndex) {
        onChanged?.call(colors[colorIndex]);
      });
  if (!ok) {
    onChanged?.call(initialColor);
  }
  return ok;
}

Future<bool> showBackgroundColorSelectDialog({
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
    ...primaryColorNames.map((it) => '${it}50'),
    'grey100',
    ...primaryColorNames.map((it) => '${it}100'),
  ];

  final ok = await _showSimpleColorSelectDialog(
      context: context,
      title: title,
      initialColor: initialColor,
      colors: colors,
      tooltips: tooltips,
      onChanged: (colorIndex) {
        onChanged?.call(colors[colorIndex]);
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

    final primarySwatch = ref.watch(primarySwatchProvider);
    final secondaryColor = ref.watch(secondaryColorProvider);
    final textColor = ref.watch(textColorProvider);
    final backgroundColor = ref.watch(backgroundColorProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: ExAppBar(
        prominent: ref.watch(prominentProvider),
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
                child: MiColorChip(color: primarySwatch),
              ),
              onTap: () async {
                final ok = await showColorSelectDialog(
                  context: context,
                  title: const Text('Primary swatch'),
                  initialColor: primarySwatch,
                  onChanged: (value) {
                    ref.read(primarySwatchProvider.notifier).state = value!.toMaterialColor();
                  },
                );
                if (ok) {
                  await savePreferences(ref);
                }
              },
            ),
            ListTile(
              title: const Text('Secondary color'),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: MiColorChip(color: secondaryColor),
              ),
              onTap: () async {
                final ok = await showColorSelectDialog(
                  context: context,
                  title: const Text('Secondary color'),
                  initialColor: secondaryColor,
                  nullable: true,
                  onChanged: (value) {
                    ref.read(secondaryColorProvider.notifier).state = value;
                  },
                );
                if (ok) {
                  await savePreferences(ref);
                }
              },
            ),
            ListTile(
              title: const Text('Text color'),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: MiColorChip(color: textColor),
              ),
              onTap: () async {
                final ok = await showTextColorSelectDialog(
                  context: context,
                  title: const Text('Text color'),
                  initialColor: textColor,
                  nullable: true,
                  onChanged: (value) {
                    ref.read(textColorProvider.notifier).state = value;
                  },
                );
                if (ok) {
                  await savePreferences(ref);
                }
              },
            ),
            ListTile(
              title: const Text('Background color'),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: MiColorChip(color: backgroundColor),
              ),
              onTap: () async {
                final ok = await showBackgroundColorSelectDialog(
                  context: context,
                  title: const Text('Background color'),
                  initialColor: backgroundColor,
                  nullable: true,
                  onChanged: (value) {
                    ref.read(backgroundColorProvider.notifier).state = value;
                  },
                );
                if (ok) {
                  await savePreferences(ref);
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
              value: ref.watch(themeAdjustmentProvider),
              title: const Text('Modify theme'),
              onChanged: (value) {
                ref.read(themeAdjustmentProvider.notifier).state = value!;
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Reset preferences'),
              onTap: () async {
                final ok = await showWarningOkCancelDialog(
                  context: context,
                  content: const Text('Are you sure to reset all preferences?'),
                );
                if (ok) {
                  await clearPreferences(ref);
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ExBottomNavigationBar(),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
