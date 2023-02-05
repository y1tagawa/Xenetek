// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

// スクリプト的モデラ、回転体(Surface of Revolution)メッシュデータ生成

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

    void addFaces(int j0, int j1) {
      for (int i = 0; i < n - 1; ++i) {
        faces.add(<MeshVertex>[
          MeshVertex(j0, -1, -1),
          MeshVertex(j1, -1, -1),
          MeshVertex(j1 + 1, -1, -1),
          MeshVertex(j0 + 1, -1, -1),
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

class Tube extends Cube {
  final double beginRadius;
  final double endRadius;
  final double height;
  final int circumDivision;
  final int heightDivision;
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
    this.circumDivision = 12,
    this.heightDivision = 1,
    this.smooth = true,
    this.reverse = false,
  });

  @override
  List<MeshData> toMeshData({required Node root}) {
    assert(circumDivision >= 3);
    assert(heightDivision >= 1);
    final vertices = <Vector3>[
      for (int i = 0; i < heightDivision; ++i)
        run(() {
          final t = i.toDouble() / heightDivision;
          return Vector3((endRadius - beginRadius) * t + beginRadius, t * height, 0.0);
        }),
      Vector3(endRadius, height, 0.0),
    ];

    final data = SorBuilder(
      vertices: vertices,
      division: circumDivision,
      smooth: smooth,
      reverse: reverse,
    ).build();
    return makeMeshData(root: root, data: data);
  }
}
