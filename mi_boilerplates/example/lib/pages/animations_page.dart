// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:lottie/lottie.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import '../data/open_moji_svgs.dart';
import 'ex_app_bar.dart';

//
// Animations example page.
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

    final tabs = <Widget>[
      const MiTab(icon: Icon(Icons.refresh), tooltip: 'Animated builder'),
      MiTab(
        icon: MiImageIcon(
          image: Image.asset('assets/lottie_icon.png'),
        ),
        tooltip: 'Lottie',
      ),
      // const MiTab(icon: Icon(Icons.pets), tooltip: 'Animated opacity'),
      // const MiTab(icon: Icon(Icons.bedroom_baby_outlined), tooltip: 'Animation GIF'),
      const MiTab(icon: Icon(Icons.play_arrow), tooltip: 'Animated icons'),
    ];

    return MiDefaultTabController(
      length: tabs.length,
      initialIndex: _tabIndex,
      onIndexChanged: (index) {
        _tabIndex = index;
      },
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
                // _AnimatedOpacityTab(),
                // _AnimationGifTab(),
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
          builder: (_, __) {
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
// https://lottiefiles.com/11458-empty
const _lottieUrl = 'https://assets3.lottiefiles.com/packages/lf20_tDw3lP/empty_03.json';

class _LottieTab extends ConsumerWidget {
  static final _logger = Logger((_LottieTab).toString());

  const _LottieTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    return Center(
      child: MiAnimationController(
        builder: (_, controller, __) {
          return ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.red,
              BlendMode.srcIn,
            ),
            child: Lottie.network(
              _lottieUrl,
              controller: controller,
              repeat: false,
              onLoaded: (composition) {
                _logger.fine('onLoaded: ${composition.duration}');
                controller.duration = composition.duration;
                controller.reset();
                controller.forward();
              },
            ),
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
// Animation GIF tab
//

const _imageUrl =
    'https://upload.wikimedia.org/wikipedia/commons/d/dd/Muybridge_race_horse_animated.gif';

class _AnimationGifTab extends ConsumerWidget {
  static final _logger = Logger((_AnimationGifTab).toString());

  const _AnimationGifTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    return Image.network(
      _imageUrl,
      fit: BoxFit.contain,
      frameBuilder: (_, child, frame, __) =>
          frame == null ? const Center(child: CircularProgressIndicator()) : child,
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Animated opacity tab
//

final _opaqueProvider = StateProvider((ref) => false);

class _AnimatedOpacityTab extends ConsumerWidget {
  static final _logger = Logger((_AnimatedOpacityTab).toString());

  const _AnimatedOpacityTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final opaque = ref.watch(_opaqueProvider);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Align(
        alignment: Alignment.topCenter,
        child: InkWell(
          onTap: () {
            ref.read(_opaqueProvider.notifier).state = !opaque;
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                opacity: opaque ? 0.5 : 1.0,
                duration: const Duration(seconds: 1),
                child: const Icon(
                  Icons.grass,
                  color: Colors.green,
                  size: 200,
                ),
              ),
              AnimatedOpacity(
                opacity: opaque ? 1.0 : 0.1,
                duration: const Duration(seconds: 1),
                child: SizedBox.square(
                  dimension: 100,
                  child: openMojiSvgLion,
                ),
              ),
            ],
          ),
        ),
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
