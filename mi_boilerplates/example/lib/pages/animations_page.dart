// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:lottie/lottie.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

//
// Animations trial page.
//

var _tabIndex = 0;

class AnimationsPage extends ConsumerWidget {
  static const icon = Icon(Icons.animation_outlined);
  static const title = Text('Anima-\ntions');
  static const _title = Text('Animations');

  static final _logger = Logger((AnimationsPage).toString());

  const AnimationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enableActions = ref.watch(enableActionsProvider);

    final theme = Theme.of(context);

    final tabs = <Widget>[
      const MiTab(icon: Icon(Icons.refresh), tooltip: 'Animated builder'),
      MiTab(
        icon: MiImageIcon(
          image: Image.asset('assets/lottie_icon_outlined.png'),
          size: 17,
        ),
        tooltip: 'Lottie',
      ),
      const MiTab(
        icon: Icon(Icons.play_arrow),
        tooltip: 'Animated icons',
      ),
    ];

    return MiDefaultTabController(
      length: tabs.length,
      initialIndex: _tabIndex,
      builder: (context) {
        return Scaffold(
          appBar: ExAppBar(
            prominent: ref.watch(prominentProvider),
            //icon: icon,
            icon: MiAnimationController(
              duration: const Duration(seconds: 120),
              builder: (_, controller, __) {
                _logger.fine(controller.value);
                return AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    return MiRotate(
                      angleDegree: controller.value * 360,
                      child: icon,
                    );
                  },
                );
              },
              onInitialized: (controller) {
                controller.forward();
              },
              onCompleted: (controller) {
                controller.reset();
                controller.forward();
              },
            ),
            title: _title,
            bottom: ExTabBar(
              enabled: enableActions,
              tabs: tabs,
            ),
          ),
          body: const SafeArea(
            minimum: EdgeInsets.symmetric(horizontal: 10),
            child: TabBarView(
              children: [
                _AnimatedBuilderTab(),
                _LottieTab(),
                _AnimatedIconsTab(),
              ],
            ),
          ),
          bottomNavigationBar: const ExBottomNavigationBar(),
        );
      },
    ).also((it) {
      _logger.fine('[o] build');
    });
  }
}

//
// Animation builder tab
//
// s.a. https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html
//   https://api.flutter.dev/flutter/animation/AnimationController-class.html
//

class _AnimatedBuilderTab extends ConsumerWidget {
  static final _logger = Logger((_AnimatedBuilderTab).toString());

  const _AnimatedBuilderTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    return Center(
      child: MiAnimationController(
        duration: const Duration(milliseconds: 800),
        builder: (_, controller, __) => AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final t = controller.value;
            _logger.fine(t);
            return SizedBox.square(
              dimension: 120,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  // dispenser
                  Transform.rotate(
                    angle: (360.0 * Curves.bounceOut.transform(t)).toRadian(),
                    child: const Icon(
                      Icons.refresh,
                      size: 60,
                    ),
                  ),
                  // star
                  if (t != 0.0 && t < 0.99)
                    Transform.translate(
                      offset: Offset(400.0 * t, 400.0 * t * t),
                      child: const Icon(
                        Icons.star,
                        size: 24,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        onTap: (controller) {
          _logger.fine('tap');
          controller.reset();
          controller.forward();
        },
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Lottie tab
//
// https://lottiefiles.com/lottiefilez
// https://pub.dev/packages/lottie
//

//// https://lottiefiles.com/99-bell
// https://lottiefiles.com/38597-diwali-peacock-lottiefiles-logo
const _lottieUrl = 'https://assets8.lottiefiles.com/private_files/lf30_smcmhowt.json';

class _LottieTab extends ConsumerWidget {
  static final _logger = Logger((_LottieTab).toString());

  const _LottieTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    return Center(
      child: MiAnimationController(
        builder: (_, controller, __) {
          return Lottie.network(
            _lottieUrl,
            controller: controller,
            repeat: false,
            onLoaded: (composition) {
              _logger.fine('onLoaded: ${composition.duration}');
              controller.duration = composition.duration;
              controller.reset();
              controller.forward();
            },
          );
        },
        onTap: (controller) {
          controller.reset();
          controller.forward();
        },
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Animated icons catalogue tab
//

const _animatedIcons = <AnimatedIconData>[
  AnimatedIcons.arrow_menu,
  AnimatedIcons.close_menu,
  AnimatedIcons.ellipsis_search,
  AnimatedIcons.event_add,
  AnimatedIcons.home_menu,
  AnimatedIcons.list_view,
  AnimatedIcons.menu_arrow,
  AnimatedIcons.menu_close,
  AnimatedIcons.menu_home,
  AnimatedIcons.pause_play,
  AnimatedIcons.play_pause,
  AnimatedIcons.search_ellipsis,
  AnimatedIcons.view_list,
];

const _animatedIconNames = [
  'arrow_menu',
  'close_menu',
  'ellipsis_search',
  'event_add',
  'home_menu',
  'list_view',
  'menu_arrow',
  'menu_close',
  'menu_home',
  'pause_play',
  'play_pause',
  'search_ellipsis',
  'view_list',
];

final _animatedIconDirections = List<bool>.generate(_animatedIcons.length, (_) => true);

class _AnimatedIconsTab extends ConsumerWidget {
  static final _logger = Logger((_AnimatedIconsTab).toString());

  const _AnimatedIconsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(_animatedIcons.length == _animatedIconNames.length);
    _logger.fine('[i] build');

    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._animatedIcons.mapIndexed(
          (index, data) => MiAnimationController(
            builder: (_, controller, __) {
              return Tooltip(
                message: _animatedIconNames[index],
                child: AnimatedIcon(
                  icon: data,
                  progress: controller,
                  size: 48,
                  color: theme.colorScheme.background,
                ),
              );
            },
            onTap: (controller) {
              final direction = _animatedIconDirections[index];
              if (direction) {
                controller.forward(from: controller.value);
              } else {
                controller.reverse(from: controller.value);
              }
              _animatedIconDirections[index] = !direction;
            },
          ),
        ),
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
