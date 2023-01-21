// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

extension GradientHelper on Gradient {
  /// [Gradient]を描画した[ui.Image]を生成する
  Future<ui.Image> toImage({
    int width = 100,
  }) async {
    assert(width > 1);
    final pictureRecorder = ui.PictureRecorder();
    final canvas = ui.Canvas(pictureRecorder);
    final paint = ui.Paint()..shader = createShader(Rect.fromLTWH(0, 0, width.toDouble(), 1));
    canvas.drawPaint(paint);
    final picture = pictureRecorder.endRecording();
    return await picture.toImage(width, 1);
  }

  Future<List<Color>> toColors({
    int length = 100,
    bool growable = false,
  }) async {
    final image = await toImage(width: length);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final colors = List.generate(length, (index) {
      final i = index * 4;
      return Color.fromARGB(
        byteData!.getUint8(i + 3),
        byteData.getUint8(i),
        byteData.getUint8(i + 1),
        byteData.getUint8(i + 2),
      );
    }, growable: growable);
    image.dispose();
    return colors;
  }
}
