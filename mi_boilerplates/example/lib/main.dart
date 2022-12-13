// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;
import 'package:shared_preferences/shared_preferences.dart';

import '../licenses.dart';
import 'pages/animations_page.dart';
import 'pages/audio_player_page.dart';
import 'pages/buttons_page.dart';
import 'pages/checks_page.dart';
import 'pages/colors_page.dart';
import 'pages/custom_paints_page.dart';
import 'pages/dialogs_page.dart';
import 'pages/embedded_tab_view_page.dart';
import 'pages/ex_app_bar.dart' as ex;
import 'pages/files_page.dart';
import 'pages/grids_page.dart';
import 'pages/list_tiles_page.dart';
import 'pages/lists_page.dart';
import 'pages/overflow_bar_page.dart';
import 'pages/page_layouts_page.dart';
import 'pages/page_view_page.dart';
import 'pages/progress_indicators_page.dart';
import 'pages/prominent_top_bar_page.dart';
import 'pages/radios_page.dart';
import 'pages/settings_page.dart';
import 'pages/snack_bar_page.dart';
import 'pages/svg_page.dart';
import 'pages/switches_page.dart';
import 'pages/tab_view_page.dart';
import 'pages/three_page.dart';

class _PageItem {
  final Widget icon;
  final Widget title;
  final String path;
  final Widget Function(BuildContext, GoRouterState) builder;
  const _PageItem({
    required this.icon,
    required this.title,
    required this.path,
    required this.builder,
  });
}

final _pages = <_PageItem>[
  _PageItem(
    icon: HomePage.icon,
    title: HomePage.title,
    path: '/',
    builder: (_, __) => const HomePage(),
  ),
  _PageItem(
    icon: AnimationsPage.icon,
    title: AnimationsPage.title,
    path: '/animations',
    builder: (_, __) => const AnimationsPage(),
  ),
  _PageItem(
    icon: AudioPlayerPage.icon,
    title: AudioPlayerPage.title,
    path: '/audio_player',
    builder: (_, __) => const AudioPlayerPage(),
  ),
  _PageItem(
    icon: ButtonsPage.icon,
    title: ButtonsPage.title,
    path: '/buttons',
    builder: (_, __) => const ButtonsPage(),
  ),
  _PageItem(
    icon: ChecksPage.icon,
    title: ChecksPage.title,
    path: '/checks',
    builder: (_, __) => const ChecksPage(),
  ),
  _PageItem(
    icon: ColorsPage.icon,
    title: ColorsPage.title,
    path: '/colors',
    builder: (_, __) => const ColorsPage(),
  ),
  _PageItem(
    icon: CustomPaintsPage.icon,
    title: CustomPaintsPage.title,
    path: '/custom_paints',
    builder: (_, __) => const CustomPaintsPage(),
  ),
  _PageItem(
    icon: DialogsPage.icon,
    title: DialogsPage.title,
    path: '/dialogs',
    builder: (_, __) => const DialogsPage(),
  ),
  _PageItem(
    icon: EmbeddedTabViewPage.icon,
    title: EmbeddedTabViewPage.title,
    path: '/drawer/embedded_tab_view',
    builder: (_, __) => const EmbeddedTabViewPage(),
  ),
  _PageItem(
    icon: FilesPage.icon,
    title: FilesPage.title,
    path: '/drawer/files',
    builder: (_, __) => const FilesPage(),
  ),
  _PageItem(
    icon: GridsPage.icon,
    title: GridsPage.title,
    path: '/drawer/grids',
    builder: (_, __) => const GridsPage(),
  ),
  _PageItem(
    icon: GridsPage.icon,
    title: GridsPage.title,
    path: '/grids/detail',
    builder: (_, __) => const GridDetailPage(),
  ),
  _PageItem(
    icon: ListsPage.icon,
    title: ListsPage.title,
    path: '/lists',
    builder: (_, __) => const ListsPage(),
  ),
  _PageItem(
    icon: ListTilesPage.icon,
    title: ListTilesPage.title,
    path: '/drawer/list_tiles',
    builder: (_, __) => const ListTilesPage(),
  ),
  _PageItem(
    icon: OverflowBarPage.icon,
    title: OverflowBarPage.title,
    path: '/overflow_bar',
    builder: (_, __) => const OverflowBarPage(),
  ),
  _PageItem(
    icon: PageLayoutsPage.icon,
    title: PageLayoutsPage.title,
    path: '/drawer/page_layouts',
    builder: (_, __) => const PageLayoutsPage(),
  ),
  _PageItem(
    icon: PageViewPage.icon,
    title: PageViewPage.title,
    path: '/page_view',
    builder: (_, __) => const PageViewPage(),
  ),
  _PageItem(
    icon: ProminentTopBarPage.icon,
    title: ProminentTopBarPage.title,
    path: '/drawer/prominent_top_bar',
    builder: (_, __) => const ProminentTopBarPage(),
  ),
  _PageItem(
    icon: ProgressIndicatorsPage.icon,
    title: ProgressIndicatorsPage.title,
    path: '/drawer/progress_indicators',
    builder: (_, __) => const ProgressIndicatorsPage(),
  ),
  _PageItem(
    icon: RadiosPage.icon,
    title: RadiosPage.title,
    path: '/radios',
    builder: (_, __) => const RadiosPage(),
  ),
  _PageItem(
    icon: SettingsPage.icon,
    title: SettingsPage.title,
    path: '/settings',
    builder: (_, __) => const SettingsPage(),
  ),
  _PageItem(
    icon: SnackBarPage.icon,
    title: SnackBarPage.title,
    path: '/drawer/snack_bar',
    builder: (_, __) => const SnackBarPage(),
  ),
  _PageItem(
    icon: SvgPage.icon,
    title: SvgPage.title,
    path: '/svg',
    builder: (_, __) => const SvgPage(),
  ),
  _PageItem(
    icon: SwitchesPage.icon,
    title: SwitchesPage.title,
    path: '/switches',
    builder: (_, __) => const SwitchesPage(),
  ),
  _PageItem(
    icon: TabViewPage.icon,
    title: TabViewPage.title,
    path: '/tab_view',
    builder: (_, __) => const TabViewPage(),
  ),
  _PageItem(
    icon: ThreePage.icon,
    title: ThreePage.title,
    path: '/three',
    builder: (_, __) => const ThreePage(),
  ),
];

final _router = GoRouter(
  routes: _pages
      .map(
        (item) => GoRoute(
          path: item.path,
          builder: item.builder,
        ),
      )
      .toList(),
);

// テーマ設定
// ダークテーマの時に最初に明るい画面が出ないよう、初期値は暗くしておく
const _initColor = Color(0xFF404040);
final primarySwatchProvider = StateProvider((ref) => _initColor.toMaterialColor());
final secondaryColorProvider = StateProvider<Color?>((ref) => _initColor);
final textColorProvider = StateProvider<Color?>((ref) => _initColor);
final backgroundColorProvider = StateProvider<Color?>((ref) => _initColor);
final brightnessProvider = StateProvider((ref) => Brightness.dark);
final useM3Provider = StateProvider((ref) => false);
final modifyThemeProvider = StateProvider((ref) => true);

final preferencesProvider = FutureProvider((ref) async {
  final logger = Logger('preferenceProvider');

  final preferences = await SharedPreferences.getInstance();

  final data = preferences.getString('theme')?.let((it) => jsonDecode(it));

  logger.fine('theme preferences=$data');
  Color? colorOrNull(String key) {
    if (data is Map<String, dynamic>) {
      final value = data[key];
      if (value is String) {
        return int.tryParse(value)?.let((it) => Color(it));
      }
    }
    return null;
  }

  ref.read(primarySwatchProvider.notifier).state =
      colorOrNull('primary_swatch')?.toMaterialColor().toMaterialColor() ?? Colors.indigo;
  ref.read(secondaryColorProvider.notifier).state = colorOrNull('secondary_color');
  ref.read(textColorProvider.notifier).state = colorOrNull('text_color');
  ref.read(backgroundColorProvider.notifier).state = colorOrNull('background_color');

  ref.read(brightnessProvider.notifier).state =
      WidgetsBinding.instance.window.platformBrightness.also((it) => logger.fine('brightness=$it'));

  return preferences;
});

Future<void> saveThemePreferences(WidgetRef ref) async {
  final logger = Logger('saveThemePreferences');

  final preferences = ref.read(preferencesProvider).value;
  if (preferences != null) {
    final data = <String, dynamic>{
      'primary_swatch': (ref.read(primarySwatchProvider).value.toString()),
      'secondary_color': (ref.read(secondaryColorProvider)?.value).toString(),
      'text_color': (ref.read(textColorProvider)?.value).toString(),
      'background_color': (ref.read(backgroundColorProvider)?.value).toString(),
    };
    logger.fine('theme preferences=$data');
    preferences.setString('theme', jsonEncode(data));
  }
}

Future<void> clearThemePreferences(WidgetRef ref) async {
  final preferences = ref.read(preferencesProvider).value;
  if (preferences != null) {
    await preferences.remove('theme');
    ref.invalidate(preferencesProvider);
  }
}

Future<void> clearPreferences(WidgetRef ref) async {
  final preferences = ref.read(preferencesProvider).value;
  if (preferences != null) {
    await preferences.clear();
    ref.invalidate(preferencesProvider);
  }
}

// main

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    log('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });

  addLicenses();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  // ignore: unused_field
  static final _logger = Logger((MyApp).toString());

  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(preferencesProvider);

    final primarySwatch = ref.watch(primarySwatchProvider);
    final secondaryColor = ref.watch(secondaryColorProvider);
    final textColor = ref.watch(textColorProvider);
    final backgroundColor = ref.watch(backgroundColorProvider);
    final brightness = ref.watch(brightnessProvider);

    return Material(
      child: MaterialApp.router(
        routeInformationProvider: _router.routeInformationProvider,
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: 'Mi boilerplates example.',
        theme: ThemeData(
          primarySwatch: primarySwatch,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: primarySwatch,
            accentColor: brightness.isDark ? secondaryColor : null,
            brightness: brightness,
          ),
          useMaterial3: ref.watch(useM3Provider),
        ).let(
          (it) => ref.watch(modifyThemeProvider)
              ? it.modify(
                  textColor: textColor,
                  backgroundColor: backgroundColor,
                )
              : it,
        ),
      ),
    );
  }
}

// サンプルアプリ ホームページ

class HomePage extends ConsumerWidget {
  static const icon = Icon(Icons.home_outlined);
  static const title = Text('Home');

  static final _logger = Logger((HomePage).toString());

  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final theme = Theme.of(context);

    return Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: icon,
        title: title,
      ),
      drawer: Drawer(
        child: ListView(
          shrinkWrap: true,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const DrawerHeader(
                child: HomePage.title,
              ),
            ),
            ..._pages
                .skip(1) // Home
                .where((item) => item.path.startsWith('/drawer/'))
                .map(
                  (item) => ListTile(
                    leading: item.icon,
                    title: item.title,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(item.path);
                    },
                  ),
                ),
          ],
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Center(
            child: Wrap(
              spacing: 2,
              runSpacing: 8,
              children: [
                ..._pages
                    .skip(1) // Home
                    .whereNot((item) =>
                        item.path.startsWith('/drawer/') ||
                        item.path.startsWith('/grids/') ||
                        item.path == '/settings')
                    .map(
                      (item) => TextButton(
                        onPressed: () => context.push(item.path),
                        child: Container(
                          alignment: Alignment.center,
                          width: 76,
                          height: 72,
                          padding: const EdgeInsets.all(2),
                          child: Column(
                            children: [
                              item.icon,
                              DefaultTextStyle.merge(
                                textAlign: TextAlign.center,
                                child: item.title,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const ex.BottomNavigationBar(),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
