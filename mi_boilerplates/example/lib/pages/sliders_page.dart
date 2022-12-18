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
      tooltip: 'Slider',
      icon: icon,
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
                _SliderTab(),
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
// Slider tab
//

//<editor-fold>

final _walkAnimationImages = <Image>[
  Image.asset('assets/walk64x64/walk64x64f1.png'),
  Image.asset('assets/walk64x64/walk64x64f2.png'),
  Image.asset('assets/walk64x64/walk64x64f3.png'),
  Image.asset('assets/walk64x64/walk64x64f4.png'),
  Image.asset('assets/walk64x64/walk64x64f5.png'),
];

final _walkAnimationFrames = <int>[0, 1, 2, 3, 4, 3, 2, 1];

class FrameAnimation extends StatefulWidget {
  final List<Image> images;
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
    return widget.images[widget.frames[_frame]];
  }
}

enum _PlayerState { stop, play, pause }

final _speedProvider = StateProvider((ref) => 1.0);
final _playProvider = StateProvider((ref) => _PlayerState.stop);

class _SliderTab extends ConsumerWidget {
  // ignore: unused_field
  static final _logger = Logger((_SliderTab).toString());

  const _SliderTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(ex.enableActionsProvider);
    final speed = ref.watch(_speedProvider);
    final play = ref.watch(_playProvider);

    final theme = Theme.of(context);

    return Column(
      children: [
        mi.Row(
          flexes: const [1, 1],
          children: [
            mi.ButtonListTile(
              icon: mi.ToggleIcon(
                checked: play == _PlayerState.play,
                checkIcon: const Icon(Icons.pause),
                uncheckIcon: const Icon(Icons.play_arrow),
              ),
              text: play == _PlayerState.play ? const Text('Pause') : const Text('Play'),
              onPressed: enabled
                  ? () {
                      ref.read(_playProvider.notifier).state =
                          play == _PlayerState.play ? _PlayerState.pause : _PlayerState.play;
                    }
                  : null,
            ),
            mi.ButtonListTile(
              icon: const Icon(Icons.stop),
              text: const Text('Stop'),
              onPressed: enabled && play != _PlayerState.stop
                  ? () {
                      ref.read(_playProvider.notifier).state = _PlayerState.stop;
                    }
                  : null,
            ),
          ],
        ),
        ListTile(
          trailing: Text('x${speed.toStringAsFixed(1)}'),
          title: Slider(
            min: 1.0,
            max: 3.0,
            value: speed,
            onChanged: enabled && play != _PlayerState.stop
                ? (value) {
                    ref.read(_speedProvider.notifier).state = value;
                  }
                : null,
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
              child: play == _PlayerState.stop
                  ? const Icon(Icons.accessibility_new, size: 64)
                  : FrameAnimation(
                      enabled: enabled && play == _PlayerState.play,
                      images: _walkAnimationImages,
                      frames: _walkAnimationFrames,
                      duration: Duration(milliseconds: 1000 ~/ speed),
                    )),
        ),
      ],
    );
  }
}

//</editor-fold>
