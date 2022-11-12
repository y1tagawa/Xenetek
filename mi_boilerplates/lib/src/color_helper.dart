// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

int? _tryAsInt(dynamic value) {
  return value is int ? value : null;
}

extension ColorHelper on Color {
  // static final _colorPattern = RegExp(r'^Color\((\w+)\)$');
  // static Color? fromString(String input) {
  //   return _colorPattern
  //       .firstMatch(input)
  //       ?.group(1)
  //       ?.let((it) => int.tryParse(it))
  //       ?.let((it) => Color(it));
  // }

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

extension MaterialColorHelper on MaterialColor {
  ///
  static MaterialColor? tryParseJson(Map<String, dynamic> json) {
    final value = _tryAsInt(json['value']);
    if (value == null) return null;
    final shade50 = _tryAsInt(json['50']);
    final shade100 = _tryAsInt(json['100']);
    final shade200 = _tryAsInt(json['200']);
    final shade300 = _tryAsInt(json['300']);
    final shade400 = _tryAsInt(json['400']);
    final shade500 = _tryAsInt(json['500']);
    final shade600 = _tryAsInt(json['600']);
    final shade700 = _tryAsInt(json['700']);
    final shade800 = _tryAsInt(json['800']);
    final shade900 = _tryAsInt(json['900']);
    final swatch = <int, Color>{
      if (shade50 != null) 50: Color(shade50),
      if (shade100 != null) 100: Color(shade100),
      if (shade200 != null) 200: Color(shade200),
      if (shade300 != null) 300: Color(shade300),
      if (shade400 != null) 400: Color(shade400),
      if (shade500 != null) 500: Color(shade500),
      if (shade600 != null) 600: Color(shade600),
      if (shade700 != null) 700: Color(shade700),
      if (shade800 != null) 800: Color(shade800),
      if (shade900 != null) 900: Color(shade900),
    };
    return MaterialColor(value, swatch);
  }

  ///
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'value': value,
      if (this[50] != null) '50': this[50]!.value,
      if (this[100] != null) '100': this[100]!.value,
      if (this[200] != null) '200': this[200]!.value,
      if (this[300] != null) '300': this[300]!.value,
      if (this[400] != null) '400': this[400]!.value,
      if (this[500] != null) '500': this[500]!.value,
      if (this[600] != null) '600': this[600]!.value,
      if (this[700] != null) '700': this[700]!.value,
      if (this[800] != null) '800': this[800]!.value,
      if (this[900] != null) '900': this[900]!.value,
    };
  }
}
