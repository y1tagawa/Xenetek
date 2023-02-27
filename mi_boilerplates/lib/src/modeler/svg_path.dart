// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:logging/logging.dart';

import 'basic.dart';

class SvgPathParser {
  // ignore: unused_field
  static final _logger = Logger('SvgPathReader');

  // todo: アルファベットの後も分離
  static final _delimiter = RegExp(r'[ ,]+');
  static final _command = RegExp(r'^[A-Za-z]$');

  // from d attribute
  static List<Vector3> fromString(String data) {
    var fields = data.split(_delimiter).where((it) => it.isNotEmpty);
    _logger.fine('fields=$fields');
    var lastPoint = Vector3.zero;
    final points = <Vector3>[];

    Vector3 takePoint() {
      assert(fields.length >= 2);
      _logger.fine('fields=$fields');
      final x = double.tryParse(fields.first);
      fields = fields.skip(1);
      final y = double.tryParse(fields.first);
      fields = fields.skip(1);
      assert(x != null && y != null);
      return Vector3(x!, y!, 0.0);
    }

    fieldLoop:
    while (fields.isNotEmpty) {
      final command = fields.first;
      fields = fields.skip(1);
      _logger.fine('command=$command');
      switch (command) {
        case 'm':
          assert(points.isEmpty);
          points.add(lastPoint + takePoint());
          lastPoint = points.last;
          continue CASE_LL;
        CASE_LL:
        case 'l':
          assert(points.isNotEmpty);
          while (fields.isNotEmpty && _command.stringMatch(fields.first) == null) {
            points.add(points.last);
            points.add(lastPoint + takePoint());
            points.add(points.last);
            lastPoint = points.last;
          }
          continue fieldLoop;
        case 'M':
          assert(points.isEmpty);
          points.add(takePoint());
          lastPoint = points.last;
          continue CASE_L;
        CASE_L:
        case 'L':
          assert(points.isNotEmpty);
          while (fields.isNotEmpty && _command.stringMatch(fields.first) == null) {
            points.add(points.last);
            points.add(takePoint());
            points.add(points.last);
            lastPoint = points.last;
          }
          continue fieldLoop;
        case 'c':
          assert(points.isNotEmpty);
          while (fields.isNotEmpty && _command.stringMatch(fields.first) == null) {
            points.add(lastPoint + takePoint());
            points.add(lastPoint + takePoint());
            points.add(lastPoint + takePoint());
            lastPoint = points.last;
          }
          continue fieldLoop;
        case 'C':
          assert(points.isNotEmpty);
          while (fields.isNotEmpty && _command.stringMatch(fields.first) == null) {
            points.add(takePoint());
            points.add(takePoint());
            points.add(takePoint());
            lastPoint = points.last;
          }
          continue fieldLoop;
        case 'z':
        case 'Z':
          break fieldLoop;
        default:
          throw UnimplementedError('command=$command');
      }
    }
    return points;
  }
}

extension Vector3BezierFormatter on Bezier<Vector3> {
  // ignore: unused_field
  static final _logger = Logger('Vector3BezierFormatter');

  String toSvgPathData() {
    assert((points.length - 1) % 3 == 0);
    final buffer = StringBuffer();

    double round(double value) => (value * 10000).round() / 10000;

    void writePoint(Vector3 point) {
      buffer.write('${round(point.x)} ${round(point.y)} ');
    }

    buffer.write('M ');
    writePoint(points.first);
    buffer.write('C ');
    for (final point in points.skip(1)) {
      writePoint(point);
    }
    return buffer.toString();
  }
}
