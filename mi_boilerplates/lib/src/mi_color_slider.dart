// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'gradient_helper.dart';

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

// トラックに[gradient]を描画する
class _ColorSliderTrackShape extends RoundedRectSliderTrackShape {
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
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
    );
    final radius = trackRect.height * 0.5;
    context.canvas.drawRRect(
      RRect.fromLTRBR(
        trackRect.left - radius,
        trackRect.top,
        trackRect.right + radius,
        trackRect.bottom,
        Radius.circular(radius),
      ),
      Paint()..shader = gradient.createShader(trackRect),
    );

    //todo: secondary track https://api.flutter.dev/flutter/material/RoundedRectSliderTrackShape/paint.html
  }
}

/// [Gradient]中のある色を採るスライダ
class ColorSlider extends StatelessWidget {
  final ColorSliderValue value;
  final ValueChanged<ColorSliderValue>? onChanged;
  final double? trackHeight;

  const ColorSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.trackHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: trackHeight,
        trackShape: onChanged != null ? _ColorSliderTrackShape(gradient: value.gradient) : null,
      ),
      child: Slider(
        thumbColor: value.color,
        value: value.position,
        onChanged: onChanged != null
            ? (position) {
                onChanged?.call(value.copyWith(position: position));
              }
            : null,
      ),
    );
  }
}
