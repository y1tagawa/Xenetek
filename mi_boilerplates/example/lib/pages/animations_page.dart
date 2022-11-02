// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:lottie/lottie.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import '../main.dart';
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
    final enableActions = ref.watch(enableActionsProvider);

    final theme = Theme.of(context);

    final tabs = <Widget>[
      const MiTab(icon: icon, tooltip: 'Animated builder'),
      MiTab(
        icon: SizedBox.square(
          dimension: 19.5,
          child: Image.asset(
            'assets/lottieIcon.png',
            // TODO: 末端でテーマ設定はよくない・非選択色対応
            color: theme.tabBarTheme.labelColor ?? theme.colorScheme.onSurface,
          ),
        ),
        tooltip: 'Lottie',
      ),
      const MiTab(
        icon: Icon(Icons.access_alarm_outlined),
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
            icon: icon,
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
    );
  }
}

//
// AnimationController tab
//
// s.a. https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html
//   https://api.flutter.dev/flutter/animation/AnimationController-class.html
//

class _AnimatedIcon extends StatefulWidget {
  final Duration duration;
  final void Function(AnimationController)? onCompleted;
  final void Function(AnimationController)? onTap;

  const _AnimatedIcon({
    // ignore: unused_element
    this.duration = const Duration(milliseconds: 1000),
    // ignore: unused_element
    this.onCompleted,
    this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon> with SingleTickerProviderStateMixin {
  static final _logger = Logger((_AnimatedIconState).toString());

  late final AnimationController _controller = AnimationController(
    vsync: this, // the SingleTickerProviderStateMixin.
    duration: widget.duration,
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call(_controller);
      }
    });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.fine('[i] build ${_controller.value}');

    return AnimatedBuilder(
      animation: _controller,
      child: null,
      builder: (context, _) {
        final t = _controller.value;
        return SizedBox.square(
          dimension: 120,
          child: InkWell(
            onTap: () => widget.onTap?.call(_controller),
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                //
                Transform.rotate(
                  angle: (360.0 * t).toRadian(),
                  child: const Icon(
                    Icons.refresh,
                    size: 60,
                  ),
                ),
                //
                if (t != 0.0 && t < 0.99)
                  Transform.translate(
                    offset: Offset(200.0 * t, 200.0 * t * t),
                    child: const Icon(
                      Icons.star,
                      size: 24,
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

class _AnimatedBuilderTab extends ConsumerWidget {
  static final _logger = Logger((_AnimatedBuilderTab).toString());

  const _AnimatedBuilderTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final productName = ref.watch(productNameProvider).when(
          data: (value) => value,
          error: (_, __) => null,
          loading: () => null,
        );

    return Center(
      child: _AnimatedIcon(
        duration: productName == 'S6-KC'
            ? const Duration(seconds: 6) // Mi Android One.
            : const Duration(milliseconds: 200),
        onTap: (controller) {
          controller.reset();
          controller.forward();
        },
        onCompleted: (_) {
          _logger.fine('_AnimatedIcon.onCompleted');
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
// s.a. https://pub.dev/packages/lottie
//

class _Animated extends StatefulWidget {
  final Duration duration;
  final Widget Function(AnimationController) builder;
  final void Function(AnimationController)? onInitialized;
  final void Function(AnimationController)? onCompleted;
  final void Function(AnimationController)? onTap;
  final Widget? child;

  const _Animated({
    required this.builder,
    // ignore: unused_element
    this.duration = const Duration(milliseconds: 1000),
    // ignore: unused_element
    this.onInitialized,
    // ignore: unused_element
    this.onCompleted,
    // ignore: unused_element
    this.onTap,
    // ignore: unused_element
    this.child,
  });

  @override
  State<StatefulWidget> createState() => _AnimatedState();
}

class _AnimatedState extends State<_Animated> with SingleTickerProviderStateMixin {
  static final _logger = Logger((_AnimatedState).toString());

  late final AnimationController _controller = AnimationController(
    vsync: this, // the SingleTickerProviderStateMixin.
    duration: widget.duration,
  ).also((it) {
    it.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call(_controller);
      }
    });
    widget.onInitialized?.call(it);
  });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.fine('[i] build ${_controller.value}');
    return InkWell(
      child: widget.builder(_controller),
      onTap: () => widget.onTap?.call(_controller),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

class _LottieTab extends ConsumerWidget {
  static final _log = Logger((_LottieTab).toString());

  const _LottieTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _log.fine('[i] build');

    final productName = ref.watch(productNameProvider).when(
          data: (value) => value,
          error: (_, __) => null,
          loading: () => null,
        );

    _log.fine('productName=[$productName]');

    return Center(
      child: _Animated(
        builder: (controller) {
          return Lottie.network(
            'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json',
            controller: controller,
            repeat: false,
            onLoaded: (composition) {
              _log.fine('onLoaded: ${composition.duration}');
              if (productName == 'S6-KC') {
                controller.duration = composition.duration * 10; // Mi Android One.
              } else {
                controller.duration = composition.duration;
              }
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
      _log.fine('[o] build');
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
          (index, data) => _Animated(
            builder: (controller) {
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
            // onInitialized: (controller) {
            //   controller.forward();
            // },
            // onCompleted: (controller) {
            //   controller.reset();
            //   controller.forward();
            // },
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
