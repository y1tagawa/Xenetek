// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:logging/logging.dart';

import 'basic.dart';

class SvgPathParser {
  // ignore: unused_field
  static final _logger = Logger('SvgPathReader');

  // todo: アルファベットの後も分離
  static final _lexer = RegExp(r'[A-Za-z]|[-+0-9.e][-+0-9.e]*|[ ,]+');

  /// SVG pathのd形式の文字列を3次Bezier曲線の制御点に変換する。
  static List<Vector3> fromString(String data) {
    bool isField(String field) {
      final c = field.codeUnitAt(0);
      return c != 0x20 && c != 0x2C;
    }

    var fields = _lexer.allMatches(data).map((it) => it[0]!).where((it) => isField(it));
    // _logger.fine('fields=$fields');
    var lastPoint = Vector3.zero;
    final points = <Vector3>[];

    Vector3 takePoint() {
      assert(fields.length >= 2);
      // _logger.fine('fields=$fields');
      final x = double.tryParse(fields.first);
      fields = fields.skip(1);
      final y = double.tryParse(fields.first);
      fields = fields.skip(1);
      assert(x != null && y != null);
      return Vector3(x!, y!, 0.0);
    }

    loop:
    while (fields.isNotEmpty) {
      final command = fields.first;
      fields = fields.skip(1);
      // _logger.fine('command=$command');
      switch (command) {
        case 'm':
          assert(points.isEmpty);
          points.add(lastPoint + takePoint());
          lastPoint = points.last;
          continue fallthrough1;
        fallthrough1:
        case 'l':
          assert(points.isNotEmpty);
          while (fields.isNotEmpty && double.tryParse(fields.first) != null) {
            points.add(points.last);
            points.add(lastPoint + takePoint());
            points.add(points.last);
            lastPoint = points.last;
          }
          break;
        case 'M':
          assert(points.isEmpty);
          points.add(takePoint());
          lastPoint = points.last;
          continue fallthrough2;
        fallthrough2:
        case 'L':
          assert(points.isNotEmpty);
          while (fields.isNotEmpty && double.tryParse(fields.first) != null) {
            points.add(points.last);
            points.add(takePoint());
            points.add(points.last);
            lastPoint = points.last;
          }
          break;
        case 'c':
          assert(points.isNotEmpty);
          while (fields.isNotEmpty && double.tryParse(fields.first) != null) {
            points.add(lastPoint + takePoint());
            points.add(lastPoint + takePoint());
            points.add(lastPoint + takePoint());
            lastPoint = points.last;
          }
          break;
        case 'C':
          assert(points.isNotEmpty);
          while (fields.isNotEmpty && double.tryParse(fields.first) != null) {
            points.add(takePoint());
            points.add(takePoint());
            points.add(takePoint());
            lastPoint = points.last;
          }
          break;
        case 'z':
        case 'Z':
          break loop;
        default:
          throw UnimplementedError('command=$command');
      }
    }
    return points;
  }
}

extension Vector3BezierFormatter on List<Vector3> {
  // ignore: unused_field
  static final _logger = Logger('Vector3BezierFormatter');

  /// 点列をSVG pathのd形式に変換する。
  String toSvgPathData() {
    assert((length - 1) % 3 == 0);
    final buffer = StringBuffer();

    String round(double value) => ((value * 10000).round() / 10000).toString();

    void writePoint(Vector3 point) {
      buffer.write('${round(point.x)} ${round(point.y)} ');
    }

    buffer.write('M ');
    writePoint(first);
    buffer.write('C ');
    for (final point in skip(1)) {
      writePoint(point);
    }
    return buffer.toString();
  }
}
