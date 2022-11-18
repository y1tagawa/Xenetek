// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

var _tabIndex = 0;

class PageLayoutsPage extends ConsumerWidget {
  static const icon = Icon(Icons.view_day_outlined);
  static const title = Text('Page layouts');

  static final _logger = Logger((PageLayoutsPage).toString());

  static const _tabs = <Widget>[
    MiTab(
      tooltip: 'Framed single child scroll view',
      icon: icon,
    ),
    MiTab(
      tooltip: 'Framed list view',
      icon: Icon(Icons.list),
    ),
  ];

  const PageLayoutsPage({super.key});

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
            ),
          ),
          body: const SafeArea(
            minimum: EdgeInsets.symmetric(horizontal: 8),
            child: TabBarView(
              children: [
                _FramedScrollViewTab(content: (SingleChildScrollView)),
                _FramedScrollViewTab(content: (ListView)),
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
// Framed scroll view tab
//

final _lengthProvider = StateProvider((ref) => 1);

const _length = [1, 20];

class _FramedScrollViewTab extends ConsumerWidget {
  static final _logger = Logger((_FramedScrollViewTab).toString());

  final Type content;

  const _FramedScrollViewTab({required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final lengthIndex = ref.watch(_lengthProvider);
    final length = _length[lengthIndex];

    final theme = Theme.of(context);

    final content_ = run(() {
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

    return MiVerticalFrame(
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