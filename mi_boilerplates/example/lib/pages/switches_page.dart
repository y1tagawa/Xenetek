// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradients/gradients.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;
import 'ex_widgets.dart' as ex;

class SwitchesPage extends ConsumerWidget {
  static const icon = Icon(Icons.toggle_on_outlined);
  static const title = Text('Switches');

  static final _logger = Logger((SwitchesPage).toString());

  static const _tabs = <Widget>[
    mi.Tab(
      tooltip: 'Switches',
      icon: icon,
    ),
    mi.Tab(
      tooltip: 'Switch theme',
      icon: Icon(Icons.tune),
    ),
  ];

  const SwitchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);

    return mi.DefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
      builder: (context) {
        return ex.Scaffold(
          appBar: ex.AppBar(
            prominent: ref.watch(ex.prominentProvider),
            icon: icon,
            title: title,
            bottom: ex.TabBar(
              enabled: enabled,
              tabs: _tabs,
            ),
          ),
          body: const TabBarView(
            children: [
              _SwitchesTab(),
              _SwitchThemeTab(),
            ],
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
// Switches tab
//

//<editor-fold>

class _SwitchItem {
  final Widget checkIcon;
  final Widget uncheckIcon;
  final Widget title;
  const _SwitchItem({required this.checkIcon, required this.uncheckIcon, required this.title});
}

final _switchItems = [
  _SwitchItem(
    checkIcon: const Icon(Icons.visibility_outlined),
    uncheckIcon: mi.ImageIcon(image: Image.asset('assets/eye_close.png')),
    //uncheckIcon: Icon(Icons.disabled_visible_outlined),
    title: const Text('Eye health'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.hearing_outlined),
    uncheckIcon: mi.Scale(scaleX: -1, child: Icon(Icons.hearing_disabled_outlined)),
    title: Text('Ear health'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.cloud_outlined),
    uncheckIcon: Icon(Icons.cloud_circle_outlined),
    title: Text('Mental health'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.calendar_view_month_outlined),
    uncheckIcon: Icon(Icons.widgets_outlined),
    title: Text('Dental health'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.directions_run),
    uncheckIcon: Icon(Icons.airline_seat_flat_outlined),
    title: Text('Physical health'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.attach_money_outlined),
    uncheckIcon: Icon(Icons.money_off_outlined),
    title: Text('Money'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.air_outlined),
    uncheckIcon: Icon(Icons.thermostat),
    title: Text('Air conditioning'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.bathroom_outlined),
    uncheckIcon: Icon(Icons.format_color_reset_outlined),
    title: Text('Bath'),
  ),
  const _SwitchItem(
    checkIcon: Icon(Icons.hourglass_top_outlined),
    uncheckIcon: Icon(Icons.hourglass_empty_outlined),
    title: Text('Life time'),
  ),
];

final _switchProvider = StateProvider((ref) => List.filled(_switchItems.length, true));

class _SwitchesTab extends ConsumerWidget {
  const _SwitchesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(ex.enableActionsProvider);
    final switches = ref.watch(_switchProvider);

    final theme = Theme.of(context);

    final myHp = switches.where((value) => value).length;

    void reset(bool value) {
      ref.read(_switchProvider.notifier).state = List.filled(_switchItems.length, value);
    }

    return Column(
      children: [
        mi.Row(
          flexes: const [1, 1],
          children: [
            ex.ResetButtonListTile(
              enabled: enableActions && switches.any((value) => !value),
              onPressed: () => reset(true),
            ),
            ex.ClearButtonListTile(
              enabled: enableActions && switches.any((value) => value),
              onPressed: () => reset(false),
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: ListView(
            children: _switchItems.mapIndexed(
              (index, item) {
                final switchValue = switches[index];
                return SwitchListTile(
                  value: switchValue,
                  title: mi.Label(
                    icon: mi.ToggleIcon(
                      checked: switchValue,
                      checkIcon: item.checkIcon,
                      uncheckIcon: item.uncheckIcon,
                    ),
                    text: item.title,
                  ),
                  onChanged: enableActions
                      ? (value) {
                          ref.read(_switchProvider.notifier).state =
                              switches.replacedAt(index, value);
                        }
                      : null,
                );
              },
            ).toList(),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              AnimatedOpacity(
                opacity: myHp.toDouble() / _switchItems.length,
                duration: const Duration(milliseconds: 500),
                child: Icon(
                  Icons.person_outline_outlined,
                  size: 48,
                  color: theme.disabledColor,
                ),
              ),
              AnimatedOpacity(
                opacity: myHp > 0 ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: Icon(
                  Icons.portrait_outlined,
                  size: 48,
                  color: theme.disabledColor,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

//</editor-fold>

//
// Switch theme tab
//

class _GradientSliderTrackShape extends RectangularSliderTrackShape {
  final Gradient gradient;
  const _GradientSliderTrackShape({
    required this.gradient,
  }) : super();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    // TODO: implement paint
    //super.paint(context, offset, parentBox, sliderTheme, enableAnimation, textDirection, thumbCenter, isDiscrete, isEnabled, additionalActiveTrackHeight);
  }
}

class ColorSliderValue {
  final Gradient gradient;
  final double position;
  final List<Color> colors;

  static Future<ColorSliderValue> fromGradient({
    required Gradient gradient,
    int resolution = 100,
    required double position,
  }) async {
    return ColorSliderValue._(
      gradient: gradient,
      position: position,
      colors: await gradient.toColors(resolution: resolution),
    );
  }

  Color? get color {
    final n = colors.length;
    return colors[math.min((position * n).toInt(), n - 1)];
  }

//<editor-fold desc="Data Methods">

  const ColorSliderValue._({
    required this.gradient,
    required this.position,
    required this.colors,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ColorSliderValue &&
          runtimeType == other.runtimeType &&
          gradient == other.gradient &&
          position == other.position &&
          colors == other.colors);

  @override
  int get hashCode => gradient.hashCode ^ position.hashCode ^ colors.hashCode;

  @override
  String toString() {
    return 'ColorSliderValue{'
        ' gradient: $gradient,'
        ' position: $position,'
        ' colors: $colors,'
        '}';
  }

  ColorSliderValue copyWith({
    double? position,
  }) {
    return ColorSliderValue._(
      gradient: gradient,
      position: position ?? this.position,
      colors: colors,
    );
  }

//</editor-fold>
}

class ColorSlider extends StatelessWidget {
  final ColorSliderValue value;
  final ValueChanged<ColorSliderValue>? onChanged;

  const ColorSlider({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      thumbColor: value.color,
      value: value.position,
      onChanged: onChanged != null
          ? (position) {
              onChanged?.call(value.copyWith(position: position));
            }
          : null,
    );
  }
}

final _streamController = StreamController<FutureOr<ColorSliderValue>>()
  ..sink.add(ColorSliderValue.fromGradient(gradient: _gradient, position: 0.0));

final _streamProvider = StreamProvider<ColorSliderValue>((ref) async* {
  await for (final value in _streamController.stream) {
    yield await value;
  }
});

//

const _hsbColors = <Color>[
  HsbColor(0.0, 100.0, 100.0),
  HsbColor(120.0, 100.0, 100.0),
  HsbColor(240.0, 100.0, 100.0),
  HsbColor(360.0, 100.0, 100.0),
  HsbColor(0.0, 0.0, 0.0),
  HsbColor(0.0, 0.0, 100.0),
];

const _gradient = LinearGradientPainter(colors: _hsbColors, colorSpace: ColorSpace.hsb);

//

final _cupertinoProvider = StateProvider((ref) => false);
final _thumbColorProvider = StateProvider<double>((ref) => 0.0);
final _trackColorProvider = StateProvider<double>((ref) => 0.0);
final _switchValueProvider = StateProvider((ref) => true);

class _SwitchThemeTab extends ConsumerWidget {
  static final _logger = Logger((SwitchesPage).toString());

  const _SwitchThemeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(ex.enableActionsProvider);
    final cupertino = ref.watch(_cupertinoProvider);
    final thumbColor = ref.watch(_thumbColorProvider);
    final trackColor = ref.watch(_trackColorProvider);
    final value = ref.watch(_switchValueProvider);

    final colorSliderValue = ref.watch(_streamProvider);

    void onChanged(bool value) {
      ref.read(_switchValueProvider.notifier).state = value;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: const Text('Style'),
            trailing: ToggleButtons(
              onPressed: enabled
                  ? (int index) {
                      ref.read(_cupertinoProvider.notifier).state = index == 0;
                    }
                  : null,
              isSelected: <bool>[cupertino, !cupertino],
              children: const [
                mi.SizedCenter(width: 80, child: Text('Cupertino')),
                mi.SizedCenter(width: 80, child: Text('Material')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Test'),
            trailing: enabled
                ? SizedBox(
                    width: 140,
                    child: colorSliderValue.when(
                      data: (value) => ColorSlider(
                        value: value,
                        onChanged: (value) {
                          _streamController.sink.add(value);
                        },
                      ),
                      error: (error, _) => Text(error.toString()),
                      loading: () => const CircularProgressIndicator(),
                    ),
                  )
                : null,
          ),
          ListTile(
            title: const Text('Thumb color'),
            trailing: enabled
                ? SizedBox(
                    width: 140,
                    child: Slider(
                      value: thumbColor,
                      onChanged: (value) {
                        ref.read(_thumbColorProvider.notifier).state = value;
                      },
                    ),
                  )
                : null,
          ),
          ListTile(
            title: const Text('Track color'),
            trailing: enabled
                ? SizedBox(
                    width: 140,
                    child: Slider(
                      value: trackColor,
                      onChanged: (value) async {
                        ref.read(_trackColorProvider.notifier).state = value;
                        final colors = await _gradient.toColors(resolution: 100);
                        final thumbColor_ =
                            colors[math.min((value * colors.length).toInt(), colors.length - 1)];
                      },
                    ),
                  )
                : null,
          ),
          const Divider(),
          SwitchTheme(
            data: SwitchTheme.of(context).copyWith(
                // thumbColor: MaterialStateProperty.resolveWith((states) =>
                //     states.contains(MaterialState.disabled) ? null : thumbColor.toColor()),
                // trackColor: MaterialStateProperty.resolveWith((states) =>
                //     states.contains(MaterialState.disabled) ? null : trackColor!.toColor()),
                ),
            child: cupertino
                ? CupertinoSwitch(
                    value: value,
                    onChanged: enabled ? onChanged : null,
                  )
                : Switch(
                    value: value,
                    onChanged: enabled ? onChanged : null,
                  ),
          ),
        ],
      ),
    );
  }
}
