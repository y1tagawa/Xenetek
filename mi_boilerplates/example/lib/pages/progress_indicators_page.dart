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

  const ProgressIndicatorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final enableActions = ref.watch(enableActionsProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: ExAppBar(
        prominent: ref.watch(prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(
          left: 40,
          top: 12,
          right: 40,
          bottom: 8,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: kToolbarHeight,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              const SizedBox(
                height: kToolbarHeight,
                child: Center(
                  child: LinearProgressIndicator(),
                ),
              ),
              MiAnimationController(
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
                    final t = controller.value;
                    return Column(
                      children: [
                        SizedBox(
                          height: kToolbarHeight,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: math.min(t * 2, 1.0),
                              backgroundColor: theme.backgroundColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: kToolbarHeight,
                          child: Center(
                            child: LinearProgressIndicator(
                              value: math.min(t * 2, 1.0),
                              backgroundColor: theme.backgroundColor,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ExBottomNavigationBar(),
    );
  }
}
