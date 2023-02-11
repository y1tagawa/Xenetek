// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'basic.dart';

// スクリプト的モデラ
// メッシュモディファイア
//
// リグ上に配置したメッシュデータを変換する。

/// ビームモディファイア
///
/// メッシュデータの[axis]が[origin]から[target]を向くように回転させる。
/// [connect]が`true`であるとき、[axis]=0.0~1.0が[origin]と[target]になるよう延長する。
/// [proportional]が`true`であるとき、延長に合わせて全体を拡縮する。
class BeamModifier extends MeshModifier {
  final String target;
  final Vector3 axis;
  final bool connect;
  final bool proportional;

  const BeamModifier({
    required this.target,
    this.axis = Vector3.unitY,
    this.connect = false,
    this.proportional = false,
  });

  @override
  MeshData transform({
    required Mesh mesh,
    required Node root,
  }) {
    // origin空間への変換マトリクス
    final origin_ = root.find(path: mesh.origin)!.matrix;
    // targetの変換行列を、origin空間にマップする。
    final target_ = origin_.inverted() * root.find(path: target)!.matrix;
    // 軸線終点をtargetに向ける。
    final rotation = Matrix4.fromForwardTargetRotation(
      forward: Vector3.unitY, // todo: axis
      target: target_.translation,
    );
    // todo: axis
    final scaleY = connect ? target_.translation.length : 1.0;
    final scaleXZ = proportional ? scaleY : 1.0;
    final scale = Matrix4.fromScale(Vector3(scaleXZ, scaleY, scaleXZ));
    return mesh.data.transformed(origin_ * rotation * scale);
  }
}
