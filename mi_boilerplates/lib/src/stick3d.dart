// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

//
// Parametric modeler
//

// https://api.flutter.dev/flutter/vector_math/vector_math-library.html

import 'package:vector_math/vector_math.dart';

class Node {
  Matrix4? _matrix;
  Matrix4 get matrix => _matrix ?? Matrix4.identity();
  set matrix(Matrix4 value) => _matrix = value;
  Map<String, Node> children;

  Node({
    Matrix4? matrix,
    this.children = const <String, Node>{},
  }) : _matrix = matrix;

  /// [path]に対応する子ノードを検索する。
  Node? find({
    required Iterable<String> path,
  }) {
    if (path.isEmpty) {
      return this;
    }
    final child = children[path.first];
    if (child == null) {
      return null;
    }
    return child.find(path: path.skip(1));
  }

  ///
  Node copy() {
    return Node(
      matrix: _matrix,
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
          _matrix == other._matrix &&
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
      matrix: matrix ?? _matrix,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_matrix': _matrix,
      'children': children,
    };
  }

  factory Node.fromMap(Map<String, dynamic> map) {
    return Node(
      matrix: map['_matrix'] as Matrix4,
      children: map['children'] as Map<String, Node>,
    );
  }

//</editor-fold>
}

class MeshVertex {
  int vertexIndex;
  int normalIndex;
  int textureVertexIndex;

  MeshVertex({
    this.vertexIndex = -1,
    this.normalIndex = -1,
    this.textureVertexIndex = -1,
  });

  //<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeshVertex &&
          runtimeType == other.runtimeType &&
          vertexIndex == other.vertexIndex &&
          normalIndex == other.normalIndex &&
          textureVertexIndex == other.textureVertexIndex);

  @override
  int get hashCode => vertexIndex.hashCode ^ normalIndex.hashCode ^ textureVertexIndex.hashCode;

  @override
  String toString() {
    return 'MeshVertex{'
        ' vertexIndex: $vertexIndex,'
        ' normalIndex: $normalIndex,'
        ' textureVertexIndex: $textureVertexIndex,'
        '}';
  }

  MeshVertex copyWith({
    int? vertexIndex,
    int? normalIndex,
    int? textureVertexIndex,
  }) {
    return MeshVertex(
      vertexIndex: vertexIndex ?? this.vertexIndex,
      normalIndex: normalIndex ?? this.normalIndex,
      textureVertexIndex: textureVertexIndex ?? this.textureVertexIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vertexIndex': vertexIndex,
      'normalIndex': normalIndex,
      'textureVertexIndex': textureVertexIndex,
    };
  }

  factory MeshVertex.fromMap(Map<String, dynamic> map) {
    return MeshVertex(
      vertexIndex: map['vertexIndex'] as int,
      normalIndex: map['normalIndex'] as int,
      textureVertexIndex: map['textureVertexIndex'] as int,
    );
  }

//</editor-fold>
}

typedef MeshFace = List<MeshVertex>;

class MeshData {
  final List<Vector3> vertices;
  final List<MeshFace> faces;

  MeshData({
    this.vertices = const <Vector3>[],
    this.faces = const <MeshFace>[],
  });

//<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeshData &&
          runtimeType == other.runtimeType &&
          vertices == other.vertices &&
          faces == other.faces);

  @override
  int get hashCode => vertices.hashCode ^ faces.hashCode;

  @override
  String toString() {
    return 'Mesh{ vertices: $vertices, faces: $faces,}';
  }

  MeshData copyWith({
    List<Vector3>? vertices,
    List<MeshFace>? faces,
  }) {
    return MeshData(
      vertices: vertices ?? this.vertices,
      faces: faces ?? this.faces,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vertices': vertices,
      'faces': faces,
    };
  }

  factory MeshData.fromMap(Map<String, dynamic> map) {
    return MeshData(
      vertices: map['vertices'] as List<Vector3>,
      faces: map['faces'] as List<MeshFace>,
    );
  }

//</editor-fold>
}

abstract class AbstractMesh {
  MeshData toMeshData();
}

//
// * 右手座標系とする。X+右、Y+上、Z+手前のイメージ
// * 関節の回転軸は原則として：
//   * Xを主要な曲げ軸とする。（肘や指の折れ軸、股の前後振り軸、肩の開き軸、椎骨の前後曲げ軸）
//   * Yを次の曲げ軸とする。（股の左右開閉軸、肩の前後振り軸、椎骨の左右曲げ軸）
//   * Zを捻り軸、肢の伸びる方向とする。
//
