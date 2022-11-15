// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:example/data/primary_color_names.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import '../main.dart';
import 'ex_app_bar.dart';

///
/// Color grid example page.
///

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
              isScrollable: true,
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
                  await savePreferences(ref);
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

final _colorSchemeItems1 = <String, Color Function(ThemeData)>{
  'colorScheme.primary': (theme) => theme.colorScheme.primary,
  'colorScheme.onPrimary': (theme) => theme.colorScheme.onPrimary,
  'colorScheme.secondary': (theme) => theme.colorScheme.secondary,
  'colorScheme.onSecondary': (theme) => theme.colorScheme.onSecondary,
  'colorScheme.background': (theme) => theme.colorScheme.background,
  'colorScheme.onBackground': (theme) => theme.colorScheme.onBackground,
  'colorScheme.surface': (theme) => theme.colorScheme.surface,
  'colorScheme.onSurface': (theme) => theme.colorScheme.onSurface,
};

final _colorSchemeItems2 = <String, Color Function(ThemeData)>{
  'colorScheme.error': (theme) => theme.colorScheme.error,
  'colorScheme.onError': (theme) => theme.colorScheme.onError,
  'colorScheme.primaryContainer': (theme) => theme.colorScheme.primaryContainer,
  'colorScheme.onPrimaryContainer': (theme) => theme.colorScheme.onPrimaryContainer,
  'colorScheme.secondaryContainer': (theme) => theme.colorScheme.secondaryContainer,
  'colorScheme.onSecondaryContainer': (theme) => theme.colorScheme.onSecondaryContainer,
  'colorScheme.tertiary': (theme) => theme.colorScheme.tertiary,
  'colorScheme.onTertiary': (theme) => theme.colorScheme.onTertiary,
  'colorScheme.tertiaryContainer': (theme) => theme.colorScheme.tertiaryContainer,
  'colorScheme.onTertiaryContainer': (theme) => theme.colorScheme.onTertiaryContainer,
  'colorScheme.errorContainer': (theme) => theme.colorScheme.errorContainer,
  'colorScheme.onErrorContainer': (theme) => theme.colorScheme.onErrorContainer,
  'colorScheme.surfaceVariant': (theme) => theme.colorScheme.surfaceVariant,
  'colorScheme.onSurfaceVariant': (theme) => theme.colorScheme.onSurfaceVariant,
  'colorScheme.outline': (theme) => theme.colorScheme.outline,
  'colorScheme.shadow': (theme) => theme.colorScheme.shadow,
  'colorScheme.inverseSurface': (theme) => theme.colorScheme.inverseSurface,
  'colorScheme.onInverseSurface': (theme) => theme.colorScheme.onInverseSurface,
  'colorScheme.inversePrimary': (theme) => theme.colorScheme.inversePrimary,
  'colorScheme.surfaceTint': (theme) => theme.colorScheme.surfaceTint,
};

final _themeColorItems1 = <String, Color Function(ThemeData)>{
  'backgroundColor': (theme) => theme.backgroundColor,
  'disabledColor': (theme) => theme.disabledColor,
  'canvasColor': (theme) => theme.canvasColor,
  'cardColor': (theme) => theme.cardColor,
  'selectedRowColor': (theme) => theme.selectedRowColor,
  'unselectedWidgetColor': (theme) => theme.unselectedWidgetColor,
};

final _themeColorItems2 = <String, Color Function(ThemeData)>{
  'bottomAppBarColor': (theme) => theme.bottomAppBarColor,
  'dialogBackgroundColor': (theme) => theme.dialogBackgroundColor,
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
  'shadowColor': (theme) => theme.shadowColor,
  'splashColor': (theme) => theme.splashColor,
  'toggleableActiveColor': (theme) => theme.toggleableActiveColor,
};

class _ColorsView extends StatelessWidget {
  final List<Color> colors1;
  final List<Color>? colors2;
  final List<String>? tooltips;
  final ValueChanged<Color>? onSelected;

  const _ColorsView({
    required this.colors1,
    required this.colors2,
    this.tooltips,
    this.onSelected,
  })  : assert(tooltips == null || tooltips.length == colors1.length),
        assert(colors2 == null || colors2.length == colors1.length);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 4,
      children: colors1.mapIndexed(
        (index, color) {
          return colors2 != null
              ? Tooltip(
                  message: tooltips?[index] ?? '',
                  child: Column(
                    children: [
                      MiColorChip(
                        color: color,
                        onTap: () => onSelected?.call(color),
                      ),
                      colors2![index].let(
                        (color2) => MiColorChip(
                          onTap: () => onSelected?.call(color2),
                          color: color2,
                        ),
                      ),
                    ],
                  ),
                )
              : MiColorChip(
                  color: color,
                  onTap: () => onSelected?.call(color),
                  tooltip: tooltips?[index],
                );
        },
      ).toList(),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(6),
            child: Text('Theme colors'),
          ),
          _ColorsView(
            colors1: _themeColorItems1.values.map((it) => it(lightTheme)).toList(),
            colors2: _themeColorItems1.values.map((it) => it(darkTheme)).toList(),
            tooltips: _themeColorItems1.keys.toList(),
            onSelected: (color) => ref.read(_selectedColorProvider.notifier).state = color,
          ),
          const SizedBox(height: 6),
          _ColorsView(
            colors1: _themeColorItems2.values.map((it) => it(lightTheme)).toList(),
            colors2: _themeColorItems2.values.map((it) => it(darkTheme)).toList(),
            tooltips: _themeColorItems2.keys.toList(),
            onSelected: (color) => ref.read(_selectedColorProvider.notifier).state = color,
          ),
          const Padding(
            padding: EdgeInsets.all(6),
            child: Text('Color scheme'),
          ),
          _ColorsView(
            colors1: _colorSchemeItems1.values.map((it) => it(lightTheme)).toList(),
            colors2: _colorSchemeItems1.values.map((it) => it(darkTheme)).toList(),
            tooltips: _colorSchemeItems1.keys.toList(),
            onSelected: (color) => ref.read(_selectedColorProvider.notifier).state = color,
          ),
          const SizedBox(height: 6),
          _ColorsView(
            colors1: _colorSchemeItems2.values.map((it) => it(lightTheme)).toList(),
            colors2: _colorSchemeItems2.values.map((it) => it(darkTheme)).toList(),
            tooltips: _colorSchemeItems2.keys.toList(),
            onSelected: (color) => ref.read(_selectedColorProvider.notifier).state = color,
          ),
          const Padding(
            padding: EdgeInsets.all(6),
            child: Text('Swatch'),
          ),
          if (selectedColor != null)
            _SwatchView(
              color: selectedColor!.toMaterialColor(),
            ),
        ],
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
