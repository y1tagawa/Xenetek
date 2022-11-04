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

class MiEmbeddedTabView extends StatelessWidget {
  final List<Widget> tabs;
  final int initialIndex;
  final List<Widget> children;
  final double? spacing;

  const MiEmbeddedTabView({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    required this.children,
    this.spacing,
  }) : assert(tabs.length == children.length);

  @override
  Widget build(BuildContext context) {
    return MiDefaultTabController(
      length: tabs.length,
      initialIndex: initialIndex,
      builder: (context) {
        return Column(
          children: [
            MiTabBar(
              embedded: true,
              tabs: tabs,
            ),
            SizedBox(height: spacing ?? 4.0),
            Expanded(
              child: TabBarView(
                children: children,
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<bool> _showColorSelectDialog({
  required BuildContext context,
  Color? initialColor,
  required List<Widget> tabs,
  required List<List<Color?>> colors,
  required List<List<String>> tooltips,
  void Function(int tabIndex, int colorIndex)? onChanged,
}) async {
  Color? color = initialColor;

  return await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return MiOkCancelDialog<bool>(
          icon: MiColorChip(color: color),
          content: MiEmbeddedTabView(
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
          ),
          getValue: (ok) => ok,
        );
      },
    ),
  ).then((value) => value ?? false);
}

Future<bool> showColorSelectDialog({
  required BuildContext context,
  required Color? initialColor,
  void Function(Color? value)? onChanged,
  bool nullable = false,
}) async {
  const tabs = <Widget>[
    MiTab(text: 'F'),
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
/// Exampleアプリの設定ページ。
///

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
            // primarySwatch
            ListTile(
              title: const Text('Primary swatch'),
              trailing: MiIconButton(
                icon: MiColorChip(
                  color: ref.watch(primarySwatchProvider),
                ),
                onPressed: () async {
                  showColorSelectDialog(
                    context: context,
                    initialColor: ref.watch(primarySwatchProvider),
                    onChanged: (value) {
                      ref.read(primarySwatchProvider.state).state = value!.toMaterialColor();
                    },
                  );
                },
              ),
            ),
            ListTile(
              title: const Text('Secondary color'),
              trailing: MiIconButton(
                icon: MiColorChip(
                  color: ref.watch(secondaryColorProvider),
                ),
                onPressed: () async {
                  showColorSelectDialog(
                    context: context,
                    initialColor: ref.watch(secondaryColorProvider),
                    nullable: true,
                    onChanged: (value) {
                      ref.read(secondaryColorProvider.state).state = value;
                    },
                  );
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
              title: const Text('Adjust theme'),
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
