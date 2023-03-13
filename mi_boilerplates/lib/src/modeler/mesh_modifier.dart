// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../helpers.dart';
import 'basic.dart';

// スクリプト的モデラ
// メッシュモディファイア
//
// リグ上に配置したメッシュデータを変換する。

/// 分身モディファイア
@immutable
class MultipleModifier extends MeshModifier {
  // ignore: unused_field
  static final _logger = Logger('MultipleModifier');

  final List<Matrix4> matrices;

  const MultipleModifier({
    required this.matrices,
  });

  @override
  MeshData transform({required Mesh mesh, required MeshData data, required Node root}) {
    final data_ = <MeshObject>[];
    for (final matrix in matrices) {
      for (final object in data) {
        data_.add(object.transformed(matrix));
      }
    }
    return data_;
  }
}

/// パラメトリックモディファイア
///
/// Y軸[0,1]に沿って、各頂点をパラメトリック曲線によって変形する。
@immutable
class ParametricModifier extends MeshModifier {
  // ignore: unused_field
  static final _logger = Logger('ParametricModifier');

  final Parametric<double, Vector3> bend; // Y=[0,1]に対応する中心線
  final Parametric<double, double> twist; // Y=[0,1]に対応するY軸周りの捻り(ラジアン)
  final Parametric<double, double> width; // Y=[0,1]に対応するX方向の拡縮
  final Parametric<double, double> depth; // Y=[0,1]に対応するZ方向の拡縮
  //todo: axis

  const ParametricModifier({
    this.bend = const BezierVector3(points: <Vector3>[Vector3.zero, Vector3.unitY]),
    this.twist = const BezierDouble(points: <double>[0.0]),
    this.width = const BezierDouble(points: <double>[1.0]),
    this.depth = const BezierDouble(points: <double>[1.0]),
  });

  @override
  MeshData transform({required Mesh mesh, required MeshData data, required Node root}) {
    final data_ = <MeshObject>[];
    for (final object in data) {
      final vertices = <Vector3>[];
      for (final vertex in object.vertices) {
        final t = vertex.y; // 0.0-1.0
        final p = bend.transform(t); // (0,y,0)->p
        final f = t >= 0.01 ? p - bend.transform(t - 0.01) : bend.transform(t + 0.01) - p;
        // 頂点を、(0,y,0)を中心に、捻り、XZ拡縮ののち曲線の接線に沿って回転
        final v = vertex.copyWith(y: 0).transformed(
            Matrix4.fromForwardTargetRotation(forward: Vector3.unitY, target: f) *
                Matrix4.fromAxisAngleRotation(axis: Vector3.unitY, radians: twist.transform(t)) *
                Matrix4.fromScale(Vector3(width.transform(t), 1, depth.transform(t))));
        // (0,y,0)を、対応する曲線上の点に平行移動
        vertices.add(v + p);
      }
      data_.add(
        object.copyWith(
          vertices: vertices,
          normals: <Vector3>[],
        ),
      );
    }
    return data_;
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
    bool f = false;
    var min_ = Vector3.zero, max_ = Vector3.zero;
    for (final object in data) {
      if (object.vertices.isEmpty) {
        continue;
      }
      if (!f) {
        min_ = object.vertices.first;
        max_ = object.vertices.first;
        f = true;
      }
      for (final v in object.vertices) {
        min_ = Vector3(math.min(v.x, min_.x), math.min(v.y, min_.y), math.min(v.z, min_.z));
        max_ = Vector3(math.max(v.x, max_.x), math.max(v.y, max_.y), math.max(v.z, max_.z));
      }
    }
    if (!f) {
      return data;
    }
    final box = max - min;
    final w = (max_.x - min_.x).let((it) => it.abs() < 1e-4 ? 0.0 : it);
    final h = (max_.y - min_.y).let((it) => it.abs() < 1e-4 ? 0.0 : it);
    final d = (max_.z - min_.z).let((it) => it.abs() < 1e-4 ? 0.0 : it);
    final data_ = <MeshObject>[];
    for (final object in data) {
      final vertices = <Vector3>[];
      for (final vertex in object.vertices) {
        vertices.add(
          Vector3(
            (w == 0.0 ? 0.0 : (vertex.x - min_.x) * box.x / w) + min.x,
            (h == 0.0 ? 0.0 : (vertex.y - min_.y) * box.y / h) + min.y,
            (d == 0.0 ? 0.0 : (vertex.z - min_.z) * box.z / d) + min.z,
          ),
        );
      }
      data_.add(
        object.copyWith(
          vertices: vertices,
        ),
      );
    }
    return data_;
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
    final data_ = <MeshObject>[];
    for (final object in data) {
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
      var object_ = object;
      if (connect) {
        final scaleY = connect ? targetMatrix.translation.length : 1.0;
        final scaleXZ = proportional ? scaleY : 1.0;
        if (minSlice != double.infinity && maxSlice != double.infinity) {
          // スライス拡縮
          object_ = object.copyWith(
            vertices: object.vertices.map((it) {
              if (it.y < minSlice) {
                return Vector3(it.x * scaleXZ, it.y, it.z * scaleXZ);
              } else if (it.y < maxSlice) {
                return Vector3(
                    it.x * scaleXZ, (it.y - minSlice) * scaleY + minSlice, it.z * scaleXZ);
              } else {
                return Vector3(
                    it.x * scaleXZ, (it.y - maxSlice) + scaleY * maxSlice, it.z * scaleXZ);
              }
            }).toList(),
          );
        } else {
          // 一様拡縮
          object_ = object.transformed(Matrix4.fromScale(Vector3(scaleXZ, scaleY, scaleXZ)));
        }
      }
      // 全体をroot座標に変換
      // todo: rotationでunitYをaxisに戻す
      data_.add(object_.transformed(rotation));
    }
    return data_;
  }
}

/// ボーンの種類
enum BoneType { type1, type2 }

/// ボーン
@immutable
class BoneData {
  final double radius;
  final double strength;
  final int exponent;
  final BoneType type;
  const BoneData({
    this.radius = 1.0,
    this.strength = 1.0,
    this.exponent = 3,
    this.type = BoneType.type1,
  }) : assert(radius >= 1e-4); //,
  //assert(exponent > 0);

  /// ボーンまたは磁石による影響
  ///
  /// 力の中心からの距離[distance]にある頂点の移動量を算出する。
  /// 式1、
  ///   力は距離0において[strength], 距離[radius]において0となる[exponent]次曲線にしたがい減衰する。
  ///   gnuplotによる[radius]=0.5, [exponent]=1,2,3の減衰曲線の例:
  ///   r=0.5
  ///   plot [0:1][0:1] -(x/r-1),(x/r-1)**2,-(x/r-1)**3
  /// 式
  double valueOf(double distance) {
    switch (type) {
      case BoneType.type1:
        assert(exponent > 0);
        if (distance >= radius) {
          return 0.0;
        }
        if (distance <= 1e-4) {
          return strength * distance;
        }
        final sign = exponent % 2 == 0 ? 1.0 : -1.0;
        return strength * math.min(distance, sign * math.pow(distance / radius - 1.0, exponent));

      case BoneType.type2:
        assert(exponent < 0);
        // if (distance >= radius) {
        //   return 0.0;
        // }
        if (distance <= 1e-4) {
          return strength * distance;
        }
        //final n = -2 / math.log(radius + 1.0);
        //print('$radius, ${math.pow(radius + 1.0, n)} $n, ${math.pow(distance + 1.0, n)}');
        return strength * math.min(distance, math.pow(distance + 1.0, exponent));
    }
  }
}

/// スキンモディファイア
@immutable
class SkinModifier extends MeshModifier {
  final List<MapEntry<String, BoneData>> bones;
  final Node referencePosition; // 基準位置のrootノード

  const SkinModifier({
    required this.bones,
    required this.referencePosition,
  });

  @override
  MeshData transform({
    required Mesh mesh,
    required MeshData data,
    required Node root,
  }) {
    // 基準位置のoriginからrootへの変換行列
    final rOriginMatrix = referencePosition.find(path: mesh.origin)!.matrix;
    // 基準位置の各ボーンからrootへの変換行列とその逆
    final rBoneMatrices = bones.map((it) => referencePosition.find(path: it.key)!.matrix).toList();
    final rInvBoneMatrices = rBoneMatrices.map((it) => it.inverted()).toList();
    // originからrootへの変換行列
    final originMatrix = root.find(path: mesh.origin)!.matrix;
    // 各ボーンからrootへの変換行列
    final boneMatrices = bones.map((it) => root.find(path: it.key)!.matrix).toList();

    final data_ = <MeshObject>[];
    for (final object in data) {
      // 各頂点について、
      final vertices = <Vector3>[];
      for (final vertex in object.vertices) {
        // 各ボーンからの相対位置と影響力を集計する。
        final boneValues = <MapEntry<Vector3, double>>[];
        var dominator = 0.0; // 影響力の総和
        // 各ボーンについて...
        final rPos = vertex.transformed(rOriginMatrix);
        for (int i = 0; i < bones.length; ++i) {
          final bone = bones[i].value;
          // 基準位置におけるボーンからの相対位置を...
          final p = rPos.transformed(rInvBoneMatrices[i]);
          final d = p.length;
          if (d <= bone.radius) {
            // rootにおけるボーンからの相対位置に変換して、影響力とともにリストアップ
            final value = bone.valueOf(d);
            boneValues.add(MapEntry(p.transformed(boneMatrices[i]), value));
            dominator += value;
          }
        }
        if (boneValues.isEmpty || dominator.abs() < 1e-4) {
          // ボーンから影響を受けなかった
          vertices.add(vertex.transformed(originMatrix));
        } else {
          // ボーンからの影響力による加重平均
          var p = Vector3.zero;
          for (final value in boneValues) {
            p = p + value.key * value.value;
          }
          vertices.add(p / dominator);
        }
      }
      data_.add(
        object.copyWith(
          vertices: vertices,
          normals: <Vector3>[],
        ).transformed(originMatrix.inverted()),
      );
    }
    return data_;
  }
}

/// 磁石
///
/// [shape]: 成分を1より小さくすると、頂点の距離dが小さくなり、その軸方向に磁力が強く働く。
///   例えばX成分を小さくすると横長の棒磁石みたいな。
@immutable
class MagnetData extends BoneData {
  final Vector3 shape;
  final Matrix4 matrix;
  final bool mirror;

  const MagnetData({
    super.radius = 1.0,
    super.strength = 1.0,
    super.exponent = 2,
    super.type = BoneType.type1,
    this.shape = Vector3.one,
    this.matrix = Matrix4.identity,
    this.mirror = false,
  }) : assert(radius >= 1e-4); //,
  //assert(exponent > 0);
}

/// マグネットモディファイア
@immutable
class MagnetModifier extends MeshModifier {
  // ignore: unused_field
  static final _logger = Logger('MagnetModifier');

  final List<MapEntry<dynamic, MagnetData>> magnets;

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
      Vector3 p;
      if (magnet.key is String) {
        p = (invOriginMatrix * root.find(path: magnet.key)!.matrix).translation;
      } else if (magnet.key is Vector3) {
        p = magnet.key;
      } else {
        throw UnimplementedError();
      }
      magnets_.add(MapEntry(p, magnet.value));
      if (magnet.value.mirror) {
        magnets_.add(MapEntry(p.mirrored(), magnet.value));
      }
    }

    final data_ = <MeshObject>[];
    for (final object in data) {
      // 頂点変形
      final vertices = <Vector3>[];
      // 各頂点について...
      for (final vertex in object.vertices) {
        // 各磁石からの力を集計
        var delta = Vector3.zero;
        for (final magnet in magnets_) {
          final v = magnet.key - vertex.transformed(magnet.value.matrix);
          final d = v.length;
          if (d >= 1e-4 && d <= magnet.value.radius) {
            // 距離による減衰
            delta += v.normalized() * magnet.value.valueOf(d);
          }
        }
        vertices.add(vertex + delta);
      }
      data_.add(
        object.copyWith(
          vertices: vertices,
          normals: <Vector3>[],
        ),
      );
    }
    return data_;
  }
}
