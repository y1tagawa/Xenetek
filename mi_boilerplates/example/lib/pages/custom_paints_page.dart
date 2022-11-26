// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';
import 'under_construction.dart';

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
      const MiTab(icon: UnderConstruction.icon, tooltip: UnderConstruction.text),
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
                UnderConstruction(),
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
  final ValueNotifier<DateTime> dateTimeNotifier;
  final Color? faceColor;
  final Color? tickColor;
  final Color? hourColor;
  final Color? minuteColor;
  final Color? secondColor;
  final Color? pivotColor;

  const _Clock({
    // ignore: unused_element
    super.key,
    required this.size,
    required this.dateTimeNotifier,
    // ignore: unused_element
    this.faceColor,
    // ignore: unused_element
    this.tickColor,
    // ignore: unused_element
    this.hourColor,
    // ignore: unused_element
    this.minuteColor,
    // ignore: unused_element
    this.secondColor,
    // ignore: unused_element
    this.pivotColor,
  });

  @override
  State<_Clock> createState() => _ClockState();
}

class _FacePainter extends CustomPainter {
  // ignore: unused_field
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
      return oldDelegate.state != state;
    }
    return false;
  }
}

class _FeaturePainter extends CustomPainter {
  // ignore: unused_field
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
      paint_.style = PaintingStyle.fill;
      paint_.color = state.tickColor;
      for (int i = 0; i < 12; ++i) {
        final p = _hand(i * (_kPi2 / 12.0), radius);
        canvas.drawCircle(p * 0.9, 4.0, paint_);
      }
      // hour hand
      paint_.style = PaintingStyle.stroke;
      paint_.strokeCap = StrokeCap.round;
      paint_.color = state.hourColor;
      paint_.strokeWidth = 8.0;
      final hour = (dateTime.hour * 60 + dateTime.minute) / 60.0;
      final h = _hand(hour * (_kPi2 / 12.0), radius);
      canvas.drawLine(h * -0.05, h * 0.5, paint_);
      // minute hand
      paint_.color = state.minuteColor;
      paint_.strokeWidth = 6.0;
      final minute = (dateTime.minute * 60 + dateTime.second) / 60.0;
      final m = _hand(minute * (_kPi2 / 60.0), radius);
      canvas.drawLine(m * -0.05, m * 0.75, paint_);
      // second hand
      paint_.strokeWidth = 3.0;
      paint_.color = state.secondColor;
      final s = _hand(dateTime.second * (_kPi2 / 60.0), radius);
      canvas.drawLine(s * -0.15, s * 0.65, paint_);
      // pivot
      paint_.style = PaintingStyle.fill;
      paint_.color = state.secondColor;
      canvas.drawCircle(Offset.zero, 3.5, paint_);
      paint_.color = state.pivotColor;
      canvas.drawCircle(Offset.zero, 2.0, paint_);
    } finally {
      canvas.restore();
    }
    //_logger.fine('[o] paint');
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _FeaturePainter) {
      return oldDelegate.state != state ||
          oldDelegate.dateTime.second != dateTime.second ||
          oldDelegate.dateTime.minute != dateTime.minute ||
          oldDelegate.dateTime.hour != dateTime.hour;
    }
    return false;
  }
}

class _ClockState extends State<_Clock> {
  // ignore: unused_field
  static final _logger = Logger((_ClockState).toString());

  late Color faceColor;
  late Color tickColor;
  late Color hourColor;
  late Color minuteColor;
  late Color secondColor;
  late Color pivotColor;

  void _onUpdate() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.dateTimeNotifier.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.dateTimeNotifier.removeListener(_onUpdate);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _Clock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      oldWidget.dateTimeNotifier.removeListener(_onUpdate);
      widget.dateTimeNotifier.addListener(_onUpdate);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = widget.dateTimeNotifier.value;

    final theme = Theme.of(context);
    final isDark = theme.isDark;
    final color = isDark ? theme.colorScheme.secondary : theme.primaryColor;

    faceColor = widget.faceColor ?? theme.colorScheme.surface;
    tickColor = widget.tickColor ?? color.withOpacity(0.5);
    hourColor = widget.hourColor ?? color;
    minuteColor = widget.minuteColor ?? tickColor;
    secondColor = widget.secondColor ?? color.withOpacity(0.75);
    pivotColor = widget.pivotColor ?? (isDark ? Colors.white70 : faceColor);

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
        child: Image.asset(
            theme.isDark ? 'assets/under_construction.png' : 'assets/under_construction2.png'),
      ),
    );
  }
}

final _dateTimeNotifier = ValueNotifier(DateTime.now());
final _dateTimeProvider = ChangeNotifierProvider((ref) => _dateTimeNotifier);

class _DigitalClock extends ConsumerWidget {
  static const _weekday = <String>['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  static final _logger = Logger((_DigitalClock).toString());

  const _DigitalClock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final theme = Theme.of(context);
    final style = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: 'Courier New',
      color: theme.disabledColor,
    );

    final dateTime = ref.watch(_dateTimeProvider).value;
    return ListTile(
      title: Text(
        '${DateFormat.yMd().format(dateTime)}(${_weekday[dateTime.weekday - 1]})',
        style: style,
      ),
      subtitle: Text(
        DateFormat.Hms().format(dateTime),
        style: style,
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

class _ClockTab extends ConsumerWidget {
  static final _logger = Logger((_ClockTab).toString());

  const _ClockTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    return MiTimerController.periodic(
      duration: const Duration(milliseconds: 200),
      onPeriodic: (_) {
        final now = DateTime.now();
        final value = _dateTimeNotifier.value;
        if (now.second != value.second ||
            now.minute != value.minute ||
            now.hour != value.hour ||
            now.day != value.day ||
            now.month != value.month ||
            now.year != value.year) {
          _dateTimeNotifier.value = now;
          //_logger.fine('update');
        }
      },
      child: Column(
        children: [
          Expanded(
            child: _Clock(
              size: const Size(200, 200),
              dateTimeNotifier: _dateTimeNotifier,
            ),
          ),
          const _DigitalClock(),
        ],
      ),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
