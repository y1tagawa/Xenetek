// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

extension ColorHelper on Color {
  /// [value]を表す16進数文字列を返す。
  String toHex() => value.toRadixString(16).toUpperCase();

  /// [value]が[Colors.primaries]に定義されていればその値を、
  /// MCGのアルゴリズムに則り、スウォッチを生成して、[MaterialColor]に変換して返す。
  /// reference: https://github.com/mbitson/mcg#color-generation
  /// https://github.com/mbitson/mcg/blob/858cffea0d79ac143d590d110fbe20a1ea54d59d/scripts/controllers/ColorGeneratorCtrl.js#L281
  /// https://github.com/salkuadrat/colours/blob/21f9ab5fd361d7281987aa64f67113c8a414bdf9/lib/src/tinycolour/tinycolor.dart#L84
  MaterialColor toMaterialColor() {
    final i = indexOfPrimaries();
    if (i >= 0) {
      return Colors.primaries[i];
    }
    if (value == Colors.grey.value) {
      return Colors.grey;
    }

    final hsl = HSLColor.fromColor(this);
    final swatch = <int, Color>{
      50: hsl.withLightness((hsl.lightness + 0.52).clamp(0, 1)).toColor(),
      100: hsl.withLightness((hsl.lightness + 0.37).clamp(0, 1)).toColor(),
      200: hsl.withLightness((hsl.lightness + 0.26).clamp(0, 1)).toColor(),
      300: hsl.withLightness((hsl.lightness + 0.12).clamp(0, 1)).toColor(),
      400: hsl.withLightness((hsl.lightness + 0.06).clamp(0, 1)).toColor(),
      500: this,
      600: hsl.withLightness((hsl.lightness - 0.06).clamp(0, 1)).toColor(),
      700: hsl.withLightness((hsl.lightness - 0.12).clamp(0, 1)).toColor(),
      800: hsl.withLightness((hsl.lightness - 0.18).clamp(0, 1)).toColor(),
      900: hsl.withLightness((hsl.lightness - 0.24).clamp(0, 1)).toColor(),
    };
    return MaterialColor(value, swatch);
  }

  /// [color]が[Colors.primaries]に含まれていればそのインデックスを、さもなくば-1を返す。
  int indexOfPrimaries() {
    for (int i = 0; i < Colors.primaries.length; ++i) {
      if (Colors.primaries[i].value == value) {
        return i;
      }
    }
    return -1;
  }
}
