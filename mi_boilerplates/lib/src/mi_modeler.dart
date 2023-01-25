// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:logging/logging.dart';
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

  double get length => math.sqrt(x * x + y * y + z * z);

  Vector3 operator -() => Vector3(-x, -y, -z);
  Vector3 operator +(Vector3 other) => Vector3(x + other.x, y + other.y, z + other.z);
  Vector3 operator -(Vector3 other) => Vector3(x - other.x, y - other.y, z - other.z);

  /// 要素ごとのスカラ積
  Vector3 operator *(dynamic other) {
    switch (other.runtimeType) {
      case double:
        return (other as double).let((it) => Vector3(x * it, y * it, z * it));
      case int:
        return (other as int).toDouble().let((it) => Vector3(x * it, y * it, z * it));
      case Vector3:
        return (other as Vector3).let((it) => Vector3(x * it.x, y * it.y, z * it.z));
      default:
        throw UnimplementedError();
    }
  }

  Vector3 normalized() {
    return Vector3.fromVmVector(toVmVector().normalized());
  }

  Vector3 transformed(Matrix4 matrix) {
    return Vector3.fromVmVector(matrix.toVmMatrix().transform3(toVmVector()));
  }

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

extension Vector3ListHelper on List<Vector3> {
  List<Vector3> transformed(Matrix4 matrix) {
    return map((value) => value.transformed(matrix)).toList();
  }
}

/// vector_mathのMatrix4の代わり
///
/// vector_mathのMatrix4はimmutableにできないので

class Matrix4 {
  static const identity = Matrix4._(<double>[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
  static const zero = Matrix4._(<double>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

  final List<double> elements;

  /// 併進成分
  Vector3 get position {
    return Vector3(elements[3], elements[7], elements[11]);
  }

  /// 回転成分
  Matrix4 get rotation {
    return Matrix4.fromList(<double>[
      elements[0], elements[1], elements[2], 0, //
      elements[4], elements[5], elements[6], 0, //
      elements[8], elements[9], elements[10], 0, //
      0, 0, 0, 1
    ]);
  }

  /// 行列積
  Matrix4 operator *(Matrix4 other) {
    return Matrix4.fromVmMatrix(toVmMatrix() * other.toVmMatrix());
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

  static Matrix4 fromRotation(Vector3 axis, double angle) {
    // https://w3e.kanazawa-it.ac.jp/math/physics/category/physical_math/linear_algebra/henkan-tex.cgi?target=/math/physics/category/physical_math/linear_algebra/rodrigues_rotation_matrix.html
    final n = axis.normalized();
    final c = math.cos(angle), c1 = 1.0 - c;
    final s = math.sin(angle);
    final elements = <double>[
      n.x * n.x * c1 + c,
      n.x * n.y * c1 - n.z * s,
      n.x * n.z * c1 + n.y * s,
      0, //
      n.x * n.y * c1 + n.z * s,
      n.y * n.y * c1 + c,
      n.y * n.z * c1 - n.x * s,
      0, //
      n.x * n.z * c1 - n.y * s,
      n.y * n.z * c1 + n.x * s,
      n.z * n.z * c1 + c,
      0, //
      0, 0, 0, 1
    ];
    return Matrix4.fromList(elements);
  }

  static Matrix4 fromPosition(Vector3 position) {
    return Matrix4.fromVmMatrix(vm.Matrix4.translation(position.toVmVector()));
  }

  static Matrix4 fromScale(dynamic scale) {
    final elements_ = identity.elements.toList();
    switch (scale.runtimeType) {
      case double:
      case int:
        elements_[0] *= scale;
        elements_[5] *= scale;
        elements_[10] *= scale;
        return Matrix4._(elements_);
      case Vector3:
        elements_[0] *= scale.x;
        elements_[5] *= scale.y;
        elements_[10] *= scale.z;
        return Matrix4._(elements_);
      default:
        throw UnimplementedError();
    }
  }

  // todo その他のコンストラクタ（LookAtとか）

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
  static final _logger = Logger((Node).toString());

  static List<String> splitPath(String path) => path.split('.');

  final Matrix4 matrix;
  final Map<String, Node> children;

  NodeFind? _find(
    Iterable<String> path,
    Matrix4 matrix,
    Node? parent,
  ) {
    if (path.isEmpty) {
      return NodeFind(node: this, matrix: this.matrix * matrix, parent: parent);
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
      default:
        throw UnimplementedError();
    }
  }

  Node put(String key, Node child) {
    final children_ = {...children};
    children_[key] = child;
    return copyWith(children: children_);
  }

  Node putDescendants(Iterable<MapEntry<String, Matrix4>> descendants) {
    if (descendants.isEmpty) {
      return this;
    }
    return put(
      descendants.first.key,
      Node(matrix: descendants.first.value).putDescendants(descendants.skip(1)),
    );
  }

  Vector3? _getPosition(Iterable<String> path) {
    final find_ = find(path);
    return find_?.matrix.position;
  }

  Vector3? getPosition(dynamic path) {
    switch (path.runtimeType) {
      case Iterable<String>:
        return _getPosition(path);
      case String:
        return _getPosition(splitPath(path));
      default:
        throw UnimplementedError();
    }
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

/// メッシュ面データ

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

  MeshData transformed(Matrix4 matrix) {
    return copyWith(
      vertices: vertices.transformed(matrix),
      normals: normals.transformed(matrix.rotation),
    );
  }

  /// XZ平面上の円（近似多角形）頂点リスト生成
  static List<Vector3> xzCircle({required double radius, required int division}) {
    final vertices = <Vector3>[];
    for (int i = 0; i < division; ++i) {
      final t = i * math.pi * 2.0 / division;
      vertices.add(Vector3(math.cos(t), 0, math.sin(t)));
    }
    return vertices;
  }

  /// 二つの頂点インデックスリストを閉曲線とみなし、それらを繋いだ面リストを生成する。
  /// ただしテクスチャ頂点、法線は定義しない。
  MeshData addTube(int index0, int index1, int length) {
    assert(index0 >= 0 && index0 + length <= vertices.length);
    assert(index1 >= 0 && index1 + length <= vertices.length);
    final faces = <MeshFace>[];
    for (int i = 0; i < length - 1; ++i) {
      faces.add(<MeshVertex>[
        MeshVertex(index0 + i, -1, -1),
        MeshVertex(index1 + i, -1, -1),
        MeshVertex(index1 + i + 1, -1, -1),
        MeshVertex(index0 + i + 1, -1, -1),
      ]);
    }
    faces.add(<MeshVertex>[
      MeshVertex(index0 + length - 1, -1, -1),
      MeshVertex(index1 + length - 1, -1, -1),
      MeshVertex(index1, -1, -1),
      MeshVertex(index0, -1, -1),
    ]);
    return addFaces(faces);
  }

  /// 頂点リスト追加
  MeshData addVertices(List<Vector3> vertices) {
    return copyWith(vertices: <Vector3>[...this.vertices, ...vertices]);
  }

  /// 面リスト追加
  MeshData addFaces(List<MeshFace> faces) {
    return copyWith(faces: <MeshFace>[...this.faces, ...faces]);
  }

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

/// 多面体の基底クラス

abstract class Shape {
  const Shape();

  MeshData toMeshData(Node root);
}

/// MeshData集積

List<MeshData> toMeshData({
  required Node root,
  required Iterable<Shape> shapes,
}) {
  final result = <MeshData>[];
  for (final shape in shapes) {
    result.add(shape.toMeshData(root));
  }
  return result;
}

/// Wavefront .obj出力

void toWavefrontObj(
  List<MeshData> meshDataList,
  StringSink sink,
) {
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
    sink.writeln('s ${meshData.smooth ? 1 : 0}');
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

/// 立方体メッシュデータ
///
/// (-0.5,0,-0.5)-(0.5,1,0.5)

const _cubeVertices = <Vector3>[
  Vector3(0.5, 1, -0.5),
  Vector3(0.5, 0, -0.5),
  Vector3(0.5, 1, 0.5),
  Vector3(0.5, 0, 0.5),
  Vector3(-0.5, 1, -0.5),
  Vector3(-0.5, 0, -0.5),
  Vector3(-0.5, 1, 0.5),
  Vector3(-0.5, 0, 0.5),
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
final _cubeMeshData = MeshData(
  vertices: _cubeVertices,
  normals: _cubeNormals,
  faces: _cubeFaces,
);

/// 直方体
///
/// [origin]を上面中心として直方体を生成する。

class Cube extends Shape {
  final String origin;
  final dynamic scale;

  const Cube({
    required this.origin,
    this.scale = Vector3.one,
  });

  @override
  MeshData toMeshData(Node root) {
    final find = root.find(origin)!;
    return _cubeMeshData.transformed(find.matrix * Matrix4.fromScale(Vector3.one * scale));
  }

//<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cube &&
          runtimeType == other.runtimeType &&
          origin == other.origin &&
          scale == other.scale);

  @override
  int get hashCode => origin.hashCode ^ scale.hashCode;

  @override
  String toString() {
    return 'CubeMesh{' ' path: $origin,' ' scale: $scale,' '}';
  }

  Cube copyWith({
    String? origin,
    Vector3? scale,
  }) {
    return Cube(
      origin: origin ?? this.origin,
      scale: scale ?? this.scale,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'origin': origin,
      'scale': scale,
    };
  }

  factory Cube.fromMap(Map<String, dynamic> map) {
    return Cube(
      origin: map['origin'] as String,
      scale: map['scale'] as Vector3,
    );
  }

//</editor-fold>
}

/// 積み上げ式円筒メッシュデータ生成
///
/// (-0.5,0,-0.5)-(0.5,1,0.5)
/// TODO: 底面形状ドーム、平面、その他。ドームのためにあとでScaleはできない。

MeshData _tubeMeshData({
  required double radius,
  required double length,
  required int baseDivision,
  required int radiusDivision,
  required int lengthDivision,
}) {
  final logger = Logger('_tubeMeshData');

  var data = const MeshData();

  // 底面
  final circle = MeshData.xzCircle(radius: radius, division: baseDivision);
  var matrix0 = Matrix4.identity;
  var index0 = data.vertices.length;
  data = data.addVertices(circle.transformed(matrix0));
  // 中間
  for (int i = 1; i <= lengthDivision; ++i) {
    final index1 = data.vertices.length;
    final matrix1 = Matrix4.fromPosition(Vector3.unitY * (i * length / lengthDivision));
    data = data.addVertices(circle.transformed(matrix1)).addTube(index0, index1, circle.length);
    index0 = index1;
    matrix0 = matrix1;
  }
  return data;
}

/// 円筒
///
/// [origin]を上面中心として円筒を生成する。

class Tube extends Shape {
  final String origin;
  final double radius;
  final double length;
  final int baseDivision;
  final int radiusDivision;
  final int lengthDivision;

  const Tube({
    required this.origin,
    this.radius = 0.5,
    this.length = 1.0,
    this.baseDivision = 8,
    this.radiusDivision = 1,
    this.lengthDivision = 1,
  })  : assert(baseDivision >= 3),
        assert(radiusDivision >= 1),
        assert(lengthDivision >= 1);

  @override
  MeshData toMeshData(Node root) {
    final find = root.find(origin)!;
    return _tubeMeshData(
      radius: radius,
      length: length,
      baseDivision: baseDivision,
      radiusDivision: radiusDivision,
      lengthDivision: lengthDivision,
    ).transformed(find.matrix);
  }

//<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tube &&
          runtimeType == other.runtimeType &&
          origin == other.origin &&
          radius == other.radius &&
          length == other.length &&
          baseDivision == other.baseDivision &&
          radiusDivision == other.radiusDivision &&
          lengthDivision == other.lengthDivision);

  @override
  int get hashCode =>
      origin.hashCode ^
      radius.hashCode ^
      length.hashCode ^
      baseDivision.hashCode ^
      radiusDivision.hashCode ^
      lengthDivision.hashCode;

  @override
  String toString() {
    return 'Tube{'
        ' origin: $origin,'
        ' radius: $radius,'
        ' length: $length,'
        ' baseDivision: $baseDivision,'
        ' radiusDivision: $radiusDivision,'
        ' lengthDivision: $lengthDivision,'
        '}';
  }

  Tube copyWith({
    String? origin,
    double? radius,
    double? length,
    int? baseDivision,
    int? radiusDivision,
    int? lengthDivision,
  }) {
    return Tube(
      origin: origin ?? this.origin,
      radius: radius ?? this.radius,
      length: length ?? this.length,
      baseDivision: baseDivision ?? this.baseDivision,
      radiusDivision: radiusDivision ?? this.radiusDivision,
      lengthDivision: lengthDivision ?? this.lengthDivision,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'origin': origin,
      'radius': radius,
      'length': length,
      'baseDivision': baseDivision,
      'radiusDivision': radiusDivision,
      'lengthDivision': lengthDivision,
    };
  }

  factory Tube.fromMap(Map<String, dynamic> map) {
    return Tube(
      origin: map['origin'] as String,
      radius: map['radius'] as double,
      length: map['length'] as double,
      baseDivision: map['baseDivision'] as int,
      radiusDivision: map['radiusDivision'] as int,
      lengthDivision: map['lengthDivision'] as int,
    );
  }

//</editor-fold>
}
