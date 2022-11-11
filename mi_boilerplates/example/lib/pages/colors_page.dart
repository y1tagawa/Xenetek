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
      tooltip: 'Color grid',
      icon: Icon(Icons.grid_on_outlined),
    ),
    MiTab(
      tooltip: 'Theme & color scheme',
      icon: Icon(Icons.schema_outlined),
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
                _ColorGridTab(),
                _ColorSchemeTab(),
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

///
/// Color grid tab.
///

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

///
///　Theme and color scheme tab.
///

final _themeColorItems = <String, Color Function(ThemeData)>{
  //
  'colorScheme.primary': (theme) => theme.colorScheme.primary,
  'colorScheme.onPrimary': (theme) => theme.colorScheme.onPrimary,
  'colorScheme.secondary': (theme) => theme.colorScheme.secondary,
  'colorScheme.onSecondary': (theme) => theme.colorScheme.onSecondary,
  'colorScheme.background': (theme) => theme.colorScheme.background,
  'colorScheme.onBackground': (theme) => theme.colorScheme.onBackground,
  'colorScheme.surface': (theme) => theme.colorScheme.surface,
  'colorScheme.onSurface': (theme) => theme.colorScheme.onSurface,
  //
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
  //
  'backgroundColor': (theme) => theme.backgroundColor,
  'disabledColor': (theme) => theme.disabledColor,
  'canvasColor': (theme) => theme.canvasColor,
  'cardColor': (theme) => theme.cardColor,
  'selectedRowColor': (theme) => theme.selectedRowColor,
  'unselectedWidgetColor': (theme) => theme.unselectedWidgetColor,
  //
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

class _ColorSchemeTab extends ConsumerWidget {
  static final _logger = Logger((_ColorSchemeTab).toString());

  const _ColorSchemeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final primarySwatch = ref.watch(primarySwatchProvider);
    final secondaryColor = ref.watch(secondaryColorProvider);
    final backgroundColor = ref.watch(backgroundColorProvider);
    final themeAdjustment = ref.watch(themeAdjustmentProvider);

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
            backgroundColor: backgroundColor,
          )
        : it);

    Widget colorRow(String key, String title) {
      final getter = _themeColorItems[key]!;
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MiColorChip(color: getter(lightTheme)),
          const VerticalDivider(width: 3),
          MiColorChip(color: getter(darkTheme)),
          const VerticalDivider(width: 3),
          Text(title),
        ],
      );
    }

    Widget colorList(
      String title,
      Iterable<String> titleKeys,
      Iterable<String> childKeys,
    ) {
      final prefix = RegExp(r'^\w+\.');

      return ExpansionTile(
        initiallyExpanded: false,
        title: DefaultTextStyle.merge(
          style: TextStyle(color: theme.colorScheme.onSurface),
          child: Expanded(
            child: Column(
              children: [
                Text(title),
                ...titleKeys.map((key) => colorRow(key, key.replaceAll(prefix, '')))
              ],
            ),
          ),
        ),
        children: [
          Padding(
            // https://api.flutter.dev/flutter/material/ExpansionTile/tilePadding.html
            padding:
                theme.expansionTileTheme.tilePadding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: childKeys.map((key) => colorRow(key, key.replaceAll(prefix, ''))).toList(),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          colorList(
              'ThemeData',
              _themeColorItems.keys
                  .skipWhile((key) => key != 'backgroundColor')
                  .takeWhile((key) => key != 'bottomAppBarColor'),
              _themeColorItems.keys.skipWhile((key) => key != 'bottomAppBarColor')),
          colorList(
              'ThemeData.colorScheme',
              _themeColorItems.keys.takeWhile((key) => key != 'colorScheme.error'),
              _themeColorItems.keys
                  .skipWhile((key) => key != 'colorScheme.error')
                  .takeWhile((key) => key != 'backgroundColor')),
        ],
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
