// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:mi_boilerplates/mi_boilerplates.dart' hide Vector3, Matrix4;
import 'package:vector_math/vector_math_64.dart' as vm;

/// vector_mathのVector3の代わり
///
/// vector_mathのVector3はimmutableにできないので

class Vector3 {
  static const unitX = Vector3(1, 0, 0);
  static const unitY = Vector3(0, 1, 0);
  static const unitZ = Vector3(0, 0, 1);
  static const zero = Vector3(0, 0, 0);
  static const one = Vector3(1, 1, 1);

  final double x;
  final double y;
  final double z;

  Vector3 operator -() => Vector3(-x, -y, -z);
  Vector3 operator +(Vector3 other) => Vector3(x + other.x, y + other.y, z + other.z);
  Vector3 operator -(Vector3 other) => Vector3(x - other.x, y - other.y, z - other.z);
  Vector3 operator *(dynamic other) {
    switch (other.runtimeType) {
      case double:
        return (other as double).let((it) => Vector3(x * it, y * it, z * it));
      case Vector3:
        return (other as Vector3).let((it) => Vector3(x * it.x, y * it.y, z * it.z));
    }
    throw UnimplementedError();
  }

  Vector3 normalized() => Vector3.fromVmVector(toVmVector().normalized());

  Vector3.fromVmVector(vm.Vector3 value)
      : x = value.x,
        y = value.y,
        z = value.z;
  vm.Vector3 toVmVector() => vm.Vector3(x, y, z);

  //<editor-fold desc="Data Methods">

  const Vector3(this.x, this.y, this.z);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vector3 &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          z == other.z);

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;

  @override
  String toString() {
    return 'Vector3{' ' x: $x,' ' y: $y,' ' z: $z,' '}';
  }

  Vector3 copyWith({
    double? x,
    double? y,
    double? z,
  }) {
    return Vector3(x ?? this.x, y ?? this.y, z ?? this.z);
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }

  factory Vector3.fromMap(Map<String, dynamic> map) {
    return Vector3(
      map['x'] as double,
      map['y'] as double,
      map['z'] as double,
    );
  }

//</editor-fold>
}

/// vector_mathのMatrix4の代わり
///
/// vector_mathのMatrix4はimmutableにできないので

class Matrix4 {
  static const identity = Matrix4._(<double>[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
  static const zero = Matrix4._(<double>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

  final List<double> elements;

  Matrix4 operator *(Matrix4 other) {
    return Matrix4.fromVmMatrix(toVmMatrix() * other.toVmMatrix());
  }

  Vector3 rotated(Vector3 value) {
    return Vector3.fromVmVector(toVmMatrix().rotated3(value.toVmVector()));
  }

  Vector3 transformed(Vector3 value) {
    return Vector3.fromVmVector(toVmMatrix().transform3(value.toVmVector()));
  }

  Matrix4.fromList(this.elements) : assert(elements.length == 16);

  Matrix4.fromVmMatrix(vm.Matrix4 value) : elements = value.storage;
  vm.Matrix4 toVmMatrix() {
    assert(elements.length == 16);
    return vm.Matrix4(
      elements[0],
      elements[1],
      elements[2],
      elements[3],
      elements[4],
      elements[5],
      elements[6],
      elements[7],
      elements[8],
      elements[9],
      elements[10],
      elements[11],
      elements[12],
      elements[13],
      elements[14],
      elements[15],
    );
  }

  static Matrix4 rotation(Vector3 axis, double angle) {
    // https://w3e.kanazawa-it.ac.jp/math/physics/category/physical_math/linear_algebra/henkan-tex.cgi?target=/math/physics/category/physical_math/linear_algebra/rodrigues_rotation_matrix.html
    final n = axis.normalized();
    final c = math.cos(angle), c1 = 1.0 - c;
    final s = math.sin(angle);
    final elements = <double>[
      n.x * n.x * c1 + c,
      n.x * n.y * c1 - n.z * s,
      n.x * n.z * c1 + n.y * s,
      0,
      n.x * n.y * c1 + n.z * s,
      n.y * n.y * c1 + c,
      n.y * n.z * c1 - n.x * s,
      0,
      n.x * n.z * c1 - n.y * s,
      n.y * n.z * c1 + n.x * s,
      n.z * n.z * c1 + c,
      0,
      0,
      0,
      0,
      1,
    ];
    return Matrix4.fromList(elements);
  }

  static Matrix4 translation(Vector3 translation) {
    return Matrix4.fromVmMatrix(vm.Matrix4.translation(translation.toVmVector()));
  }

  // todo その他のコンストラクタ

  //<editor-fold desc="Data Methods">

  const Matrix4._(this.elements);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Matrix4 && runtimeType == other.runtimeType && elements == other.elements);

  @override
  int get hashCode => elements.hashCode;

  @override
  String toString() {
    return 'Matrix4{' ' elements: $elements,' '}';
  }

  Matrix4 copyWith({
    List<double>? elements,
  }) {
    return Matrix4._(
      elements ?? this.elements,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elements': elements,
    };
  }

  factory Matrix4.fromMap(Map<String, dynamic> map) {
    final elements = map['elements'] as List<double>;
    if (elements.length != 16) {
      throw const FormatException();
    }
    return Matrix4._(elements);
  }

//</editor-fold>
}

/// ノード検索結果

class NodeFind {
  final Node node;
  final Matrix4 matrix;
  final Node? parent;

  const NodeFind({
    required this.node,
    required this.matrix,
    required this.parent,
  });
}

/// ノード
///
/// モデルの制御点（関節）を定義する。
/// [matrix]は親ノードからの相対的な変換を表す。

class Node {
  static List<String> splitPath(String path) => path.split('.');

  final Matrix4 matrix;
  final Map<String, Node> children;

  NodeFind? _find(
    Iterable<String> path,
    Matrix4 matrix,
    Node? parent,
  ) {
    if (path.isEmpty) {
      return NodeFind(node: this, matrix: matrix, parent: parent);
    }
    final child = children[path.first];
    if (child == null) {
      return null;
    }
    return child._find(path.skip(1), this.matrix * matrix, this);
  }

  NodeFind? find(dynamic path) {
    switch (path.runtimeType) {
      case Iterable<String>:
        return _find(path, Matrix4.identity, null);
      case String:
        return _find(splitPath(path), Matrix4.identity, null);
    }
    throw UnimplementedError();
  }

  Node put(String key, Node child) {
    final children_ = {...children};
    children_[key] = child;
    return copyWith(children: children_);
  }

  //<editor-fold desc="Data Methods">

  const Node({
    this.matrix = Matrix4.identity,
    this.children = const <String, Node>{},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Node &&
          runtimeType == other.runtimeType &&
          matrix == other.matrix &&
          children == other.children);

  @override
  int get hashCode => matrix.hashCode ^ children.hashCode;

  @override
  String toString() {
    return 'Node{' ' matrix: $matrix,' ' children: $children,' '}';
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
/// - 省略されたインデックスは-1。

class MeshVertex {
  final int vertexIndex;
  final int textureVertexIndex;
  final int normalIndex;

  const MeshVertex(
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
  final List<Vector3> vertices;
  final List<Vector3> normals;
  final List<Vector3> textureVertices;
  final List<MeshFace> faces;
  final bool smooth;

  const MeshData({
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

void toWavefrontObj(List<MeshData> meshDataList, StringSink sink) {
  int vertexIndex = 1;
  int textureVertexIndex = 1;
  int normalIndex = 1;
  for (final meshData in meshDataList) {
    for (final vertex in meshData.vertices) {
      sink.writeln('v ${vertex.x} ${vertex.y} ${vertex.z}');
    }
    for (final textureVertex in meshData.textureVertices) {
      sink.writeln('vt ${textureVertex.x} ${textureVertex.y} ${textureVertex.z}');
    }
    for (final normal in meshData.normals) {
      sink.writeln('vn ${normal.x} ${normal.y} ${normal.z}');
    }
    for (final face in meshData.faces) {
      assert(face.length >= 3);
      sink.write('f');
      for (final vertex in face) {
        assert(vertex.vertexIndex >= 0 && vertex.vertexIndex < meshData.vertices.length);
        sink.write(' ${vertex.vertexIndex + vertexIndex}');
        if (vertex.normalIndex >= 0) {
          sink.write('/');
          if (vertex.textureVertexIndex >= 0) {
            assert(vertex.textureVertexIndex < meshData.textureVertices.length);
            sink.write('${vertex.textureVertexIndex + textureVertexIndex}');
          }
          sink.write('/');
          assert(vertex.normalIndex < meshData.normals.length);
          sink.write('${vertex.normalIndex + normalIndex}');
        }
      }
      sink.writeln();
    }
    vertexIndex += meshData.vertices.length;
    textureVertexIndex += meshData.textureVertices.length;
    normalIndex += meshData.normals.length;
  }
}

/// メッシュの基底クラス

abstract class Mesh {
  const Mesh();

  MeshData toMeshData(Node rootNode);
}

/// 立方体生成用メッシュデータ
///
/// (-1,-1,-1)-(1,1,1)

const _cubeVertices = <Vector3>[
  Vector3(1, 1, -1),
  Vector3(1, -1, -1),
  Vector3(1, 1, 1),
  Vector3(1, -1, 1),
  Vector3(-1, 1, -1),
  Vector3(-1, -1, -1),
  Vector3(-1, 1, 1),
  Vector3(-1, -1, 1),
];

final _cubeNormals = <Vector3>[
  Vector3.unitY,
  Vector3.unitZ,
  -Vector3.unitX,
  -Vector3.unitY,
  Vector3.unitX,
  -Vector3.unitZ,
];

const _cubeFaces = <MeshFace>[
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

MeshData _toCubeMeshData({
  required Matrix4 matrix,
  Vector3 scale = Vector3.one,
}) {
  return MeshData(
    vertices: _cubeVertices
        .map(
          (it) => Vector3(
            it.x * scale.x * 0.5,
            it.y * scale.y * 0.5,
            it.z * scale.z * 0.5,
          ),
        )
        .toList(),
    normals: _cubeNormals.map((it) => matrix.rotated(it)).toList(),
    faces: _cubeFaces,
    smooth: false,
  );
}

///
///

List<MeshData> toMeshData({
  required Node rootNode,
  required Iterable<Mesh> meshes,
}) {
  final result = <MeshData>[];
  for (final mesh in meshes) {
    result.add(mesh.toMeshData(rootNode));
  }
  return result;
}

/// 直方体
///
/// 指定のノードを中心に直方体を生成する。

class CubeMesh extends Mesh {
  final String center;
  final Vector3 scale;

  const CubeMesh({
    required this.center,
    this.scale = Vector3.one,
  });

  @override
  MeshData toMeshData(Node rootNode) {
    final find = rootNode.find(center);
    return _toCubeMeshData(matrix: find!.matrix, scale: scale);
  }

//<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CubeMesh &&
          runtimeType == other.runtimeType &&
          center == other.center &&
          scale == other.scale);

  @override
  int get hashCode => center.hashCode ^ scale.hashCode;

  @override
  String toString() {
    return 'CubeMesh{' ' path: $center,' ' scale: $scale,' '}';
  }

  CubeMesh copyWith({
    String? path,
    Vector3? scale,
  }) {
    return CubeMesh(
      center: path ?? this.center,
      scale: scale ?? this.scale,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'path': center,
      'scale': scale,
    };
  }

  factory CubeMesh.fromMap(Map<String, dynamic> map) {
    return CubeMesh(
      center: map['path'] as String,
      scale: map['scale'] as Vector3,
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
