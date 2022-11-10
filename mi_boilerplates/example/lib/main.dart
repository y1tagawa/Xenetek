// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/animations_page.dart';
import 'pages/buttons_page.dart';
import 'pages/checks_page.dart';
import 'pages/colors_page.dart';
import 'pages/dialogs_page.dart';
import 'pages/embedded_tab_view_page.dart';
import 'pages/ex_app_bar.dart';
import 'pages/list_tiles_page.dart';
import 'pages/lists_page.dart';
import 'pages/menus_page.dart';
import 'pages/overflow_bar_page.dart';
import 'pages/progress_indicators_page.dart';
import 'pages/prominent_top_bar_page.dart';
import 'pages/radios_page.dart';
import 'pages/settings_page.dart';
import 'pages/snack_bar_page.dart';
import 'pages/svg_page.dart';
import 'pages/switches_page.dart';
import 'pages/tab_view_page.dart';

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
    icon: MenusPage.icon,
    title: MenusPage.title,
    path: '/menus',
    builder: (_, __) => const MenusPage(),
  ),
  _PageItem(
    icon: OverflowBarPage.icon,
    title: OverflowBarPage.title,
    path: '/overflow_bar',
    builder: (_, __) => const OverflowBarPage(),
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
    path: '/progress_indicators',
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
    path: '/drawer/settings',
    builder: (_, __) => const SettingsPage(),
  ),
  _PageItem(
    icon: SnackBarPage.icon,
    title: SnackBarPage.title,
    path: '/snack_bar',
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
final backgroundColorProvider = StateProvider<Color?>((ref) => _initColor);
final brightnessProvider = StateProvider((ref) => Brightness.dark);
final useM3Provider = StateProvider((ref) => false);
final themeAdjustmentProvider = StateProvider((ref) => true);

final preferencesProvider = FutureProvider((ref) async {
  final logger = Logger('preferenceProvider');

  final preferences = await SharedPreferences.getInstance();

  Color? colorOrNull(String? data) {
    return data?.let((it) => int.tryParse(it))?.let((it) => Color(it));
  }

  ref.read(primarySwatchProvider.notifier).state = preferences
      .getString('primary_swatch')
      .also((it) => logger.fine('primary_swatch=$it'))
      .let((it) => colorOrNull(it)?.toMaterialColor() ?? Colors.indigo);

  ref.read(secondaryColorProvider.notifier).state = preferences
      .getString('secondary_color')
      .also((it) => logger.fine('secondary_color=$it'))
      .let((it) => colorOrNull(it));

  ref.read(backgroundColorProvider.notifier).state = preferences
      .getString('background_color')
      .also((it) => logger.fine('background_color=$it'))
      .let((it) => colorOrNull(it));

  ref.read(brightnessProvider.notifier).state = preferences
      .getString('brightness')
      .also((it) => logger.fine('brightness=$it'))
      .let((it) => it == 'dark' ? Brightness.dark : Brightness.light);

  return preferences;
});

Future<void> savePreferences(WidgetRef ref) async {
  final logger = Logger('savePreferences');

  final preferences = ref.read(preferencesProvider).value;
  if (preferences != null) {
    preferences.setString(
      'primary_swatch',
      (ref.read(primarySwatchProvider).value.toString())
          .also((it) => logger.fine('primary_swatch=$it')),
    );
    preferences.setString(
      'secondary_color',
      (ref.read(secondaryColorProvider)?.value)
          .toString()
          .also((it) => logger.fine('secondary_color=$it')),
    );
    preferences.setString(
      'background_color',
      (ref.read(backgroundColorProvider)?.value)
          .toString()
          .also((it) => logger.fine('background_color=$it')),
    );
    preferences.setString(
      'brightness',
      (ref.read(brightnessProvider).isDark ? 'dark' : 'light')
          .also((it) => logger.fine('brightness=$it')),
    );
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

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  // ignore: unused_field
  static final _logger = Logger((HomePage).toString());

  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(preferencesProvider);

    final textTheme = Theme.of(context).textTheme;

    final primarySwatch = ref.watch(primarySwatchProvider);
    final secondaryColor = ref.watch(secondaryColorProvider);
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
          ).let(
            //
            (it) => it.copyWith(
              onPrimary: brightness.isDark ? null : backgroundColor,
              onSurface: brightness.isDark ? backgroundColor : null,
            ),
          ),
          //
          textTheme: brightness.isDark
              ? textTheme.apply(
                  bodyColor: backgroundColor,
                  displayColor: backgroundColor,
                )
              : textTheme,
          scaffoldBackgroundColor: brightness.isDark ? null : backgroundColor, //
          useMaterial3: ref.watch(useM3Provider),
        ).let((it) => ref.watch(themeAdjustmentProvider) ? it.adjust() : it),
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

    return Scaffold(
      appBar: ExAppBar(
        prominent: ref.watch(prominentProvider),
        icon: icon,
        title: title,
      ),
      drawer: Drawer(
        child: Expanded(
          // background
          child: InkWell(
            onTap: () => Navigator.pop(context),
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
                    .whereNot((item) => item.path.startsWith('/drawer/'))
                    .map(
                      (item) => TextButton(
                        onPressed: () => context.push(item.path),
                        child: Container(
                          width: 76,
                          height: 72,
                          padding: const EdgeInsets.all(2),
                          child: Column(
                            children: [item.icon, item.title],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const ExBottomNavigationBar(),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
