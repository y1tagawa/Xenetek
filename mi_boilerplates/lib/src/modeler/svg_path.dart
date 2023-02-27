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

    void addPoint(Vector3 point) {
      points.add(point);
    }

    fieldLoop:
    while (fields.isNotEmpty) {
      final command = fields.first;
      fields = fields.skip(1);
      _logger.fine('command=$command');
      switch (command) {
        case 'm':
          assert(points.isEmpty);
          addPoint(lastPoint + takePoint());
          lastPoint = points.last;
          continue CASE_LL;
        CASE_LL:
        case 'l':
          assert(points.isNotEmpty);
          while (fields.isNotEmpty && _command.stringMatch(fields.first) == null) {
            addPoint(points.last);
            addPoint(lastPoint + takePoint());
            addPoint(points.last);
            lastPoint = points.last;
          }
          continue fieldLoop;
        case 'M':
          assert(points.isEmpty);
          addPoint(takePoint());
          lastPoint = points.last;
          continue CASE_L;
        CASE_L:
        case 'L':
          assert(points.isNotEmpty);
          while (fields.isNotEmpty && _command.stringMatch(fields.first) == null) {
            addPoint(points.last);
            addPoint(takePoint());
            addPoint(points.last);
            lastPoint = points.last;
          }
          continue fieldLoop;
        case 'c':
          assert(points.isNotEmpty);
          while (fields.isNotEmpty && _command.stringMatch(fields.first) == null) {
            addPoint(lastPoint + takePoint());
            addPoint(lastPoint + takePoint());
            addPoint(lastPoint + takePoint());
            lastPoint = points.last;
          }
          continue fieldLoop;
        case 'C':
          assert(points.isNotEmpty);
          while (fields.isNotEmpty && _command.stringMatch(fields.first) == null) {
            addPoint(takePoint());
            addPoint(takePoint());
            addPoint(takePoint());
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
