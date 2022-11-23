// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/data/primary_color_names.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import '../main.dart';
import 'ex_app_bar.dart';

//
// Color grid example page.
//

var _tabIndex = 0;

class ColorsPage extends ConsumerWidget {
  static const icon = Icon(Icons.palette_outlined);
  static const title = Text('Colors');

  static final _logger = Logger((ColorsPage).toString());

  static const _tabs = <Widget>[
    MiTab(
      tooltip: 'Theme & color scheme',
      icon: Icon(Icons.schema_outlined),
    ),
    MiTab(
      tooltip: 'Color grid',
      icon: Icon(Icons.grid_on_outlined),
    ),
  ];

  const ColorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);

    return MiDefaultTabController(
      length: _tabs.length,
      initialIndex: _tabIndex,
      builder: (context) {
        return Scaffold(
          appBar: ExAppBar(
            prominent: ref.watch(prominentProvider),
            icon: icon,
            title: title,
            bottom: ExTabBar(
              enabled: enabled,
              tabs: _tabs,
            ),
          ),
          body: const SafeArea(
            minimum: EdgeInsets.symmetric(horizontal: 8),
            child: TabBarView(
              children: [
                _ColorSchemeTab(),
                _ColorGridTab(),
              ],
            ),
          ),
          bottomNavigationBar: const ExBottomNavigationBar(),
        );
      },
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Color grid tab.
//

class _ColorGridTab extends ConsumerWidget {
  static final _logger = Logger((_ColorGridTab).toString());

  const _ColorGridTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    //final enabled = ref.watch(enableActionsProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: MiColorGrid(
                colors: Colors.primaries,
                tooltips: primaryColorNames,
                onChanged: (index) async {
                  final color = Colors.primaries[index];
                  ref.read(primarySwatchProvider.notifier).state = color.toMaterialColor();
                  await saveThemePreferences(ref);
                },
              ),
            ),
          ),
        ],
        //colorize
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
//　Theme and color scheme tab.
//

final _colorSchemeItems = <String, Color Function(ThemeData)>{
  'primary': (theme) => theme.colorScheme.primary,
  'onPrimary': (theme) => theme.colorScheme.onPrimary,
  'primaryContainer': (theme) => theme.colorScheme.primaryContainer,
  'onPrimaryContainer': (theme) => theme.colorScheme.onPrimaryContainer,
  'secondary': (theme) => theme.colorScheme.secondary,
  'onSecondary': (theme) => theme.colorScheme.onSecondary,
  'secondaryContainer': (theme) => theme.colorScheme.secondaryContainer,
  'onSecondaryContainer': (theme) => theme.colorScheme.onSecondaryContainer,
  'tertiary': (theme) => theme.colorScheme.tertiary,
  'onTertiary': (theme) => theme.colorScheme.onTertiary,
  'tertiaryContainer': (theme) => theme.colorScheme.tertiaryContainer,
  'onTertiaryContainer': (theme) => theme.colorScheme.onTertiaryContainer,
  'error': (theme) => theme.colorScheme.error,
  'onError': (theme) => theme.colorScheme.onError,
  'errorContainer': (theme) => theme.colorScheme.errorContainer,
  'onErrorContainer': (theme) => theme.colorScheme.onErrorContainer,
  'background': (theme) => theme.colorScheme.background,
  'onBackground': (theme) => theme.colorScheme.onBackground,
  'surface': (theme) => theme.colorScheme.surface,
  'onSurface': (theme) => theme.colorScheme.onSurface,
  'surfaceVariant': (theme) => theme.colorScheme.surfaceVariant,
  'onSurfaceVariant': (theme) => theme.colorScheme.onSurfaceVariant,
  'outline': (theme) => theme.colorScheme.outline,
  'shadow': (theme) => theme.colorScheme.shadow,
  'inverseSurface': (theme) => theme.colorScheme.inverseSurface,
  'onInverseSurface': (theme) => theme.colorScheme.onInverseSurface,
  'inversePrimary': (theme) => theme.colorScheme.inversePrimary,
  'surfaceTint': (theme) => theme.colorScheme.surfaceTint,
};

final _themeColorItems = <String, Color Function(ThemeData)>{
  'backgroundColor': (theme) => theme.backgroundColor,
  'bottomAppBarColor': (theme) => theme.bottomAppBarColor,
  'canvasColor': (theme) => theme.canvasColor,
  'cardColor': (theme) => theme.cardColor,
  'dialogBackgroundColor': (theme) => theme.dialogBackgroundColor,
  'disabledColor': (theme) => theme.disabledColor,
  'dividerColor': (theme) => theme.dividerColor,
  'errorColor': (theme) => theme.errorColor,
  'focusColor': (theme) => theme.focusColor,
  'highlightColor': (theme) => theme.highlightColor,
  'hintColor': (theme) => theme.hintColor,
  'hoverColor': (theme) => theme.hoverColor,
  'indicatorColor': (theme) => theme.indicatorColor,
  'primaryColor': (theme) => theme.primaryColor,
  'primaryColorDark': (theme) => theme.primaryColorDark,
  'primaryColorLight': (theme) => theme.primaryColorLight,
  'scaffoldBackgroundColor': (theme) => theme.scaffoldBackgroundColor,
  'secondaryHeaderColor': (theme) => theme.secondaryHeaderColor,
  'selectedRowColor': (theme) => theme.selectedRowColor,
  'shadowColor': (theme) => theme.shadowColor,
  'splashColor': (theme) => theme.splashColor,
  'toggleableActiveColor': (theme) => theme.toggleableActiveColor,
  'unselectedWidgetColor': (theme) => theme.unselectedWidgetColor,
};

class _ColorsListTile extends StatelessWidget {
  final Widget title;
  final ThemeData theme1;
  final ThemeData theme2;
  final Map<String, Color Function(ThemeData)> items;
  final bool initiallyExpanded;

  const _ColorsListTile({
    required this.title,
    required this.theme1,
    required this.theme2,
    required this.items,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return MiExpansionTile(
      title: title,
      initiallyExpanded: initiallyExpanded,
      children: items.keys.map((key) {
        return MiRow(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MiColorChip(color: items[key]!.call(theme1)),
            MiColorChip(color: items[key]!.call(theme2)),
            Text(key),
          ],
        );
      }).toList(),
    );
  }
}

class _SwatchView extends StatelessWidget {
  final MaterialColor color;

  const _SwatchView({required this.color});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [900, 800, 700, 600, 500, 400, 300, 200, 100, 50].map((index) {
        return MiColorChip(color: color[index]!);
      }).toList(),
    );
  }
}

final _selectedColorProvider = StateProvider<Color?>((ref) => null);
final _tileTestProvider = StateProvider((ref) => false);

class _ColorSchemeTab extends ConsumerWidget {
  static final _logger = Logger((_ColorSchemeTab).toString());

  const _ColorSchemeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final primarySwatch = ref.watch(primarySwatchProvider);
    final secondaryColor = ref.watch(secondaryColorProvider);
    final textColor = ref.watch(textColorProvider);
    final backgroundColor = ref.watch(backgroundColorProvider);
    final themeAdjustment = ref.watch(modifyThemeProvider);

    final selectedColor = ref.watch(_selectedColorProvider);

    final theme = Theme.of(context);

    final lightTheme = ThemeData(
      primarySwatch: primarySwatch,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primarySwatch,
        accentColor: secondaryColor,
        brightness: Brightness.light,
      ),
    ).let((it) => themeAdjustment
        ? it.modifyWith(
            textColor: textColor,
            backgroundColor: backgroundColor,
          )
        : it);

    final darkTheme = ThemeData(
      primarySwatch: primarySwatch,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primarySwatch,
        accentColor: secondaryColor,
        brightness: Brightness.dark,
      ),
    ).let((it) => themeAdjustment
        ? it.modifyWith(
            textColor: textColor,
            backgroundColor: backgroundColor,
          )
        : it);

    final tileTest = ref.watch(_tileTestProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ColorsListTile(
          title: const Text('Theme colors'),
          theme1: lightTheme,
          theme2: darkTheme,
          items: _themeColorItems,
        ),
        _ColorsListTile(
          title: const Text('Color scheme colors'),
          theme1: lightTheme,
          theme2: darkTheme,
          items: _colorSchemeItems,
        ),
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
