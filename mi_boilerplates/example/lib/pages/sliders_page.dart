// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;
import 'ex_widgets.dart' as ex;

class SlidersPage extends ConsumerWidget {
  static const icon = Icon(Icons.tune);
  static const title = Text('Sliders');

  static final _logger = Logger((SlidersPage).toString());

  static final _tabs = <Widget>[
    const mi.Tab(
      tooltip: 'Int slider',
      icon: Icon(Icons.linear_scale),
    ),
    const mi.Tab(
      tooltip: ex.UnderConstruction.title,
      icon: ex.UnderConstruction.icon,
    ),
  ];

  const SlidersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);

    return mi.DefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
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
            minimum: EdgeInsets.all(8),
            child: TabBarView(
              children: [
                _IntSliderTab(),
                ex.UnderConstruction(),
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
// Int slider tab
//

//<editor-fold>

const _animationImages = <AssetImage>[
  AssetImage('assets/walk64x64/walk64x64_0.png'),
  AssetImage('assets/walk64x64/walk64x64_1.png'),
  AssetImage('assets/walk64x64/walk64x64_2.png'),
  AssetImage('assets/walk64x64/walk64x64_3.png'),
  AssetImage('assets/walk64x64/walk64x64_4.png'),
  AssetImage('assets/walk64x64/walk64x64_5.png'),
  AssetImage('assets/walk64x64/walk64x64_6.png'),
];

final _animationFrames0 = <int>[5, 6];
final _animationFrames1 = <int>[2, 3, 4, 3, 2, 1];
final _animationFrames2 = <int>[2, 3, 4, 3, 2, 1, 0, 1];

// FrameAnimation

class FrameAnimation extends StatefulWidget {
  final List<ImageProvider> images;
  final List<int> frames;
  final Duration duration;
  final bool enabled;

  const FrameAnimation({
    super.key,
    required this.images,
    required this.frames,
    required this.duration,
    this.enabled = true,
  });

  @override
  State<StatefulWidget> createState() => _FrameAnimationState();
}

class _FrameAnimationState extends State<FrameAnimation> {
  // ignore: unused_field
  static final _logger = Logger((_FrameAnimationState).toString());

  Timer? _timer;
  int _frame = 0;

  void _setTimer() {
    _timer?.cancel();
    if (widget.enabled) {
      _timer = Timer.periodic(widget.duration ~/ widget.frames.length, _onTimer);
    }
  }

  void _onTimer(Timer _) {
    //_logger.fine('_frame=$_frame');
    setState(() {});
    _frame = (_frame + 1) % widget.frames.length;
  }

  @override
  void initState() {
    assert(widget.frames.isNotEmpty);
    super.initState();
    _setTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FrameAnimation oldWidget) {
    assert(widget.frames.isNotEmpty);
    super.didUpdateWidget(oldWidget);
    _setTimer();
  }

  @override
  Widget build(BuildContext context) {
    _frame = _frame.clamp(0, widget.frames.length - 1);
    return Image(image: widget.images[widget.frames[_frame]]);
  }
}

// _IntSliderTab

final _speedProvider = StateProvider((ref) => 0);
final _breatherProvider = StateProvider<Timer?>((ref) => null);

class _IntSliderTab extends ConsumerWidget {
  // ignore: unused_field
  static final _logger = Logger((_IntSliderTab).toString());

  const _IntSliderTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(ex.enableActionsProvider);
    final speed = ref.watch(_speedProvider);
    final breather = ref.watch(_breatherProvider);

    final theme = Theme.of(context);
    final sliderTheme = SliderTheme.of(context);

    return Column(
      children: [
        ListTile(
          trailing: Text('x${speed.toStringAsFixed(1)}'),
          title: SliderTheme(
            data: sliderTheme.copyWith(
              tickMarkShape: RoundSliderTickMarkShape(
                tickMarkRadius: sliderTheme.trackHeightValue * 2.0,
              ),
            ),
            child: mi.IntSlider(
              min: 0,
              max: 3,
              value: speed,
              onChanged: enabled
                  ? (value) {
                      ref.read(_speedProvider.notifier).state = value;
                      if (value == 0) {
                        if (breather != null) {
                          breather.cancel();
                        }
                        ref.read(_breatherProvider.notifier).state = Timer(
                          const Duration(milliseconds: 2400),
                          () {
                            ref.read(_breatherProvider.notifier).state = null;
                          },
                        );
                      }
                    }
                  : null,
            ),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              theme.disabledColor,
              BlendMode.srcIn,
            ),
            child: speed == 0
                ? breather != null
                    ? FrameAnimation(
                        enabled: enabled,
                        images: _animationImages,
                        frames: _animationFrames0,
                        duration: const Duration(milliseconds: 400),
                      )
                    : const Icon(Icons.accessibility_new, size: 64)
                : FrameAnimation(
                    enabled: enabled,
                    images: _animationImages,
                    frames: speed == 1 ? _animationFrames1 : _animationFrames2,
                    duration: Duration(milliseconds: 1000 ~/ (speed + 1)),
                  ),
          ),
        ),
      ],
    );
  }
}

//</editor-fold>
