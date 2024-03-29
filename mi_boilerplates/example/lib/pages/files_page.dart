// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;
import 'package:path_provider/path_provider.dart';

import 'ex_app_bar.dart' as ex;
import 'ex_widgets.dart' as ex;

//
// File I/O examples page.
//

class FilesPage extends ConsumerWidget {
  static const icon = Icon(Icons.create_new_folder_outlined);
  static const title = Text('Files');

  static final _logger = Logger((FilesPage).toString());

  static const _tabs = <Widget>[
    mi.Tab(
      tooltip: 'Paths & pickers',
      icon: icon,
    ),
    mi.Tab(
      tooltip: ex.UnderConstruction.title,
      icon: ex.UnderConstruction.icon,
    ),
  ];

  const FilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);

    return mi.DefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
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
              _PathsTab(),
              ex.UnderConstruction(),
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
// Path provider & pickers tab
//

class _Paths {
  final Directory applicationDocumentsDirectory;
  final Directory applicationSupportDirectory;
  final Directory temporaryDirectory;
  const _Paths({
    required this.applicationDocumentsDirectory,
    required this.applicationSupportDirectory,
    required this.temporaryDirectory,
  });
}

final _pathsProvider = FutureProvider((ref) async {
  return _Paths(
    applicationDocumentsDirectory: await getApplicationDocumentsDirectory(),
    applicationSupportDirectory: await getApplicationSupportDirectory(),
    temporaryDirectory: await getTemporaryDirectory(),
  );
});

class _PathsTab extends ConsumerWidget {
  static final _logger = Logger((_PathsTab).toString());

  const _PathsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(ex.enableActionsProvider);

    final paths = ref.watch(_pathsProvider).value;

    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          if (paths != null) ...[
            ListTile(
              title: const Text('Application documents directory'),
              subtitle: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(paths.applicationDocumentsDirectory.path),
              ),
              textColor: theme.disabledColor,
            ),
            ListTile(
              title: const Text('Application support directory'),
              subtitle: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(paths.applicationSupportDirectory.path),
              ),
              textColor: theme.disabledColor,
            ),
            ListTile(
              title: const Text('Temporary directory'),
              subtitle: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(paths.temporaryDirectory.path),
              ),
              textColor: theme.disabledColor,
            ),
          ] else
            const CircularProgressIndicator(),
          const Divider(),
          ListTile(
            enabled: enabled,
            title: const Text('pickFiles()'),
            trailing: const Icon(Icons.navigate_next),
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                dialogTitle: 'Open',
                allowedExtensions: const ['.txt', '.md'],
              );
              _logger.fine('result=${result?.files}');
            },
          ),
        ],
      ),
    );
  }
}
