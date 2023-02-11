// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'basic.dart';

// スクリプト的モデラ
// メッシュモディファイア
//
// リグ上に配置したメッシュデータを変換する。

/// 方向モディファイア
///
/// メッシュデータの[axis]が[origin]から[target]を向くように回転させる。
/// [connect]が`true`であるとき、Y=0.0~1.0が[origin]と[target]になるよう延長する。
/// [proportional]が`true`であるとき、延長に合わせて全体を拡縮する。
class LookAtModifier extends MeshModifier {
  final String target;
  final Vector3 axis; //todo:
  final bool connect;
  final bool proportional;
  //todo: minMargin, maxMargin axisに沿ってminMargin以下、maxMargon以上は端からの距離が変わらないようにする

  const LookAtModifier({
    required this.target,
    this.axis = Vector3.unitY,
    this.connect = false,
    this.proportional = false,
  });

  @override
  MeshData transform({
    required Mesh mesh,
    required MeshData data,
    required Node root,
  }) {
    // root空間におけるorigin空間への変換マトリクス
    final origin_ = root.find(path: mesh.origin)!.matrix;
    // targetの変換行列を、origin空間にマップする。
    final target_ = origin_.inverted() * root.find(path: target)!.matrix;
    // origin空間において、軸線終点をtargetに向ける。
    final rotation = Matrix4.fromForwardTargetRotation(
      forward: Vector3.unitY, // todo: axis
      target: target_.translation,
    );
    // todo: axis
    // 必要に応じて変形し...
    final scaleY = connect ? target_.translation.length : 1.0;
    final scaleXZ = proportional ? scaleY : 1.0;
    final scale = Matrix4.fromScale(Vector3(scaleXZ, scaleY, scaleXZ));
    // 全体をルート空間にマップする。
    return data.transformed(origin_ * rotation * scale);
  }
}

/// ボーンデータ
class BoneData {
  final double radius;
  final double power;
  const BoneData({
    this.radius = double.maxFinite,
    this.power = 2.0,
  });
}

/// スキンモディファイア
class SkinModifier extends MeshModifier {
  final List<MapEntry<String, BoneData>> bones;
  final Node init; // 初期姿勢のrootノード

  const SkinModifier({
    required this.bones,
    required this.init,
  });

  @override
  MeshData transform({
    required Mesh mesh,
    required MeshData data,
    required Node root,
  }) {
    // 初期空間におけるoriginへの変換行列
    final zeroOrigin_ = init.find(path: mesh.origin)!.matrix;
    final zi = zeroOrigin_.inverted();
    // 初期空間への各ボーンの変換行列
    final zeros_ = bones.map((it) => zi * init.find(path: it.key)!.matrix).toList();
    // root空間におけるoriginへの変換行列
    final origin_ = init.find(path: mesh.origin)!.matrix;
    final oi = origin_.inverted();
    // root空間への各ボーンの変換行列
    final targets_ = bones.map((it) => oi * root.find(path: it.key)!.matrix).toList();

    // 各頂点について...
    final vertices = <Vector3>[];
    for (final vertex in data.vertices) {
      // 初期姿勢の位置
      final zPos = vertex.transformed(zeroOrigin_);
      // rootにおける各ボーンからの相対位置と影響
      final targetValues = <MapEntry<Vector3, double>>[];
      var dominator = 0.0;
      for (int i = 0; i < bones.length; ++i) {
        // 初期姿勢における各ボーンからの相対位置
        final pos = zPos - zeros_[i].translation;
        final d = pos.length;
        if (d > 1e-4 && d <= bones[i].value.radius) {
          final value = 1.0 / math.pow(d, bones[i].value.power);
          targetValues.add(MapEntry(pos.transformed(targets_[i]), value));
          dominator += value;
        }
      }
      if (targetValues.isEmpty) {
        // ボーンから影響を受けなかった
        vertices.add(zPos);
      } else {
        // ボーンからの影響の加重平均
        var pos = Vector3.zero;
        for (final targetValue in targetValues) {
          pos = pos + targetValue.key * targetValue.value;
        }
        vertices.add(pos * (1.0 / dominator));
      }
    }

    return data.copyWith(
      vertices: vertices,
      normals: <Vector3>[], //todo:
    );
  }
}
