// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

/// [ColorSlider]の状態変数
///
/// [gradient]中の位置[position]の色をプロパティとしてとるウィジェット[ColorSlider]の状態変数。
/// 初期化に非同期処理が必要なので、値でなくFutureとして生成する。
/// [ColorSliderValue]をプロバイダ化する場合、下のように、[FutureOr]の[StreamController]を生成し、
/// [StreamProvider]にすればなんとかなる。
///
/// ```dart
/// // StreamController生成、初期値のFutureを入れる
/// final _streamController = StreamController<FutureOr<ColorSliderValue>>()
///   ..sink.add(ColorSliderValue.fromGradient(gradient: _gradient, position: 0.0));
///
/// // StreamProviderでプロバイダ化
/// final _streamProvider = StreamProvider<ColorSliderValue>((ref) async* {
///   // ストリームをawaitし...
///   await for (final value in _streamController.stream) {
///     // さらにFutureOrをawait
///     yield await value;
///   }
/// });
///     :
///   // build()中に、StreamProviderをwatchして...
///   final asyncValue = ref.watch(_streamProvider);
///     :
///   // AsyncValueの状態に応じてColorSliderを構築
///   asyncValue.when(
///     data: (value) => ColorSlider(
///       value: value,
///       onChanged: (value) {
///         // 値が変化したらストリームに追加すると、自動的にプロバイダ更新
///         _streamController.sink.add(value);
///       },
///     ),
///     error: (error, _) => Text(error.toString()),
///     loading: () => const CircularProgressIndicator(),
///   ),
///     :
/// ```

class ColorSliderValue {
  final Gradient gradient;
  final double position;
  final List<Color> colors;

  /// Futureを生成する（まあ一種の）コンストラクタ
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

  /// [position]に対応する色
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

/// TODO:
class _ColorSliderTrackShape extends RectangularSliderTrackShape {
  final Gradient gradient;
  const _ColorSliderTrackShape({
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

/// [Gradient]中のある色を採るスライダ
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
