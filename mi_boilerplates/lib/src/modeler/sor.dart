// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

// スクリプト的モデラ、回転体メッシュデータ生成

/// 回転体(Surface of Revolution)メッシュデータビルダ
class SorBuilder {
  static final logger = Logger('SorBuilder');

  final List<Vector3> vertices;
  final Vector3 axis;
  final int division;
  final bool smooth;
  final bool reverse;

  const SorBuilder({
    required this.vertices,
    this.axis = Vector3.unitY,
    this.division = 12,
    this.smooth = true,
    this.reverse = false,
  });

  /// メッシュデータ生成
  MeshData build() {
    assert(division >= 3);
    assert(vertices.length >= 2);

    // 頂点生成
    final n = vertices.length;
    final vertices_ = <Vector3>[];
    for (int i = 0; i < division; ++i) {
      final matrix = Matrix4.fromAxisAngleRotation(axis, i * 2.0 * math.pi / division);
      for (final vertex in vertices) {
        vertices_.add(vertex.transformed(matrix));
      }
    }

    // 面生成
    final faces = <MeshFace>[];

    void addFaces(final int j0, final int j1) {
      for (int i = 0; i < n - 1; ++i) {
        faces.add(<MeshVertex>[
          MeshVertex(j0 + i, -1, -1),
          MeshVertex(j1 + i, -1, -1),
          MeshVertex(j1 + i + 1, -1, -1),
          MeshVertex(j0 + i + 1, -1, -1),
        ]);
      }
    }

    int i = 0;
    for (; i < division - 1; ++i) {
      addFaces(i * n, (i + 1) * n);
    }
    addFaces(i * n, 0);

    final data = MeshData(vertices: vertices_, faces: faces, smooth: smooth);
    return reverse ? data.reversed() : data;
  }
}

/// 回転体
// todo

//
abstract class EndShape {
  const EndShape();
}

class OpenEnd extends EndShape {
  const OpenEnd();
}

class ConeEnd extends EndShape {
  final double height;
  final int division;
  const ConeEnd({this.height = 0.0, this.division = 1});
}

class DomeEnd extends EndShape {
  final double height;
  final int division;
  const DomeEnd({this.height = double.infinity, this.division = 4});
}

/// 円筒
///
/// [origin]を軸線の始点、[target]を終点として円筒を生成する。
class Tube extends Cube {
  final double beginRadius;
  final double endRadius;
  final double height;
  final int circleDivision;
  final int heightDivision;
  final EndShape beginShape;
  final EndShape endShape;
  final bool smooth;
  final bool reverse;

  const Tube({
    required super.origin,
    super.target = '',
    super.scale = Vector3.one,
    super.fill = true,
    this.beginRadius = 0.5,
    this.endRadius = 0.5,
    this.height = 1.0,
    this.circleDivision = 12,
    this.heightDivision = 1,
    this.beginShape = const OpenEnd(),
    this.endShape = const OpenEnd(),
    this.smooth = true,
    this.reverse = false,
  });

  @override
  List<MeshData> toMeshData({required final Node root}) {
    assert(circleDivision >= 3);
    assert(heightDivision >= 1);

    // 母線頂点生成
    final vertices = <Vector3>[];
    //　始端
    switch (beginShape.runtimeType) {
      case ConeEnd:
        final coneEnd = beginShape as ConeEnd;
        for (int i = 0; i < coneEnd.division; ++i) {
          final t = i.toDouble() / coneEnd.division;
          vertices.add(Vector3(t * beginRadius, (1.0 - t) * -coneEnd.height, 0.0));
        }
        break;
      case DomeEnd:
        final domeEnd = beginShape as DomeEnd;
        final domeHeight = domeEnd.height == double.infinity ? beginRadius : domeEnd.height;
        for (int i = 0; i < domeEnd.division; ++i) {
          final t = i.toDouble() / domeEnd.division;
          final a = (1.0 - t) * math.pi * 0.5;
          vertices.add(Vector3(math.cos(a) * beginRadius, math.sin(a) * -domeHeight, 0.0));
        }
        break;
      default:
        break;
    }
    // 胴
    for (int i = 0; i < heightDivision; ++i) {
      final t = i.toDouble() / heightDivision;
      vertices.add(Vector3((endRadius - beginRadius) * t + beginRadius, t * height, 0.0));
    }
    vertices.add(Vector3(endRadius, height, 0.0));
    // 終端
    switch (endShape.runtimeType) {
      case ConeEnd:
        final coneEnd = endShape as ConeEnd;
        for (int i = 1; i <= coneEnd.division; ++i) {
          final t = i.toDouble() / coneEnd.division;
          vertices.add(Vector3((1.0 - t) * endRadius, t * coneEnd.height + height, 0.0));
        }
        break;
      case DomeEnd:
        final domeEnd = endShape as DomeEnd;
        final domeHeight = domeEnd.height == double.infinity ? endRadius : domeEnd.height;
        for (int i = 1; i <= domeEnd.division; ++i) {
          final t = i.toDouble() / domeEnd.division;
          final a = t * math.pi * 0.5;
          vertices.add(Vector3(math.cos(a) * endRadius, math.sin(a) * domeHeight + height, 0.0));
        }
        break;
      default:
        break;
    }
    // メッシュデータ生成
    final data = SorBuilder(
      vertices: vertices,
      division: circleDivision,
      smooth: smooth,
      reverse: reverse,
    ).build();
    return makeMeshData(root: root, data: data);
  }
}
