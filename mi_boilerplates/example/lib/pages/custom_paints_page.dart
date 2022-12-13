// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;
import 'ex_widgets.dart' as ex;

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

    final enableActions = ref.watch(ex.enableActionsProvider);

    final tabs = <Widget>[
      const mi.Tab(icon: Icon(Icons.watch_later_outlined), tooltip: 'Clock'),
      const mi.Tab(icon: ex.UnderConstruction.icon, tooltip: ex.UnderConstruction.title),
    ];

    return mi.DefaultTabController(
      length: tabs.length,
      initialIndex: _tabIndex,
      builder: (context) {
        return Scaffold(
          appBar: ex.AppBar(
            prominent: ref.watch(ex.prominentProvider),
            //icon: icon,
            icon: icon,
            title: title,
            bottom: ex.TabBar(
              enabled: enableActions,
              tabs: tabs,
            ),
          ),
          body: const SafeArea(
            minimum: EdgeInsets.symmetric(horizontal: 10),
            child: TabBarView(
              children: [
                _ClockTab(),
                ex.UnderConstruction(),
              ],
            ),
          ),
          bottomNavigationBar: const ex.BottomNavigationBar(),
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

// アナログ時計風カスタム描画ウィジェット
class _Clock extends StatefulWidget {
  final Size size;
  final ValueNotifier<DateTime> dateTimeNotifier;
  final Color? faceColor;
  final Color? tickColor;
  final Color? hourColor;
  final Color? minuteColor;
  final Color? secondColor;
  final Color? pivotColor;
  final Widget? child;

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
    // ignore: unused_element
    this.child,
  });

  @override
  State<_Clock> createState() => _ClockState();
}

class _ClockFacePainter extends CustomPainter {
  // ignore: unused_field
  static final _logger = Logger((_ClockFacePainter).toString());

  final _ClockState state;
  final DateTime dateTime;

  const _ClockFacePainter({
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
    if (oldDelegate is _ClockFacePainter) {
      return oldDelegate.state != state;
    }
    return false;
  }
}

class _ClockHandsPainter extends CustomPainter {
  // ignore: unused_field
  static final _logger = Logger((_ClockHandsPainter).toString());

  final _ClockState state;
  final DateTime dateTime;

  const _ClockHandsPainter({
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
    if (oldDelegate is _ClockHandsPainter) {
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
    hourColor = widget.hourColor ?? color.withOpacity(0.9);
    minuteColor = widget.minuteColor ?? tickColor;
    secondColor = widget.secondColor ?? color.withOpacity(0.75);
    pivotColor = widget.pivotColor ?? (isDark ? Colors.white70 : faceColor);

    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: CustomPaint(
        painter: _ClockFacePainter(
          state: this,
          dateTime: dateTime,
        ),
        foregroundPainter: _ClockHandsPainter(
          state: this,
          dateTime: dateTime,
        ),
        child: widget.child,
      ),
    );
  }
}

// デジタル時計風ウィジェット
// 全体のリビルドを避けるため別クラスとする。
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

final _dateTimeNotifier = ValueNotifier(DateTime.now());
final _dateTimeProvider = ChangeNotifierProvider((ref) => _dateTimeNotifier);

class _ClockTab extends ConsumerWidget {
  static final _logger = Logger((_ClockTab).toString());

  const _ClockTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final theme = Theme.of(context);

    return mi.TimerController.periodic(
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
              child: Image.asset(
                theme.isDark ? 'assets/worker_cat2.png' : 'assets/worker_cat1.png',
              ),
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

//
//
//

abstract class _AbstractSprite {
  int get plane;
  bool get enabled;
  void update(void Function(_AbstractSprite sprite) addSprite);
  void paint(Canvas canvas, Size size);
}

class _SpritePainter extends CustomPainter {
  var _sprites = <_AbstractSprite>[];
  var _shouldRepaint = true;

  _SpritePainter({
    List<_AbstractSprite> sprites = const <_AbstractSprite>[],
  }) : _sprites = sprites;

  void update() {
    var sprites = <_AbstractSprite>[];
    for (final sprite in _sprites) {
      sprite.update((sprite_) => sprites.add(sprite_));
    }
    _sprites = sprites;
    _shouldRepaint = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var sprites = <int, List<_AbstractSprite>>{};
    for (final sprite in _sprites) {
      sprites[sprite.plane].let((it) {
        if (it == null) {
          sprites[sprite.plane] = [sprite];
        } else {
          it.add(sprite);
        }
      });
    }
    final planes = sprites.keys.toList().sorted();
    for (final plane in planes) {
      for (final sprite in sprites[plane]!) {
        sprite.paint(canvas, size);
      }
    }
    _shouldRepaint = false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return _shouldRepaint;
  }
}
