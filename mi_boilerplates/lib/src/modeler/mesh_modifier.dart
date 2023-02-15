// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

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
@immutable
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
    // originからrootへの変換行列
    final originMatrix = root.find(path: mesh.origin)!.matrix;
    // targetからrootの変換行列を、origin原点に変換
    final targetMatrix = originMatrix.inverted() * root.find(path: target)!.matrix;
    // origin原点から軸線終点をtargetに向ける回転行列
    // todo: rotationでaxisをunitYに変換
    final rotation = Matrix4.fromForwardTargetRotation(
      forward: Vector3.unitY,
      target: targetMatrix.translation,
    );
    // メッシュ拡縮行列
    final scaleY = connect ? targetMatrix.translation.length : 1.0;
    final scaleXZ = proportional ? scaleY : 1.0;
    final scale = Matrix4.fromScale(Vector3(scaleXZ, scaleY, scaleXZ));
    // 全体をroot座標に変換
    // todo: rotationでunitYをaxisに戻す
    return data.transformed(rotation * scale);
  }
}

/// ボーン
@immutable
class BoneData {
  final double radius;
  final double force;
  final double power;
  const BoneData({
    this.radius = double.maxFinite,
    this.force = 1.0,
    this.power = -2,
  }) : assert(radius >= 1e-4);
}

/// スキンモディファイア
@immutable
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
    // 初期姿勢のoriginからrootへの変換行列
    final initOriginMatrix = initRoot.find(path: mesh.origin)!.matrix;
    // 初期姿勢の各ボーンからrootへの変換行列とその逆
    final initBoneMatrices = bones.map((it) => initRoot.find(path: it.key)!.matrix).toList();
    final initInvBoneMatrices = initBoneMatrices.map((it) => it.inverted()).toList();
    // originからrootへの変換行列
    final originMatrix = root.find(path: mesh.origin)!.matrix;
    // 各ボーンからrootへの変換行列
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
        final bone = bones[i].value;
        // 初期姿勢におけるボーンからの相対位置を...
        final p = initPos.transformed(initInvBoneMatrices[i]);
        final d = p.length;
        if (d <= bone.radius) {
          // todo: shape
          // 影響力(距離0において1.0、以後距離のpower乗に比例して0に漸近)
          // gnuplot> plot [0:2][0:1] (x+1)**-2
          final value = bone.force * math.pow(d + 1.0, bone.power);
          // rootにおけるボーンからの相対位置に変換して、影響力とともにリストアップ
          boneValues.add(
            MapEntry(
              p.transformed(boneMatrices[i]),
              value,
            ),
          );
          dominator += value;
        }
      }
      if (boneValues.isEmpty) {
        // ボーンから影響を受けなかった
        vertices.add(vertex);
      } else {
        // ボーンからの影響力による加重平均
        var p = Vector3.zero;
        for (final value in boneValues) {
          p = p + value.key * value.value;
        }
        vertices.add(p / dominator);
      }
    }

    return data.copyWith(
      vertices: vertices,
      normals: <Vector3>[],
    ).transformed(originMatrix.inverted());
  }
}

/// 磁石
@immutable
class MagnetData {
  final double radius;
  final double force;
  final double power;
  final Vector3 shape;
  final bool mirror;

  const MagnetData({
    this.radius = double.maxFinite,
    this.force = 1.0,
    this.power = -2,
    this.shape = Vector3.one,
    this.mirror = false,
  }) : assert(radius >= 1e-4);
}

/// マグネットモディファイア
@immutable
class MagnetModifier extends MeshModifier {
  // ignore: unused_field
  static final _logger = Logger('MagnetModifier');

  final List<MapEntry<String, MagnetData>> magnets;

  const MagnetModifier({required this.magnets});

  @override
  MeshData transform({
    required Mesh mesh,
    required MeshData data,
    required Node root,
  }) {
    // rootからoriginへの変換行列
    final originMatrix = root.find(path: mesh.origin)!.matrix;
    // rootから各磁石への変換行列
    final magnetMatrices = magnets.map((it) => root.find(path: it.key)!.matrix).toList();
    final magnetRotations = magnetMatrices.map((it) => it.rotation).toList();
    final invMagnetRotations = magnetRotations.map((it) => it.inverted()).toList();

    // 頂点変形
    final vertices = <Vector3>[];
    // 各頂点について...
    for (final vertex in data.vertices) {
      final p = vertex.transformed(originMatrix);
      // 各磁石からの力を集計
      var delta = Vector3.zero;
      for (int i = 0; i < magnets.length; ++i) {
        // 各磁石について...
        final magnet = magnets[i].value;
        // 磁石から見た頂点の方向
        // todo: shape
        final v = p - magnetMatrices[i].translation;
        final d = v.length;
        if (d >= 1e-6 && d <= magnet.radius) {
          delta = delta + v * magnet.force * math.pow(d + 1.0, magnet.power);
        }
      }
      vertices.add(p - delta);
    }
    return data.copyWith(
      vertices: vertices,
      normals: <Vector3>[],
    ).transformed(originMatrix.inverted());
  }
}
