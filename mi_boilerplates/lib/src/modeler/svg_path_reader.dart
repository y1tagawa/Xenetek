// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:logging/logging.dart';

import 'basic.dart';

class SvgPathReader {
  // ignore: unused_field
  static final _logger = Logger('SvgPathReader');

  static Vector3 _takePoint(
    final String field,
  ) {
    assert(field.isNotEmpty);
    final elements = field.split(',');
    assert(elements.length == 2);
    final x = double.tryParse(elements[0]);
    final y = double.tryParse(elements[1]);
    assert(x != null && y != null);
    return Vector3(x!, y!, 0.0);
  }

  // from d attribute
  static List<Vector3> fromString(String data) {
    var fields = data.split(' ').where((it) => it.isNotEmpty);
    var lastPoint = Vector3.zero;
    final points = <Vector3>[];
    void addPoint(Vector3 point) {
      points.add(point);
      lastPoint = point;
      fields = fields.skip(1);
    }

    bool f = false; // 最初の制御点
    fieldLoop:
    while (fields.isNotEmpty) {
      final command = fields.first;
      fields = fields.skip(1);
      _logger.fine('command=$command');
      switch (command) {
        case 'm':
          assert(!f);
          addPoint(lastPoint + _takePoint(fields.first));
          f = true;
          continue fieldLoop;
        case 'M':
          assert(!f);
          addPoint(_takePoint(fields.first));
          f = true;
          continue fieldLoop;
        case 'c':
          assert(f);
          while (fields.isNotEmpty && fields.first.length > 1) {
            addPoint(lastPoint + _takePoint(fields.first));
            addPoint(lastPoint + _takePoint(fields.first));
            addPoint(lastPoint + _takePoint(fields.first));
          }
          continue fieldLoop;
        case 'C':
          assert(f);
          while (fields.isNotEmpty && fields.first.length > 1) {
            addPoint(_takePoint(fields.first));
            addPoint(_takePoint(fields.first));
            addPoint(_takePoint(fields.first));
          }
          continue fieldLoop;
        case 'z':
          break fieldLoop;
        default:
          throw UnimplementedError('command=$command');
      }
    }
    return points;
  }
}
