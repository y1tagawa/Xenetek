// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../scope_functions.dart';
import 'basic.dart';

// スクリプト的モデラ
// メッシュモディファイア
//
// リグ上に配置したメッシュデータを変換する。

/// 芯材モディファイア
///
/// Y軸[0,1]に沿ってBスプラインによって変形する。
@immutable
class WickModifier extends MeshModifier {
  // ignore: unused_field
  static final _logger = Logger('name');

  final List<Vector3> wicking; // Y=[0,1]に対応する中心線
  final List<double> twist; // Y=[0,1]に対応するY軸周りの回転(ラジアン)
  final List<double> width; // Y=[0,1]に対応するX半径
  final List<double> depth; // Y=[0,1]に対応するX半径

  const WickModifier({
    required this.wicking,
    this.twist = const <double>[0.0],
    this.width = const <double>[1.0],
    this.depth = const <double>[1.0],
  });

  @override
  MeshData transform({required Mesh mesh, required MeshData data, required Node root}) {
    final wicking_ = BezierVector3(points: wicking);
    final twist_ = BezierDouble(points: twist);
    final width_ = BezierDouble(points: width);
    final depth_ = BezierDouble(points: depth);
    final vertices = <Vector3>[];
    for (final vertex in data.vertices) {
      final t = vertex.y; // 0.0-1.0
      final p = wicking_.transform(t);
      final p1 = wicking_.transform(t - 0.01);
      final p2 = wicking_.transform(t + 0.01);
      vertices.add(vertex.transformed(
        Matrix4.fromTranslation(p) *
            Matrix4.fromForwardTargetRotation(forward: p - p1, target: p2 - p) *
            Matrix4.fromAxisAngleRotation(axis: Vector3.unitY, radians: twist_.transform(t)) *
            Matrix4.fromScale(Vector3(width_.transform(t), 1, depth_.transform(t))),
      ));
    }
    return data.copyWith(
      vertices: vertices,
      normals: <Vector3>[],
    );
  }
}

/// ボックスモディファイア
///
/// メッシュデータを[min]-[max]をバウンディングボックスとする直方体の中にマップする。
/// 頂点は面に使用されていなくともよい。
@immutable
class BoxModifier extends MeshModifier {
  final Vector3 min;
  final Vector3 max;
  const BoxModifier({
    required this.min,
    required this.max,
  });

  @override
  MeshData transform({
    required Mesh mesh,
    required MeshData data,
    required Node root,
  }) {
    if (data.vertices.isEmpty) {
      return data;
    }
    Vector3 vMin = data.vertices.first, vMax = vMin;
    for (final v in data.vertices.skip(1)) {
      vMin = Vector3(math.min(v.x, vMin.x), math.min(v.y, vMin.y), math.min(v.z, vMin.z));
      vMax = Vector3(math.max(v.x, vMax.x), math.max(v.y, vMax.y), math.max(v.z, vMax.z));
    }
    final box = max - min;
    final w = (vMax.x - vMin.x).let((it) => it.abs() < 1e-4 ? 0.0 : it);
    final h = (vMax.y - vMin.y).let((it) => it.abs() < 1e-4 ? 0.0 : it);
    final d = (vMax.z - vMin.z).let((it) => it.abs() < 1e-4 ? 0.0 : it);
    final vertices = data.vertices
        .map(
          (it) => Vector3(
            w == 0.0 ? it.x : (it.x - vMin.x) * box.x / w + min.x,
            h == 0.0 ? it.y : (it.y - vMin.y) * box.y / h + min.y,
            d == 0.0 ? it.z : (it.z - vMin.z) * box.z / d + min.z,
          ),
        )
        .toList();
    return data.copyWith(vertices: vertices);
  }
}

/// 方向モディファイア
///
/// メッシュデータの[axis]が[origin]から[target]を向くように回転させる。
/// [connect]が`true`であるとき、Y=0.0~1.0が[origin]と[target]になるよう延長する。
/// [proportional]が`true`であるとき、延長に合わせて全体を拡縮する。
/// [minSlice], [maxSlice]がともに指定されたとき、その間の頂点のみ延長される。
@immutable
class LookAtModifier extends MeshModifier {
  // ignore: unused_field
  static final _logger = Logger('LookAtModifier');

  final String target;
  final Vector3 axis; //todo:
  final bool connect;
  final bool proportional;
  final double minSlice;
  final double maxSlice;

  const LookAtModifier({
    required this.target,
    this.axis = Vector3.unitY,
    this.connect = false,
    this.proportional = false,
    this.minSlice = double.infinity,
    this.maxSlice = double.infinity,
  }) : assert((minSlice == double.infinity) == (maxSlice == double.infinity));

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
    // メッシュ拡縮
    MeshData data_ = data;
    if (connect) {
      final scaleY = connect ? targetMatrix.translation.length : 1.0;
      final scaleXZ = proportional ? scaleY : 1.0;
      if (minSlice != double.infinity && maxSlice != double.infinity) {
        // スライス拡縮
        data_ = data.copyWith(
          vertices: data.vertices.map((it) {
            if (it.y < minSlice) {
              return Vector3(it.x * scaleXZ, it.y, it.z * scaleXZ);
            } else if (it.y < maxSlice) {
              return Vector3(it.x * scaleXZ, (it.y - minSlice) * scaleY + minSlice, it.z * scaleXZ);
            } else {
              return Vector3(it.x * scaleXZ, (it.y - maxSlice) + scaleY * maxSlice, it.z * scaleXZ);
            }
          }).toList(),
        );
      } else {
        // 一様拡縮
        data_ = data.transformed(Matrix4.fromScale(Vector3(scaleXZ, scaleY, scaleXZ)));
      }
    }
    // 全体をroot座標に変換
    // todo: rotationでunitYをaxisに戻す
    return data_.transformed(rotation);
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
  final Node rRoot; // 初期姿勢のrootノード

  const SkinModifier({
    required this.bones,
    required this.rRoot,
  });

  @override
  MeshData transform({
    required Mesh mesh,
    required MeshData data,
    required Node root,
  }) {
    // 初期姿勢のoriginからrootへの変換行列
    final rOriginMatrix = rRoot.find(path: mesh.origin)!.matrix;
    // 初期姿勢の各ボーンからrootへの変換行列とその逆
    final rBoneMatrices = bones.map((it) => rRoot.find(path: it.key)!.matrix).toList();
    final rInvBoneMatrices = rBoneMatrices.map((it) => it.inverted()).toList();
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
      final rPos = vertex.transformed(rOriginMatrix);
      for (int i = 0; i < bones.length; ++i) {
        final bone = bones[i].value;
        // 初期姿勢におけるボーンからの相対位置を...
        final p = rPos.transformed(rInvBoneMatrices[i]);
        final d = p.length;
        if (d <= bone.radius) {
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
  final bool mirror;

  const MagnetData({
    this.radius = double.maxFinite,
    this.force = 1.0,
    this.power = -2,
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
    final invOriginMatrix = originMatrix.inverted();
    // originから各磁石への変換行列
    final magnets_ = <MapEntry<Vector3, MagnetData>>[];
    for (final magnet in magnets) {
      final p = (invOriginMatrix * root.find(path: magnet.key)!.matrix).translation;
      magnets_.add(MapEntry(p, magnet.value));
      if (magnet.value.mirror) {
        magnets_.add(MapEntry(p.mirrored(), magnet.value));
      }
    }

    // 頂点変形
    final vertices = <Vector3>[];
    // 各頂点について...
    for (final vertex in data.vertices) {
      //final p = vertex.transformed(originMatrix);
      // 各磁石からの力を集計
      var delta = Vector3.zero;
      for (final magnet in magnets_) {
        final v = magnet.key - vertex;
        final d = v.length;
        if (d >= 1e-6 && d <= magnet.value.radius) {
          // 距離による減衰
          delta += v.normalized() * magnet.value.force * math.pow(d + 1.0, magnet.value.power);
        }
      }
      vertices.add(vertex + delta);
    }
    return data.copyWith(
      vertices: vertices,
      normals: <Vector3>[],
    );
  }
}
