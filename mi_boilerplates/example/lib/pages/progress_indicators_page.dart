// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

///
/// Progress indicators bar example page.
///

class ProgressIndicatorsPage extends ConsumerWidget {
  static const icon = Icon(Icons.refresh_outlined);
  static const title = Text('Progress indicators');

  static final _logger = Logger((ProgressIndicatorsPage).toString());

  static const _tabs = <Widget>[
    MiTab(text: 'Determinate'),
    MiTab(text: 'Indeterminate'),
  ];

  const ProgressIndicatorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);

    return MiDefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
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
            minimum: EdgeInsets.all(8),
            child: TabBarView(
              children: [
                _DeterminateTab(),
                _IndeterminateTab(),
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

class _DeterminateTab extends ConsumerWidget {
  // ignore: unused_field
  static final _logger = Logger((_DeterminateTab).toString());

  const _DeterminateTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 8,
      ),
      child: MiAnimationController(
        duration: const Duration(seconds: 4),
        onInitialized: (controller) {
          controller.forward();
        },
        onCompleted: (controller) {
          controller.reset();
          controller.forward();
        },
        builder: (_, controller, __) => AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final t = math.min(controller.value * 2.0, 1.0);
            return Column(
              children: [
                SizedBox(
                  height: kToolbarHeight,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: t,
                      backgroundColor: theme.backgroundColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: Center(
                    child: LinearProgressIndicator(
                      value: t,
                      backgroundColor: theme.backgroundColor,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _IndeterminateTab extends ConsumerWidget {
  // ignore: unused_field
  static final _logger = Logger((_IndeterminateTab).toString());

  const _IndeterminateTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 8,
      ),
      child: Column(
        children: const [
          SizedBox(
            height: kToolbarHeight,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          SizedBox(
            height: kToolbarHeight * 0.5,
            child: Center(
              child: LinearProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
