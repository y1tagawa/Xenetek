// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;

var _tabIndex = 0;

class PageLayoutsPage extends ConsumerWidget {
  static const icon = Icon(Icons.view_day_outlined);
  static const title = Text('Page layouts');

  static final _logger = Logger((PageLayoutsPage).toString());

  static const _tabs = <Widget>[
    mi.Tab(
      tooltip: 'Expanded single child scroll view',
      icon: icon,
    ),
    mi.Tab(
      tooltip: 'Expanded list view',
      icon: Icon(Icons.list),
    ),
  ];

  const PageLayoutsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);

    return mi.DefaultTabController(
      length: _tabs.length,
      initialIndex: _tabIndex,
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
          body: const SafeArea(
            minimum: EdgeInsets.symmetric(horizontal: 8),
            child: TabBarView(
              children: [
                _ExpandedScrollViewTab(content: (SingleChildScrollView)),
                _ExpandedScrollViewTab(content: (ListView)),
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
// Expanded scroll view tab
//

final _lengthProvider = StateProvider((ref) => 1);

const _length = [1, 20];

class _ExpandedScrollViewTab extends ConsumerWidget {
  static final _logger = Logger((_ExpandedScrollViewTab).toString());

  final Type content;

  const _ExpandedScrollViewTab({required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final lengthIndex = ref.watch(_lengthProvider);
    final length = _length[lengthIndex];

    final theme = Theme.of(context);

    final content_ = mi.run(() {
      switch (content) {
        case (SingleChildScrollView):
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, top: 4, right: 24, bottom: 4),
              child: Container(
                width: double.infinity,
                height: kToolbarHeight * length,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text('Single child scroll view'),
              ),
            ),
          );

        default:
          return ListView.builder(
            itemCount: length,
            itemBuilder: (_, index) => ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text('List item #${index + 1}'),
            ),
          );
      }
    });

    return mi.ExpandedColumn(
      tops: [
        ListTile(
          title: const Text('Top'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<int>(
                value: 0,
                groupValue: lengthIndex,
                onChanged: (value) => ref.read(_lengthProvider.notifier).state = value!,
              ),
              const Text('1'),
              Radio<int>(
                value: 1,
                groupValue: lengthIndex,
                onChanged: (value) => ref.read(_lengthProvider.notifier).state = value!,
              ),
              const Text('20'),
            ],
          ),
        ),
        const Divider(),
      ],
      bottoms: const [
        Divider(),
        ListTile(
          title: Text('Bottom'),
        ),
      ],
      child: content_,
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
