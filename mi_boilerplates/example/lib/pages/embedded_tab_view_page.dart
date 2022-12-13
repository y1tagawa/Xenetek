// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;

///
/// Embedded tab view example page.
///

const _tabs = <Widget>[
  mi.Tab(
    icon: Icon(Icons.looks_one_outlined),
    text: 'One',
  ),
  mi.Tab(
    icon: Icon(Icons.looks_two_outlined),
    text: 'Two',
  ),
  mi.Tab(
    icon: Icon(Icons.looks_3_outlined),
    text: 'Three',
  ),
];

const _embeddedTabs = <Widget>[
  mi.Tab(
    icon: Icon(Icons.filter_1_outlined),
    text: 'One',
  ),
  mi.Tab(
    icon: Icon(Icons.filter_2_outlined),
    text: 'Two',
  ),
  mi.Tab(
    icon: Icon(Icons.filter_3_outlined),
    text: 'Three',
  ),
  mi.Tab(
    icon: Icon(Icons.filter_4_outlined),
    text: 'Three',
  ),
];

int _tabIndex = 0;
final _embeddedTabIndices = List<int>.generate(_tabs.length, (index) => 0);

class EmbeddedTabViewPage extends ConsumerWidget {
  static const icon = Icon(Icons.folder_copy_outlined);
  static const title = Text('Embedded tab view');

  static final _logger = Logger((EmbeddedTabViewPage).toString());

  const EmbeddedTabViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);

    return mi.DefaultTabController(
      length: _tabs.length,
      initialIndex: _tabIndex,
      onIndexChanged: (value) => _tabIndex = value,
      builder: (context) {
        return Scaffold(
          appBar: ex.AppBar(
            prominent: ref.watch(ex.prominentProvider),
            icon: icon,
            title: title,
            bottom: ex.TabBar(
              enabled: enabled,
              tabs: _tabs,
            ),
          ),
          body: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 8),
            child: TabBarView(
              physics: enabled ? null : const NeverScrollableScrollPhysics(),
              children: [
                ..._tabs.mapIndexed((index, _) => _EmbeddedTabViewTab(index)).toList(),
              ],
            ),
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
// Embedded tab view tab.
//

class _EmbeddedTabViewTab extends ConsumerWidget {
  static final _logger = Logger((_EmbeddedTabViewTab).toString());

  final int index;

  const _EmbeddedTabViewTab(this.index);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);

    return SingleChildScrollView(
      child: mi.DefaultTabController(
        length: _embeddedTabs.length,
        initialIndex: _embeddedTabIndices[index],
        onIndexChanged: (value) => _embeddedTabIndices[index] = value,
        builder: (context) {
          return Column(
            children: [
              ex.TabBar(
                enabled: enabled,
                embedded: true,
                tabs: _embeddedTabs,
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  children: [
                    ..._embeddedTabs.mapIndexed(
                      (index_, _) {
                        return Center(
                          child: Text('${index + 1} - ${index_ + 1}'),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
