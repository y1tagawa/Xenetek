// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
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
import 'pages/sliders_page.dart';
import 'pages/snack_bar_page.dart';
import 'pages/svg_page.dart';
import 'pages/switches_page.dart';
import 'pages/tab_view_page.dart';
import 'pages/three_page.dart';
import 'pages/three_tier_page.dart';

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
    icon: _HomePage.icon,
    title: _HomePage.title,
    path: '/',
    builder: (_, __) => const mi.HomePageHelper(child: _HomePage()),
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
    path: '/drawer/overflow_bar',
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
    path: '/drawer/page_view',
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
    icon: SlidersPage.icon,
    title: SlidersPage.title,
    path: '/sliders',
    builder: (_, __) => const SlidersPage(),
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
  _PageItem(
    icon: ThreeTierPage.icon,
    title: ThreeTierPage.title,
    path: '/three_tier',
    builder: (_, __) => const ThreeTierPage(),
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
const _initColor = mi.SerializableColor(Color(0xFF404040));
const _defaultColorSettings = mi.ColorSettings(
  primarySwatch: mi.SerializableColor(Colors.indigo),
);

final colorSettingsStream = StreamController<mi.ColorSettings>();
final colorSettingsProvider = StreamProvider<mi.ColorSettings>(
  (ref) async* {
    final logger = Logger('colorSettingsProvider');
    await loadColorSettings();
    await for (final data in colorSettingsStream.stream) {
      yield data;
    }
  },
);

final brightnessProvider =
    StateProvider((ref) => WidgetsBinding.instance.window.platformBrightness);
//    Brightness.dark);
final useM3Provider = StateProvider((ref) => false);
final modifyThemeProvider = StateProvider((ref) => true);

Future<bool> loadColorSettings() async {
  final logger = Logger('loadColorSettings');
  final sp = await SharedPreferences.getInstance();
  final json = sp.getString('colorSettings');
  logger.fine('json=$json');
  var data = mi.ColorSettings.fromJson(json);
  if (data.primarySwatch.value == null) {
    data = data.copyWith(
      primarySwatch: const mi.SerializableColor(Colors.indigo),
    );
  }
  logger.fine('data=${data.toString()}');
  colorSettingsStream.add(data);
  return true;
}

Future<void> saveThemePreferences(WidgetRef ref) async {
  final logger = Logger('saveThemePreferences');

  ref.read(colorSettingsProvider).when(
        data: (data) async {
          final sp = await SharedPreferences.getInstance();
          sp.setString('colorSettings', data.toJson());
        },
        error: (error, stackTrace) {
          debugPrintStack(stackTrace: stackTrace, label: error.toString());
        },
        loading: () {},
      );
}

Future<void> clearPreferences(WidgetRef ref) async {
  final logger = Logger('clearPreferences');
  final sp = await SharedPreferences.getInstance();
  final ok = await sp.clear();
  logger.fine('cleared ok=$ok');
  await loadColorSettings();
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
    final colorSettings = ref.watch(colorSettingsProvider).when(
      data: (data) {
        _logger.fine('colorSettings=${data.toString()}');
        return data;
      },
      error: (error, stackTrace) {
        debugPrintStack(stackTrace: stackTrace, label: error.toString());
        return _defaultColorSettings;
      },
      loading: () {
        _logger.fine('Loading: colorSettings=$_defaultColorSettings');
        return _defaultColorSettings;
      },
    );
    final brightness = ref.watch(brightnessProvider);

    return Material(
      child: MaterialApp.router(
        routeInformationProvider: _router.routeInformationProvider,
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: 'Mi boilerplates example.',
        theme: mi.ThemeDataHelper.fromColorSettings(
          primarySwatch: colorSettings.primarySwatch.value?.toMaterialColor() ?? Colors.indigo,
          secondaryColor: colorSettings.secondaryColor.value,
          textColor: colorSettings.textColor.value,
          backgroundColor: colorSettings.backgroundColor.value,
          brightness: brightness,
          useMaterial3: ref.watch(useM3Provider),
          doModify: ref.watch(modifyThemeProvider),
        ),
      ),
    );
  }
}

// サンプルアプリ ホームページ

class _HomePage extends ConsumerWidget {
  static const icon = Icon(Icons.home_outlined);
  static const title = Text('Home');

  static final _logger = Logger((_HomePage).toString());

  // ignore: unused_element
  const _HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    return ex.Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: icon,
        title: title,
      ),
      drawer: mi.Drawer(
        onBackButtonPressed: () => Navigator.pop(context),
        children: _pages
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
            )
            .toList(),
      ),
      body: SingleChildScrollView(
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
      bottomNavigationBar: const ex.BottomNavigationBar(),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
