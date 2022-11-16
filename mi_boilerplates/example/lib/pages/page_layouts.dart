// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
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
      tooltip: 'Headered scroll view',
      icon: icon,
    ),
    MiTab(
      tooltip: 'Headered list view',
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
                _HeaderedScrollTab(),
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
// Headered scrollable example tab
//

/// タブ中の頻出コード
///
/// TODO: childに[ListView]を入れる場合
class MiHeaderedScrollView extends StatelessWidget {
  final Axis scrollDirection;
  final bool reverse;
  final EdgeInsetsGeometry? padding;
  final bool? primary;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final Widget? child;
  final DragStartBehavior dragStartBehavior;
  final Clip clipBehavior;
  final String? restorationId;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Widget? header;
  final Widget? bottom;

  const MiHeaderedScrollView({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.primary,
    this.physics,
    this.controller,
    this.child,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.header,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (header != null) header!,
        if (child != null)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: scrollDirection,
              reverse: reverse,
              padding: padding,
              primary: primary,
              physics: physics,
              controller: controller,
              dragStartBehavior: dragStartBehavior,
              clipBehavior: clipBehavior,
              restorationId: restorationId,
              child: child!,
            ),
          ),
        if (bottom != null) bottom!,
      ],
    );
  }
}

class _HeaderedScrollTab extends ConsumerWidget {
  static final _logger = Logger((_HeaderedScrollTab).toString());

  const _HeaderedScrollTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    return MiHeaderedScrollView(
      header: const ListTile(
        title: Text('Header'),
      ),
      bottom: const ListTile(
        title: Text('Bottom'),
      ),
      child: Column(
        children: iota(20)
            .map(
              (index) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text('Item #$index'),
              ),
            )
            .toList(),
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
//
//

class _HeaderedListTab extends ConsumerWidget {
  static final _logger = Logger((_HeaderedListTab).toString());

  const _HeaderedListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    return Column(
      children: [
        const ListTile(
          title: Text('Header'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 20,
            itemBuilder: (_, index) => ListTile(
              trailing: const Icon(Icons.person_outline),
              title: Text('Item #$index'),
            ),
          ),
        ),
        const ListTile(
          title: Text('Bottom'),
        ),
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
