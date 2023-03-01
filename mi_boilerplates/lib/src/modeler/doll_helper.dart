// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'basic.dart';
import 'human_rig_builder.dart';

// スクリプト的ドール(mk1)モデラ拡張
// todo: むしろこの辺はdoll.dartに

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
    return _rotate(HumanRigBuilder.neck, Vector3.unitX, radians_)
        ._rotate(HumanRigBuilder.head, Vector3.unitX, radians_);
  }

  Node twistNeck({double? radians, double? degrees}) {
    final radians_ = _toRadians(radians, degrees) * 0.5;
    return _rotate(HumanRigBuilder.neck, Vector3.unitY, radians_)
        ._rotate(HumanRigBuilder.head, Vector3.unitY, radians_);
  }

  // 右下肢
  Node twistRCoxa({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.rCoxa, Vector3.unitY, _toRadians(radians, degrees));
  Node swingRCoxa({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.rCoxa, Vector3.unitZ, _toRadians(radians, degrees));
  Node swingRAnkle({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.rAnkle, Vector3.unitZ, _toRadians(radians, degrees));

  // 左下肢
  Node twistLCoxa({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.lCoxa, Vector3.unitY, _toRadians(radians, degrees));
  Node swingLCoxa({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.lCoxa, Vector3.unitZ, _toRadians(radians, degrees));
  Node swingLAnkle({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.lAnkle, Vector3.unitZ, _toRadians(radians, degrees));

  // 右上肢
  //todo: テスト、それとIK的な腕の全関節の動き関数
  Node bendRSc({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.rSc, Vector3.unitY, _toRadians(radians, degrees));
  Node twistRSc({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.rSc, -Vector3.unitZ, _toRadians(radians, degrees));
  Node bendRShoulder({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.rShoulder, -Vector3.unitZ, _toRadians(radians, degrees));
  Node twistRShoulder({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.rShoulder, Vector3.unitX, _toRadians(radians, degrees));
  Node swingRShoulder({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.rShoulder, Vector3.unitY, _toRadians(radians, degrees));
  Node bendRElbow({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.rElbow, Vector3.unitY, _toRadians(radians, degrees));
  // todo: 手首

  // 左上肢
  Node bendLShoulder({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.lShoulder, Vector3.unitZ, _toRadians(radians, degrees));
  Node bendLElbow({double? radians, double? degrees}) =>
      _rotate(HumanRigBuilder.lElbow, -Vector3.unitY, _toRadians(radians, degrees));
  // todo: 手首

}
