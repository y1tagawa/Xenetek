// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

//
// Parametric modeler
//

// https://api.flutter.dev/flutter/vector_math/vector_math-library.html

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart';

final x_ = Vector3(1, 0, 0);
final y_ = Vector3(0, 1, 0);
final z_ = Vector3(0, 0, 1);

/// ノード
///
/// モデルの制御点（関節）を定義する。
/// [matrix]は親ノードからの相対的な変換を表す。

class Node {
  Matrix4? _matrix;
  Matrix4 get matrix => _matrix ?? Matrix4.identity();
  set matrix(Matrix4 value) => _matrix = value;
  Map<String, Node> children;

  Node({
    Matrix4? matrix,
    this.children = const <String, Node>{},
  }) : _matrix = matrix;

  MapEntry<Node, Matrix4>? _find(
    Iterable<String> path,
    Matrix4 matrix,
  ) {
    if (path.isEmpty) {
      return MapEntry(this, matrix);
    }
    final child = children[path.first];
    if (child == null) {
      return null;
    }
    return child._find(path.skip(1), this.matrix * matrix);
  }

  MapEntry<Node, Matrix4>? find(
    Iterable<String> path,
  ) {
    return _find(path, Matrix4.identity());
  }

  Node copy() {
    return Node(
      matrix: matrix,
      children: <String, Node>{
        for (var item in children.entries) item.key: item.value.copy(),
      },
    );
  }

//<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Node &&
          runtimeType == other.runtimeType &&
          matrix == other.matrix &&
          children == other.children);

  @override
  int get hashCode => _matrix.hashCode ^ children.hashCode;

  @override
  String toString() {
    return 'Node{ _matrix: $_matrix, ' 'children: $children,' '}';
  }

  Node copyWith({
    Matrix4? matrix,
    Map<String, Node>? children,
  }) {
    return Node(
      matrix: matrix ?? this.matrix,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matrix': matrix,
      'children': children,
    };
  }

  factory Node.fromMap(Map<String, dynamic> map) {
    return Node(
      matrix: map['matrix'] as Matrix4,
      children: map['children'] as Map<String, Node>,
    );
  }

//</editor-fold>
}

/// メッシュ頂点データ
///
/// 大体Wavefront .objの頂点データ。ただし、
/// - インデックスは0から。
/// - 省略時は-1。

class MeshVertex {
  int vertexIndex;
  int textureVertexIndex;
  int normalIndex;

  MeshVertex(
    this.vertexIndex,
    int? textureVertexIndex,
    int? normalIndex,
  )   : textureVertexIndex = textureVertexIndex ?? -1,
        normalIndex = normalIndex ?? -1;

  //<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeshVertex &&
          runtimeType == other.runtimeType &&
          vertexIndex == other.vertexIndex &&
          textureVertexIndex == other.textureVertexIndex &&
          normalIndex == other.normalIndex);

  @override
  int get hashCode => vertexIndex.hashCode ^ textureVertexIndex.hashCode ^ normalIndex.hashCode;

  @override
  String toString() {
    return 'MeshVertex{'
        ' vertexIndex: $vertexIndex,'
        ' textureVertexIndex: $textureVertexIndex,'
        ' normalIndex: $normalIndex,'
        '}';
  }

  MeshVertex copyWith({
    int? vertexIndex,
    int? textureVertexIndex,
    int? normalIndex,
  }) {
    return MeshVertex(
      vertexIndex ?? this.vertexIndex,
      textureVertexIndex ?? this.textureVertexIndex,
      normalIndex ?? this.normalIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vertexIndex': vertexIndex,
      'textureVertexIndex': textureVertexIndex,
      'normalIndex': normalIndex,
    };
  }

  factory MeshVertex.fromMap(Map<String, dynamic> map) {
    return MeshVertex(
      map['vertexIndex'] as int,
      map['textureVertexIndex'] as int,
      map['normalIndex'] as int,
    );
  }

//</editor-fold>
}

typedef MeshFace = List<MeshVertex>;

/// メッシュデータ
///
/// 大体Wavefront .objみたいなやつ。

class MeshData {
  List<Vector3> vertices;
  List<Vector3> normals;
  List<Vector3> textureVertices;
  List<MeshFace> faces;
  bool smooth;

  MeshData({
    this.vertices = const <Vector3>[],
    this.normals = const <Vector3>[],
    this.textureVertices = const <Vector3>[],
    this.faces = const <MeshFace>[],
    this.smooth = false,
  });

//<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeshData &&
          runtimeType == other.runtimeType &&
          normals == other.normals &&
          textureVertices == other.textureVertices &&
          vertices == other.vertices &&
          faces == other.faces &&
          smooth == other.smooth);

  @override
  int get hashCode =>
      vertices.hashCode ^
      normals.hashCode ^
      textureVertices.hashCode ^
      faces.hashCode ^
      smooth.hashCode;

  @override
  String toString() {
    return 'Mesh{ vertices: $vertices, '
        'normals: $normals, '
        'textureVertices: $textureVertices, '
        'faces: $faces, '
        'smooth: $smooth}';
  }

  MeshData copyWith({
    List<Vector3>? vertices,
    List<Vector3>? normals,
    List<Vector3>? textureVertices,
    List<MeshFace>? faces,
    bool? smooth,
  }) {
    return MeshData(
      vertices: vertices ?? this.vertices,
      normals: normals ?? this.normals,
      textureVertices: textureVertices ?? this.textureVertices,
      faces: faces ?? this.faces,
      smooth: smooth ?? this.smooth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vertices': vertices,
      'normals': normals,
      'textureVertices': textureVertices,
      'faces': faces,
      'smooth': smooth,
    };
  }

  factory MeshData.fromMap(Map<String, dynamic> map) {
    return MeshData(
      vertices: map['vertices'] as List<Vector3>,
      normals: map['normals'] as List<Vector3>,
      textureVertices: map['textureVertices'] as List<Vector3>,
      faces: map['faces'] as List<MeshFace>,
      smooth: map['smooth'] as bool,
    );
  }

//</editor-fold>
}

// Print to Wavefront .obj
String toWavefrontObj(List<MeshData> meshList) {
  return ''; //TODO
}

/// メッシュの基底クラス

abstract class AbstractMesh {
  @protected
  List<String> toPath(String path) => path.split('.');

  MeshData toMeshData(Node rootNode);
}

/// 立方体生成用メッシュデータ

final _cubeVertices = <Vector3>[
  Vector3(1, 1, -1),
  Vector3(1, -1, -1),
  Vector3(1, 1, 1),
  Vector3(1, -1, 1),
  Vector3(-1, 1, -1),
  Vector3(-1, -1, -1),
  Vector3(-1, 1, 1),
  Vector3(-1, -1, 1),
];

final _cubeNormals = <Vector3>[y_, z_, -x_, -y_, x_, -z_];

final _cubeFaces = <MeshFace>[
  <MeshVertex>[
    MeshVertex(0, -1, 0),
    MeshVertex(4, -1, 0),
    MeshVertex(6, -1, 0),
    MeshVertex(2, -1, 0),
  ],
  <MeshVertex>[
    MeshVertex(3, -1, 1),
    MeshVertex(2, -1, 1),
    MeshVertex(6, -1, 1),
    MeshVertex(7, -1, 1),
  ],
  <MeshVertex>[
    MeshVertex(7, -1, 2),
    MeshVertex(6, -1, 2),
    MeshVertex(4, -1, 2),
    MeshVertex(5, -1, 2),
  ],
  <MeshVertex>[
    MeshVertex(5, -1, 3),
    MeshVertex(1, -1, 3),
    MeshVertex(3, -1, 3),
    MeshVertex(7, -1, 3),
  ],
  <MeshVertex>[
    MeshVertex(1, -1, 4),
    MeshVertex(0, -1, 4),
    MeshVertex(2, -1, 4),
    MeshVertex(3, -1, 4),
  ],
  <MeshVertex>[
    MeshVertex(5, -1, 5),
    MeshVertex(4, -1, 5),
    MeshVertex(0, -1, 5),
    MeshVertex(1, -1, 5),
  ],
];

MeshData _toCubeMeshData(Matrix4 matrix) {
  return MeshData(
    vertices: _cubeVertices.map((it) => matrix.transform3(it * 0.5)).toList(),
    normals: _cubeNormals.map((it) => matrix.rotated3(it)).toList(),
    faces: _cubeFaces,
    smooth: false,
  );
}

/// 立方体
///
/// 指定のノード位置に立方体を生成する。

class CubeMesh extends AbstractMesh {
  String path;

  CubeMesh({
    required this.path,
  });

  @override
  MeshData toMeshData(Node rootNode) {
    final matrix = rootNode.find(toPath(path));
    return _toCubeMeshData(matrix!.value);
  }

//<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CubeMesh && runtimeType == other.runtimeType && path == other.path);

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() {
    return 'CubeMesh{' ' path: $path,' '}';
  }

  CubeMesh copyWith({
    String? path,
  }) {
    return CubeMesh(
      path: path ?? this.path,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'path': path,
    };
  }

  factory CubeMesh.fromMap(Map<String, dynamic> map) {
    return CubeMesh(
      path: map['path'] as String,
    );
  }

//</editor-fold>
}

//
// * 右手座標系とする。X+右、Y+上、Z+手前のイメージ
// * 関節の回転軸は原則として：
//   * Xを主要な曲げ軸とする。（肘や指の折れ軸、股の前後振り軸、肩の開き軸、椎骨の前後曲げ軸）
//   * Yを次の曲げ軸とする。（股の左右開閉軸、肩の前後振り軸、椎骨の左右曲げ軸）
//   * Zを捻り軸、肢の伸びる方向とする。
//
