// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

//
// Custom paints trial page.
//

const _kPi2 = 2.0 * math.pi;

var _tabIndex = 0;

class CustomPaintsPage extends ConsumerWidget {
  static const icon = Icon(Icons.brush_outlined);
  static const title = Text('Custom paints');

  static final _logger = Logger((CustomPaintsPage).toString());

  const CustomPaintsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enableActions = ref.watch(enableActionsProvider);

    final tabs = <Widget>[
      const MiTab(icon: Icon(Icons.watch_later_outlined), tooltip: 'Clock'),
      const MiTab(
          icon: MiRotate(
            angleDegree: 180,
            child: Icon(Icons.filter_list),
          ),
          tooltip: 'Under construction'),
    ];

    return MiDefaultTabController(
      length: tabs.length,
      initialIndex: _tabIndex,
      builder: (context) {
        return Scaffold(
          appBar: ExAppBar(
            prominent: ref.watch(prominentProvider),
            //icon: icon,
            icon: icon,
            title: title,
            bottom: ExTabBar(
              enabled: enableActions,
              tabs: tabs,
            ),
          ),
          body: const SafeArea(
            minimum: EdgeInsets.symmetric(horizontal: 10),
            child: TabBarView(
              children: [
                _ClockTab(),
                _ClockTab(),
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
// Clock tab
//

class _Clock extends StatefulWidget {
  final Size size;
  final DateTime Function() onInterval;
  final Color? faceColor;
  final Color? tickColor;
  final Color? hourColor;
  final Color? minuteColor;
  final Color? secondColor;
  final Color? tenthSecondColor;

  const _Clock({
    super.key,
    required this.size,
    this.onInterval = DateTime.now,
    this.faceColor,
    this.tickColor,
    this.hourColor,
    this.minuteColor,
    this.secondColor,
    this.tenthSecondColor,
  });

  @override
  State<_Clock> createState() => _ClockState();
}

class _FacePainter extends CustomPainter {
  static final _logger = Logger((_FacePainter).toString());

  final _ClockState state;
  final DateTime dateTime;

  const _FacePainter({
    required this.state,
    required this.dateTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    //_logger.fine('[i] paint');
    canvas.save();
    try {
      canvas.translate(size.width * 0.5, size.height * 0.5);
      final radius = math.min(size.width, size.height) * 0.5;
      final paint_ = Paint();
      // face
      paint_.style = PaintingStyle.fill;
      paint_.color = state.faceColor;
      canvas.drawCircle(Offset.zero, radius, paint_);
    } finally {
      canvas.restore();
    }
    //_logger.fine('[o] paint');
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _FacePainter) {
      return oldDelegate.state != state || oldDelegate.dateTime != dateTime;
    }
    return false;
  }
}

class _FeaturePainter extends CustomPainter {
  static final _logger = Logger((_FeaturePainter).toString());

  final _ClockState state;
  final DateTime dateTime;

  const _FeaturePainter({
    required this.state,
    required this.dateTime,
  });

  Offset _hand(double angle, double radius) =>
      Offset(math.sin(angle) * radius, -math.cos(angle) * radius);

  @override
  void paint(Canvas canvas, Size size) {
    //_logger.fine('[i] paint');
    canvas.save();
    try {
      canvas.translate(size.width * 0.5, size.height * 0.5);
      final radius = math.min(size.width, size.height) * 0.5;
      final paint_ = Paint();
      // ticks
      paint_.color = state.tickColor;
      paint_.style = PaintingStyle.stroke;
      paint_.strokeCap = StrokeCap.round;
      paint_.strokeWidth = 3.0;
      for (int i = 0; i < 60; ++i) {
        final p = _hand(i * _kPi2 / 60.0, 1.0);
        canvas.drawLine(Offset.zero, p * 0.95, paint_);
      }
      // hour hand
      paint_.color = state.hourColor;
      paint_.strokeWidth = 8.0;
      canvas.drawLine(
          Offset.zero,
          _hand(
            dateTime.hour * _kPi2 / 12.0,
            radius * 0.5,
          ),
          paint_);
      // minute hand
      paint_.color = state.minuteColor;
      paint_.strokeWidth = 6.0;
      canvas.drawLine(
          Offset.zero,
          _hand(
            dateTime.minute * _kPi2 / 60.0,
            radius * 0.8,
          ),
          paint_);
      // minute hand
      paint_.strokeWidth = 3.0;
      paint_.color = state.secondColor;
      canvas.drawLine(
          Offset.zero,
          _hand(
            dateTime.second * _kPi2 / 60.0,
            radius * 0.75,
          ),
          paint_);
    } finally {
      canvas.restore();
    }
    //_logger.fine('[o] paint');
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _FeaturePainter) {
      return oldDelegate.state != state || oldDelegate.dateTime != dateTime;
    }
    return false;
  }
}

class _ClockState extends State<_Clock> {
  static final _logger = Logger((_ClockState).toString());

  late Timer _timer;

  late Color faceColor;
  late Color tickColor;
  late Color hourColor;
  late Color minuteColor;
  late Color secondColor;
  late Color tenthSecondColor;

  @override
  void initState() {
    super.initState();
    _logger.fine('timer start');
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _logger.fine('timer.cancel');
    _timer.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _Clock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = widget.onInterval();

    final theme = Theme.of(context);
    final isDark = theme.isDark;
    final color1 = isDark ? theme.colorScheme.secondary : theme.primaryColorDark;
    final color2 = isDark ? theme.colorScheme.secondary : theme.primaryColorLight;

    faceColor = widget.faceColor ?? theme.colorScheme.surface;
    tickColor = widget.tickColor ?? theme.colorScheme.onSurface;
    hourColor = widget.hourColor ?? color1;
    minuteColor = widget.minuteColor ?? color2;
    secondColor = widget.secondColor ?? color1;
    tenthSecondColor = widget.tenthSecondColor ?? color2;

    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: CustomPaint(
        painter: _FacePainter(
          state: this,
          dateTime: dateTime,
        ),
        foregroundPainter: _FeaturePainter(
          state: this,
          dateTime: dateTime,
        ),
        //child: Icon(Icons.closed_caption),
      ),
    );
  }
}

class _ClockTab extends ConsumerWidget {
  static final _logger = Logger((_ClockTab).toString());

  const _ClockTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    return Column(
      children: const [
        _Clock(
          size: Size(200, 200),
        ),
      ],
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
