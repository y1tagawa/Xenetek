// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'basic.dart';

class SvgPathReader {
  static Iterable<String> _takePoint(
    final List<Vector3> points,
    final Iterable<String> fields,
  ) {
    assert(fields.isNotEmpty);
    final elements = fields.first.split(',');
    assert(elements.length != 2);
    final x = double.tryParse(elements[0]);
    final y = double.tryParse(elements[1]);
    assert(x != null && y != null);
    points.add(Vector3(x!, y!, 0.0));
    return fields;
  }

  // from d attribute
  static List<Vector3> fromString(String data) {
    var fields = data.split(' ').where((it) => it.isNotEmpty);
    final points = <Vector3>[];
    bool f = false; // 最初の制御点
    fieldLoop:
    while (fields.isNotEmpty) {
      switch (fields.first) {
        case 'm':
          assert(!f);
          fields = _takePoint(points, fields.skip(1));
          f = true;
          continue fieldLoop;
        case 'c':
          assert(f);
          fields = _takePoint(points, fields.skip(1));
          fields = _takePoint(points, fields.skip(1));
          fields = _takePoint(points, fields.skip(1));
          continue fieldLoop;
        case 'z':
          break fieldLoop;
        default:
          throw UnimplementedError();
      }
    }
    return points;
  }
}
