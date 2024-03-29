// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/pages/ex_color_grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import '../main.dart';
import 'ex_app_bar.dart' as ex;

const _nullIcon = Icon(Icons.block);

/// primarySwatchまたはsecondaryColor選択ダイアログ
Future<void> _showColorSelectDialog({
  required BuildContext context,
  Widget? title,
  required Color? initialColor,
  void Function(bool save, Color? value)? onChanged,
  bool nullable = false,
}) async {
  final ok = await mi.ColorGridHelper.showColorSelectDialog(
    context: context,
    title: title,
    initialColor: initialColor,
    nullIcon: _nullIcon,
    onChanged: (value) => onChanged?.call(false, value),
    builder: (_, onChanged) {
      return ColorGrid(
        onChanged: onChanged,
      );
    },
  );
  if (ok.key) {
    onChanged?.call(true, ok.value);
  } else {
    onChanged?.call(false, initialColor);
  }
}

/// textColor選択ダイアログ
Future<void> _showTextColorSelectDialog({
  required BuildContext context,
  Widget? title,
  required Color? initialColor,
  void Function(bool save, Color? value)? onChanged,
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
    nullIcon: _nullIcon,
    onChanged: (value) => onChanged?.call(false, value),
    builder: (_, onChanged_) {
      return SingleChildScrollView(
        child: mi.ColorGrid(
          colors: colors,
          nullIcon: _nullIcon,
          tooltips: tooltips,
          onChanged: (index) => onChanged_?.call(colors[index]),
        ),
      );
    },
  );
  if (ok.key) {
    onChanged?.call(true, ok.value);
  } else {
    onChanged?.call(false, initialColor);
  }
}

/// backgroundColor選択ダイアログ
Future<void> _showBackgroundColorSelectDialog({
  required BuildContext context,
  Widget? title,
  required Color? initialColor,
  void Function(bool save, Color? value)? onChanged,
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
    nullIcon: _nullIcon,
    onChanged: (value) => onChanged?.call(false, value),
    builder: (_, onChanged_) {
      return SingleChildScrollView(
        child: mi.ColorGrid(
          colors: colors,
          nullIcon: _nullIcon,
          tooltips: tooltips,
          onChanged: (index) => onChanged_?.call(colors[index]),
        ),
      );
    },
  );
  if (ok.key) {
    onChanged?.call(true, ok.value);
  } else {
    onChanged?.call(false, initialColor);
  }
}

//
// Exampleアプリの設定ページ
//

class SettingsPage extends ConsumerWidget {
  static const icon = Icon(Icons.settings_outlined);
  static const title = Text('Settings');

  static final _logger = Logger((SettingsPage).toString());

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    assert(mi.x11Colors.length == mi.x11ColorNames.length);

    return ref.watch(colorSettingsProvider).when(
      data: (data) {
        final theme = Theme.of(context);

        return ex.Scaffold(
          appBar: ex.AppBar(
            prominent: ref.watch(ex.prominentProvider),
            icon: icon,
            title: title,
          ),
          body: ListView(
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
                  child: mi.ColorChip(color: data.primarySwatch.value),
                ),
                onTap: () async {
                  await _showColorSelectDialog(
                    context: context,
                    title: const Text('Primary swatch'),
                    initialColor: data.primarySwatch.value,
                    onChanged: (save, value) async {
                      MyApp.setColorSettings(
                        data: data.copyWith(primarySwatch: mi.ColorOrNull(value)),
                        save: save,
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Secondary color'),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: mi.ColorChip(
                    color: data.secondaryColor.value,
                    nullIcon: _nullIcon,
                  ),
                ),
                onTap: () async {
                  await _showColorSelectDialog(
                    context: context,
                    title: const Text('Secondary color'),
                    initialColor: data.secondaryColor.value,
                    nullable: true,
                    onChanged: (save, value) {
                      MyApp.setColorSettings(
                        data: data.copyWith(secondaryColor: mi.ColorOrNull(value)),
                        save: save,
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Text color'),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: mi.ColorChip(
                    color: data.textColor.value,
                    nullIcon: _nullIcon,
                  ),
                ),
                onTap: () async {
                  await _showTextColorSelectDialog(
                    context: context,
                    title: const Text('Text color'),
                    initialColor: data.textColor.value,
                    nullable: true,
                    onChanged: (save, value) {
                      MyApp.setColorSettings(
                        data: data.copyWith(textColor: mi.ColorOrNull(value)),
                        save: save,
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Background color'),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: mi.ColorChip(
                    color: data.backgroundColor.value,
                    nullIcon: _nullIcon,
                  ),
                ),
                onTap: () async {
                  await _showBackgroundColorSelectDialog(
                    context: context,
                    title: const Text('Background color'),
                    initialColor: data.backgroundColor.value,
                    nullable: true,
                    onChanged: (save, value) {
                      MyApp.setColorSettings(
                        data: data.copyWith(backgroundColor: mi.ColorOrNull(value)),
                        save: save,
                      );
                    },
                  );
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
                value: data.useMaterial3,
                title: const Text('Use material 3'),
                onChanged: (value) async {
                  MyApp.setColorSettings(
                    data: data.copyWith(useMaterial3: value),
                    save: true,
                  );
                },
              ),
              const Divider(),
              Theme(
                data: theme.isDark ? ThemeData.dark() : ThemeData.light(),
                child: ListTile(
                  title: const Text('Reset preferences'),
                  onTap: () async {
                    final ok = await mi.showWarningOkCancelDialog(
                      context: context,
                      content: const Text('Are you sure to reset theme preferences?'),
                      theme: theme.isDark ? ThemeData.dark() : ThemeData.light(),
                    );
                    if (ok) {
                      await MyApp.clearPreferences();
                    }
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: const ex.BottomNavigationBar(),
        ).also((_) {
          _logger.fine('[o] build');
        });
      },
      error: (error, stackTrace) {
        debugPrintStack(stackTrace: stackTrace, label: error.toString());
        return Text(error.toString());
      },
      loading: () {
        return const Text('Loading');
      },
    );
  }
}
