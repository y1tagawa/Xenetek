// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gradients/gradients.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import '../main.dart';
import 'ex_app_bar.dart' as ex;
import 'ex_color_grid.dart' as ex;

//
// Color example page.
//

var _tabIndex = 0;

class ColorsPage extends ConsumerWidget {
  static const icon = Icon(Icons.palette_outlined);
  static const title = Text('Colors');

  static final _logger = Logger((ColorsPage).toString());

  static const _tabs = <Widget>[
    mi.Tab(
      tooltip: 'Theme & color scheme',
      icon: Icon(Icons.schema_outlined),
    ),
    mi.Tab(
      tooltip: 'Color grid',
      icon: Icon(Icons.grid_on_outlined),
    ),
    mi.Tab(
      tooltip: 'Gradients',
      icon: Icon(Icons.gradient),
    ),
  ];

  const ColorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);

    return mi.DefaultTabController(
      length: _tabs.length,
      initialIndex: _tabIndex,
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
              _ColorSchemeTab(),
              _ColorGridTab(),
              _GradientTab(),
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
//　Theme and color scheme tab.
//

//<editor-fold>

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

class _ColorsView extends StatelessWidget {
  final Widget title;
  final ThemeData theme1;
  final ThemeData theme2;
  final Map<String, Color Function(ThemeData)> items;
  final ValueChanged<Color?>? onColorSelected;
  final bool initiallyExpanded;

  const _ColorsView({
    required this.title,
    required this.theme1,
    required this.theme2,
    required this.items,
    this.onColorSelected,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return mi.ExpansionTile(
      title: title,
      initiallyExpanded: initiallyExpanded,
      children: items.keys.map((key) {
        return mi.Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            items[key]!.call(theme1).let((color) => mi.ColorChip(
                  color: color,
                  onTap: () => onColorSelected?.call(color),
                )),
            items[key]!.call(theme2).let((color) => mi.ColorChip(
                  color: color,
                  onTap: () => onColorSelected?.call(color),
                )),
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
        return mi.ColorChip(color: color[index]!);
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
    final colorSettings = ref.watch(colorSettingsProvider);
    final doModify = ref.watch(modifyThemeProvider);

    final selectedColor = ref.watch(_selectedColorProvider);

    final lightTheme = mi.ThemeDataHelper.fromColorSettings(
      primarySwatch: colorSettings.primarySwatch.value?.toMaterialColor() ?? Colors.indigo,
      secondaryColor: colorSettings.secondaryColor.value,
      textColor: colorSettings.textColor.value,
      brightness: Brightness.light,
      doModify: doModify,
    );

    final darkTheme = mi.ThemeDataHelper.fromColorSettings(
      primarySwatch: colorSettings.primarySwatch.value?.toMaterialColor() ?? Colors.indigo,
      secondaryColor: colorSettings.secondaryColor.value,
      textColor: colorSettings.textColor.value,
      brightness: Brightness.dark,
      doModify: doModify,
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ColorsView(
                  title: const Text('Theme colors'),
                  theme1: lightTheme,
                  theme2: darkTheme,
                  items: _themeColorItems,
                  onColorSelected: (color) {
                    ref.read(_selectedColorProvider.notifier).state = color;
                  },
                ),
                _ColorsView(
                  initiallyExpanded: true,
                  title: const Text('Color scheme colors'),
                  theme1: lightTheme,
                  theme2: darkTheme,
                  items: _colorSchemeItems,
                  onColorSelected: (color) {
                    ref.read(_selectedColorProvider.notifier).state = color;
                  },
                ),
              ],
            ),
          ),
        ),
        if (selectedColor != null)
          ListTile(
            title: const Text('Color swatch'),
            subtitle: _SwatchView(color: selectedColor.toMaterialColor()),
          )
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//</editor-fold>

//
// Color grid tab.
//

//<editor-fold>

final _selectedColorProvider2 = StateProvider<Color?>((ref) => null);

class _ColorGridTab extends ConsumerWidget {
  static final _logger = Logger((_ColorGridTab).toString());

  const _ColorGridTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    //final enabled = ref.watch(enableActionsProvider);
    final selectedColor = ref.watch(_selectedColorProvider2);

    return mi.ExpandedColumn(
      bottoms: [
        if (selectedColor != null) ...[
          const Divider(),
          ListTile(
            title: const Text('Color swatch'),
            subtitle: _SwatchView(color: selectedColor.toMaterialColor()),
          )
        ]
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ex.ColorGrid(
          onChanged: (color) {
            ref.read(_selectedColorProvider2.notifier).state = color;
          },
        ),
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//</editor-fold>

//
// Color grid tab.
//

//<editor-fold>

final _rgbColors = <Color>[
  const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 120.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 240.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 359.9, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 0.0, 0.0, 0.0).toColor(),
  const HSVColor.fromAHSV(1.0, 0.0, 0.0, 1.0).toColor(),
];

// Hueでループさせようとすると、HsbColorでないと上手くいかない。
const _hsbColors = <Color>[
  HsbColor(0.0, 100.0, 100.0),
  HsbColor(120.0, 100.0, 100.0),
  HsbColor(240.0, 100.0, 100.0),
  HsbColor(360.0, 100.0, 100.0),
  HsbColor(0.0, 0.0, 0.0),
  HsbColor(0.0, 0.0, 100.0),
];

const _stops = <double>[0.0, 0.25, 0.5, 0.75, 0.75, 1.0];

final _gradientItems = <String, Gradient>{
  // https://pub.dev/packages/gradients
  'HSV': LinearGradientPainter(colors: _hsbColors, stops: _stops, colorSpace: ColorSpace.hsb),
  'RGB': LinearGradient(colors: _rgbColors, stops: _stops),
}.entries.toList();

final _positionProvider = StateProvider((ref) => 0.0);
final _colorSpaceProvider = StateProvider((ref) => 0);
final _gradientImageProvider = StateProvider<Image?>((ref) => null);
final _gradientColorProvider = StateProvider<Color?>((ref) => null);

class _GradientTab extends ConsumerWidget {
  static final _logger = Logger((_GradientTab).toString());

  const _GradientTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);
    final position = ref.watch(_positionProvider);
    final colorSpace = ref.watch(_colorSpaceProvider);

    //final gradientImage = ref.watch(_gradientImageProvider);
    final gradientColor = ref.watch(_gradientColorProvider);

    Future<void> update() async {
      final gradient = _gradientItems[colorSpace].value;

      final image = await gradient.toImage();
      try {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        ref.read(_gradientImageProvider.notifier).state =
            Image.memory(Uint8List.view(byteData!.buffer));
      } finally {
        image.dispose();
      }

      final colors = await gradient.toColors();
      final color = colors[math.min((position * colors.length).toInt(), colors.length - 1)];
      ref.read(_gradientColorProvider.notifier).state = color;
    }

    if (gradientColor == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await update();
      });
    }

    return mi.ExpandedColumn(
      child: ListView(
        children: [
          ..._gradientItems.mapIndexed((index, item) {
            return ListTile(
              enabled: enabled,
              title: Text(item.key),
              selected: colorSpace == index,
              subtitle: Container(
                height: kToolbarHeight * 0.5,
                decoration: BoxDecoration(
                  gradient: item.value,
                ),
              ),
              onTap: () async {
                ref.read(_colorSpaceProvider.notifier).state = index;
                await update();
              },
            );
          }),
          const Divider(),
          ListTile(
            leading: ClipOval(
              child: mi.ColorChip(
                enabled: enabled,
                color: gradientColor,
                margin: 0,
                size: 36,
              ),
            ),
            title: Slider(
              value: position,
              min: 0.0,
              max: 1.0,
              onChanged: enabled
                  ? (position) async {
                      ref.read(_positionProvider.notifier).state = position;
                      await update();
                    }
                  : null,
            ),
          ),
          //if (gradientImage != null) gradientImage,
        ],
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//</editor-fold>
