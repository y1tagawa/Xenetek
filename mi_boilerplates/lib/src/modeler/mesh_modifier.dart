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
    // rootからoriginへの変換行列
    final originMatrix = root.find(path: mesh.origin)!.matrix;
    // rootからtargetの変換行列を、origin原点に変換
    final targetMatrix = originMatrix.inverted() * root.find(path: target)!.matrix;
    // origin原点から軸線終点をtargetに向ける回転行列
    final rotation = Matrix4.fromForwardTargetRotation(
      forward: Vector3.unitY, // todo: axis
      target: targetMatrix.translation,
    );
    // todo: axis
    // メッシュ拡縮行列
    final scaleY = connect ? targetMatrix.translation.length : 1.0;
    final scaleXZ = proportional ? scaleY : 1.0;
    final scale = Matrix4.fromScale(Vector3(scaleXZ, scaleY, scaleXZ));
    // 全体をroot座標に変換
    return data.transformed(originMatrix * rotation * scale);
  }
}

/// ボーンデータ
class BoneData {
  final double radius;
  final double power;
  const BoneData({
    this.radius = double.maxFinite,
    this.power = 0.5,
  });
}

/// スキンモディファイア
class SkinModifier extends MeshModifier {
  final List<MapEntry<String, BoneData>> bones;
  final Node initRoot; // 初期姿勢のrootノード

  const SkinModifier({
    required this.bones,
    required this.initRoot,
  });

  @override
  MeshData transform({
    required Mesh mesh,
    required MeshData data,
    required Node root,
  }) {
    // 初期姿勢のrootからoriginへの変換行列
    final initOriginMatrix = initRoot.find(path: mesh.origin)!.matrix;
    // 初期姿勢のrootから各ボーンへの変換行列
    final initBoneMatrices = bones.map((it) => initRoot.find(path: it.key)!.matrix).toList();
    // rootからoriginへの変換行列
    final originMatrix = root.find(path: mesh.origin)!.matrix;
    // 各ボーンからrootの変換行列
    final boneMatrices = bones.map((it) => root.find(path: it.key)!.matrix).toList();

    // 各頂点について、
    final vertices = <Vector3>[];
    for (final vertex in data.vertices) {
      // 各ボーンからの相対位置と影響力を集計する。
      final boneValues = <MapEntry<Vector3, double>>[];
      var dominator = 0.0; // 影響力の総和
      // 各ボーンについて...
      final initPos = vertex.transformed(initOriginMatrix);
      for (int i = 0; i < bones.length; ++i) {
        // 初期姿勢におけるボーンからの相対位置を...
        final pos = initPos - initBoneMatrices[i].translation;
        final d = pos.length;
        if (d <= bones[i].value.radius) {
          final value = math.pow(d, bones[i].value.power).toDouble();
          // rootにおけるボーンからの相対位置に変換して、影響力とともにリストアップ
          boneValues.add(MapEntry(pos.transformed(boneMatrices[i]), value));
          dominator += value;
        }
      }
      if (boneValues.isEmpty) {
        // ボーンから影響を受けなかった
        vertices.add(vertex.transformed(originMatrix));
      } else {
        // ボーンからの影響力による加重平均
        var pos = Vector3.zero;
        for (final value in boneValues) {
          pos = pos + value.key * value.value;
        }
        vertices.add(pos / dominator);
      }
    }

    return data.copyWith(
      vertices: vertices,
      normals: <Vector3>[], //todo:
    );
  }
}
