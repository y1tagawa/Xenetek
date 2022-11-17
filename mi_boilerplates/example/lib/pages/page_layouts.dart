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
      icon: Icon(Icons.toc),
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
                _FramedScrollTab(),
                _HeaderedListTab(),
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
// Framed single child scroll view tab
//

/// タブまたはScaffold body中の頻出コード
///
/// TODO: childに[ListView]を入れる場合
class MiScrollViewFrame extends StatelessWidget {
  final Widget child;
  final Widget? top;
  final Widget? bottom;

  const MiScrollViewFrame({
    super.key,
    required this.child,
    this.top,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (top != null) top!,
        Expanded(child: child),
        if (bottom != null) bottom!,
      ],
    );
  }
}

final _lengthProvider = StateProvider((ref) => 1);

const _length = [1, 20];

class _FramedScrollTab extends ConsumerWidget {
  static final _logger = Logger((_FramedScrollTab).toString());

  const _FramedScrollTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final lengthIndex = ref.watch(_lengthProvider);
    final length = _length[lengthIndex];

    return MiScrollViewFrame(
      top: ListTile(
        title: const Text('Header'),
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
      bottom: const ListTile(
        title: Text('Bottom'),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: iota(length)
              .map(
                (index) => ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text('Item #$index'),
                ),
              )
              .toList(),
        ),
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Framed list view tab
//

class _HeaderedListTab extends ConsumerWidget {
  static final _logger = Logger((_HeaderedListTab).toString());

  const _HeaderedListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final lengthIndex = ref.watch(_lengthProvider);
    final length = _length[lengthIndex];

    return MiScrollViewFrame(
      top: ListTile(
        title: const Text('Header'),
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
      bottom: const ListTile(
        title: Text('Bottom'),
      ),
      child: ListView.builder(
        itemCount: length,
        itemBuilder: (_, index) => ListTile(
          trailing: const Icon(Icons.person_outline),
          title: Text('Item #$index'),
        ),
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
