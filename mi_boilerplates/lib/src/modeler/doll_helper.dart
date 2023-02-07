// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'basic.dart';
import 'doll.dart';

// スクリプト的ドール(mk1)モデラ拡張
// todo: むしろこの辺はdool.dartに

extension NodeHelper on Node {
  // ポージング

  Node _rotate(String path, Vector3 axis, double radians) => transform(
        path: path,
        matrix: Matrix4.fromAxisAngleRotation(
          axis: axis,
          radians: radians,
        ),
      );

  double _toRadians(double? radians, double? degrees) {
    if (radians != null) {
      assert(degrees == null);
      return radians;
    }
    assert(degrees != null);
    return degrees! * math.pi / 180.0;
  }

  // 頸
  Node bendNeck({double? radians, double? degrees}) {
    final radians_ = _toRadians(radians, degrees) * 0.5;
    return _rotate(HumanRig.neck, Vector3.unitX, radians_)
        ._rotate(HumanRig.head, Vector3.unitX, radians_);
  }

  // 右胸鎖関節
  //todo: テスト、それとIK的な腕の全関節の動き関数
  Node bendRSc({double? radians, double? degrees}) =>
      _rotate(HumanRig.rSc, Vector3.unitY, _toRadians(radians, degrees));
  Node twistRSc({double? radians, double? degrees}) =>
      _rotate(HumanRig.rSc, -Vector3.unitZ, _toRadians(radians, degrees));

  // 右肩
  Node bendRShoulder({double? radians, double? degrees}) =>
      _rotate(HumanRig.rShoulder, -Vector3.unitZ, _toRadians(radians, degrees));
  Node twistRShoulder({double? radians, double? degrees}) =>
      _rotate(HumanRig.rShoulder, Vector3.unitX, _toRadians(radians, degrees));
  Node swingRShoulder({double? radians, double? degrees}) =>
      _rotate(HumanRig.rShoulder, Vector3.unitY, _toRadians(radians, degrees));

  // 左肩
  Node bendLShoulder({double? radians, double? degrees}) =>
      _rotate(HumanRig.lShoulder, Vector3.unitZ, _toRadians(radians, degrees));

  // 右肘
  Node bendRElbow({double? radians, double? degrees}) =>
      _rotate(HumanRig.rElbow, Vector3.unitY, _toRadians(radians, degrees));

  // 左肘
  Node bendLElbow({double? radians, double? degrees}) =>
      _rotate(HumanRig.lElbow, -Vector3.unitY, _toRadians(radians, degrees));
  // todo: 手首

}
