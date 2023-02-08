// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'basic.dart';

// スクリプト的モデラ、メッシュデータ生成

/// 図形の基底クラス
@immutable
abstract class Shape {
  const Shape();

  /// メッシュデータ生成
  List<MeshData> toMeshData({required final Node root});
}

/// 始端終端を持つ図形の基底クラス
@immutable
abstract class _Beam extends Shape {
  // ignore: unused_field
  static final _logger = Logger('_Beam');

  final String origin;
  final String target;
  final bool fill;

  const _Beam({
    required this.origin,
    this.target = '',
    this.fill = true,
  });

  MeshData get data;

  /// メッシュデータを[origin]から[target]まで延長
  ///
  /// 基底では単にY軸に沿って拡縮するだけなので、必要に応じてカスタマイズする。
  @protected
  MeshData _fillMeshData({
    required final MeshData data,
    required final double length,
  }) =>
      data.transformed(Matrix4.fromScale(Vector3(1, length, 1)));

  /// [origin]の原点位置に置かれた[data]を[target]に向け回転、延長し、
  /// [root]空間に頂点・法線変換したメッシュデータを返す。
  @override
  List<MeshData> toMeshData({required final Node root}) {
    // origin空間への変換マトリクス
    final origin_ = root.find(path: origin)!.matrix;
    if (target.isEmpty) {
      return <MeshData>[data.transformed(origin_)];
    }
    // targetの変換行列を、origin空間にマップする。
    final target_ = origin_.inverted() * root.find(path: target)!.matrix;
    // 軸線終点をtargetに向ける。
    final rotation = Matrix4.fromForwardTargetRotation(
      forward: Vector3.unitY,
      target: target_.translation,
    );
    // fillの場合、モデルをorigin原点からtarget原点までに延長し...
    final data_ = fill ? _fillMeshData(data: data, length: target_.translation.length) : data;
    // ...root空間に変換する。
    return <MeshData>[data_.transformed(origin_ * rotation)];
  }
}

// 立方体メッシュデータ
//
// (-0.5,0,-0.5)-(0.5,1,0.5)
//<editor-fold>

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

const _cubeNormals = <Vector3>[
  Vector3(0, 1, 0),
  Vector3(0, 0, 1),
  Vector3(-1, 0, 0),
  Vector3(0, -1, 0),
  Vector3(1, 0, 0),
  Vector3(0, 0, -1),
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

const _cubeMeshData = MeshData(
  vertices: _cubeVertices,
  normals: _cubeNormals,
  faces: _cubeFaces,
);

//</editor-fold>

/// 直方体
///
/// [origin]を底面中心、[target]を上面として直方体を配置する。
@immutable
class Cube extends _Beam {
  // ignore: unused_field
  static final _logger = Logger('Cube');

  final Vector3 scale;

  const Cube({
    required super.origin,
    super.target = '',
    this.scale = Vector3.one,
    super.fill = true,
  });

  @override
  MeshData get data => _cubeMeshData.transformed(Matrix4.fromScale(scale));

//<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cube &&
          runtimeType == other.runtimeType &&
          origin == other.origin &&
          target == other.target &&
          scale == other.scale &&
          fill == other.fill);

  @override
  int get hashCode => origin.hashCode ^ target.hashCode ^ scale.hashCode ^ fill.hashCode;

  @override
  String toString() {
    return 'Cube{ origin: $origin, target: $target, scale: $scale, fill: $fill}';
  }

  Cube copyWith({
    String? origin,
    String? target,
    Vector3? scale,
    bool? fill,
  }) {
    return Cube(
      origin: origin ?? this.origin,
      target: target ?? this.target,
      scale: scale ?? this.scale,
      fill: fill ?? this.fill,
    );
  }

//</editor-fold>
}

// 正八面体メッシュデータ
//
// (-0.5,0,-0.5)-(0.5,1,0.5)
//<editor-fold>

const _octahedronVertices = <Vector3>[
  Vector3(0.5, 0.5, 0),
  Vector3(-0.5, 0.5, 0),
  Vector3(0, 1, 0),
  Vector3(0, 0, 0),
  Vector3(0, 0.5, 0.5),
  Vector3(0, 0.5, -0.5),
];

const _octahedronFaces = <MeshFace>[
  <MeshVertex>[
    MeshVertex(4, -1, -1),
    MeshVertex(0, -1, -1),
    MeshVertex(2, -1, -1),
  ],
  <MeshVertex>[
    MeshVertex(4, -1, -1),
    MeshVertex(2, -1, -1),
    MeshVertex(1, -1, -1),
  ],
  <MeshVertex>[
    MeshVertex(4, -1, -1),
    MeshVertex(1, -1, -1),
    MeshVertex(3, -1, -1),
  ],
  <MeshVertex>[
    MeshVertex(4, -1, -1),
    MeshVertex(3, -1, -1),
    MeshVertex(0, -1, -1),
  ],
  <MeshVertex>[
    MeshVertex(5, -1, -1),
    MeshVertex(2, -1, -1),
    MeshVertex(0, -1, -1),
  ],
  <MeshVertex>[
    MeshVertex(5, -1, -1),
    MeshVertex(1, -1, -1),
    MeshVertex(2, -1, -1),
  ],
  <MeshVertex>[
    MeshVertex(5, -1, -1),
    MeshVertex(3, -1, -1),
    MeshVertex(1, -1, -1),
  ],
  <MeshVertex>[
    MeshVertex(5, -1, -1),
    MeshVertex(0, -1, -1),
    MeshVertex(3, -1, -1),
  ],
];

const _octahedronMeshData = MeshData(
  vertices: _octahedronVertices,
  faces: _octahedronFaces,
);

//</editor-fold>

/// ピン
///
/// [origin]を始端(底面)中心、[target]を終端(上面)として八面体のピンを配置する。
@immutable
class Pin extends _Beam {
  // ignore: unused_field
  static final _logger = Logger('Pin');

  const Pin({
    required super.origin,
    super.target = '',
  }) : super(fill: true);

  @override
  MeshData get data => _octahedronMeshData;

  /// ピンの半径は長さに比例する。
  @override
  MeshData _fillMeshData({
    required final MeshData data,
    required final double length,
  }) =>
      data.transformed(Matrix4.fromScale(const Vector3(0.25, 1, 0.25) * length));

//<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pin &&
          runtimeType == other.runtimeType &&
          origin == other.origin &&
          target == other.target);

  @override
  int get hashCode => origin.hashCode ^ target.hashCode;

  @override
  String toString() {
    return 'Pin{ origin: $origin, target: $target}';
  }

  Pin copyWith({
    String? origin,
    String? target,
  }) {
    return Pin(
      origin: origin ?? this.origin,
      target: target ?? this.target,
    );
  }

//</editor-fold>
}

/// メッシュデータ
///
/// [origin]を軸線始端、[target]を終端としてメッシュデータを配置する。
@immutable
class Mesh extends _Beam {
  // ignore: unused_field
  static final _logger = Logger('Mesh');

  final MeshData _data;

  const Mesh({
    required super.origin,
    super.target = '',
    super.fill = false,
    required MeshData data,
  }) : _data = data;

  @override
  MeshData get data => _data;
}

/// 回転体メッシュデータ生成
abstract class _SorBuilder {
  static final logger = Logger('_SorBuilder');

  final int division;
  final bool smooth;
  final bool reverse;

  const _SorBuilder({
    required this.division,
    required this.smooth,
    required this.reverse,
  });

  /// 緯線頂点を生成する。
  @protected
  List<Vector3> makeLatitudeVertices({
    required int index,
  });

  @protected
  MeshData build() {
    // 頂点生成
    final vertices = <Vector3>[];
    vertices.addAll(makeLatitudeVertices(index: 0));
    final n = vertices.length;
    for (int i = 1; i < division; ++i) {
      final ridge = makeLatitudeVertices(index: i);
      assert(ridge.length == n);
      vertices.addAll(ridge);
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
    final data = MeshData(vertices: vertices, faces: faces, smooth: smooth);
    return reverse ? data.reversed() : data;
  }
}

/// 積み上げ式円筒メッシュデータ生成
/// TODO: まずは回転体か
///
/// (-0.5,0,-0.5)-(0.5,1,0.5)
/// TODO: 底面形状ドーム、平面、その他。ドームのためにあとでScaleはできない。

// /// XZ平面上の円（近似多角形）頂点リスト生成
// static List<Vector3> xzCircle({required double radius, required int division}) {
//   final vertices = <Vector3>[];
//   for (int i = 0; i < division; ++i) {
//     final t = i * math.pi * 2.0 / division;
//     vertices.add(Vector3(math.cos(t), 0, math.sin(t)));
//   }
//   return vertices;
// }
//
// /// Y軸中心
// MeshData addBowl1({
//   required double radius,
//   double endAngle = math.pi * 0.5,
//   required List<Vector3> points,
//   required int latDivision,
//   Matrix4 matrix = Matrix4.identity,
// }) {
//   assert(latDivision >= 1);
//   final xzRadius = (Vector3.unitX + Vector3.unitZ) * radius;
//   final yRadius = Vector3.unitY * radius;
//   // 頂点
//   MeshData data = this;
//   int index0 = vertices.length;
//   final index1 = index0 + 1;
//   final t = 1 * endAngle / latDivision;
//   data = data
//       .addVertices([
//         yRadius,
//         ...(points
//             .transformed(Matrix4.fromScale(xzRadius * math.sin(t)))
//             .transformed(Matrix4.fromTranslation(yRadius * math.cos(t))))
//       ].transformed(matrix))
//       .addCup(index0, index1, latDivision);
//   index0 = index1;
//   // 経線
//   for (int i = 2; i <= latDivision; ++i) {
//     final index1 = vertices.length;
//     final t = i * endAngle / latDivision;
//     data = data
//         .addVertices(points
//             .transformed(Matrix4.fromScale(xzRadius * math.sin(t)))
//             .transformed(Matrix4.fromTranslation(yRadius * math.cos(t)))
//             .transformed(matrix))
//         .addTube(index0, index1, latDivision);
//     index0 = index1;
//   }
//   return data;
// }
//
// /// Y軸中心の下半球状の面リスト追加
// MeshData addBowl({
//   required double radius,
//   double endAngle = math.pi * 0.5,
//   required int latDivision,
//   required int longDivision,
//   Matrix4 matrix = Matrix4.identity,
// }) {
//   assert(latDivision >= 2);
//   assert(longDivision >= 3);
//   return addBowl1(
//     radius: radius,
//     endAngle: endAngle,
//     points: xzCircle(radius: radius, division: longDivision),
//     latDivision: latDivision,
//     matrix: matrix,
//   );
// }
//
// /// 頂点と閉曲線間の盃状の面リスト追加
// MeshData addCup(int index0, int index1, int length) {
//   assert(index0 >= 0 && index0 <= vertices.length);
//   assert(index1 >= 0 && index1 + length <= vertices.length);
//   final faces = <MeshFace>[];
//   for (int i = 0; i < length - 1; ++i) {
//     faces.add(<MeshVertex>[
//       MeshVertex(index0, -1, -1),
//       MeshVertex(index1 + i, -1, -1),
//       MeshVertex(index1 + i + 1, -1, -1),
//     ]);
//   }
//   faces.add(<MeshVertex>[
//     MeshVertex(index0, -1, -1),
//     MeshVertex(index1 + length - 1, -1, -1),
//     MeshVertex(index1, -1, -1),
//   ]);
//   return addFaces(faces);
// }
//
// /// 閉曲線と頂点間の冠状の面リスト追加
// MeshData addCap(int index0, int length, index1) {
//   assert(index0 >= 0 && index0 + length <= vertices.length);
//   assert(index1 >= 0 && index1 <= vertices.length);
//   final faces = <MeshFace>[];
//   for (int i = 0; i < length - 1; ++i) {
//     faces.add(<MeshVertex>[
//       MeshVertex(index0 + i, -1, -1),
//       MeshVertex(index1, -1, -1),
//       MeshVertex(index0 + i + 1, -1, -1),
//     ]);
//   }
//   faces.add(<MeshVertex>[
//     MeshVertex(index0 + length - 1, -1, -1),
//     MeshVertex(index1, -1, -1),
//     MeshVertex(index0, -1, -1),
//   ]);
//   return addFaces(faces);
// }
//
// /// 二つの閉曲線間の帯状の面リスト追加
// MeshData addTube(int index0, int index1, int length) {
//   assert(index0 >= 0 && index0 + length <= vertices.length);
//   assert(index1 >= 0 && index1 + length <= vertices.length);
//   final faces = <MeshFace>[];
//   for (int i = 0; i < length - 1; ++i) {
//     faces.add(<MeshVertex>[
//       MeshVertex(index0 + i, -1, -1),
//       MeshVertex(index1 + i, -1, -1),
//       MeshVertex(index1 + i + 1, -1, -1),
//       MeshVertex(index0 + i + 1, -1, -1),
//     ]);
//   }
//   faces.add(<MeshVertex>[
//     MeshVertex(index0 + length - 1, -1, -1),
//     MeshVertex(index1 + length - 1, -1, -1),
//     MeshVertex(index1, -1, -1),
//     MeshVertex(index0, -1, -1),
//   ]);
//   return addFaces(faces);
// }

// MeshData _tubeMeshData({
//   required double radius,
//   required double length,
//   required int longDivision,
//   required int radiusDivision,
//   required int lengthDivision,
// }) {
//   final logger = Logger('_tubeMeshData');
//
//   var data = const MeshData();
//
//   // 底面
//   final circle = MeshData.xzCircle(radius: radius, division: longDivision);
//   var matrix0 = Matrix4.identity;
//   var index0 = data.vertices.length;
//   data = data.addVertices(circle.transformed(matrix0));
//   // 中間
//   for (int i = 1; i <= lengthDivision; ++i) {
//     final index1 = data.vertices.length;
//     final matrix1 = Matrix4.fromTranslation(Vector3.unitY * (i * length / lengthDivision));
//     data = data.addVertices(circle.transformed(matrix1)).addTube(index0, index1, circle.length);
//     index0 = index1;
//     matrix0 = matrix1;
//   }
//   return data;
// }
//
// /// 円筒
// ///
// /// [origin]を上面中心として円筒を生成する。
// class Tube extends Shape {
//   final String origin;
//   final double radius;
//   final double length;
//   final int longDivision;
//   final int radiusDivision;
//   final int lengthDivision;
//
//   const Tube({
//     required this.origin,
//     this.radius = 0.5,
//     this.length = 1.0,
//     this.longDivision = 8,
//     this.radiusDivision = 1,
//     this.lengthDivision = 1,
//   })  : assert(longDivision >= 3),
//         assert(radiusDivision >= 1),
//         assert(lengthDivision >= 1);
//
//   @override
//   List<MeshData> toMeshData({required Node root}) {
//     throw UnimplementedError();
//     // final find = root.find(path: origin)!;
//     // return _tubeMeshData(
//     //   radius: radius,
//     //   length: length,
//     //   longDivision: longDivision,
//     //   radiusDivision: radiusDivision,
//     //   lengthDivision: lengthDivision,
//     // ).transformed(find.matrix);
//   }
//
// //<editor-fold desc="Data Methods">
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       (other is Tube &&
//           runtimeType == other.runtimeType &&
//           origin == other.origin &&
//           radius == other.radius &&
//           length == other.length &&
//           longDivision == other.longDivision &&
//           radiusDivision == other.radiusDivision &&
//           lengthDivision == other.lengthDivision);
//
//   @override
//   int get hashCode =>
//       origin.hashCode ^
//       radius.hashCode ^
//       length.hashCode ^
//       longDivision.hashCode ^
//       radiusDivision.hashCode ^
//       lengthDivision.hashCode;
//
//   @override
//   String toString() {
//     return 'Tube{'
//         ' origin: $origin,'
//         ' radius: $radius,'
//         ' length: $length,'
//         ' longDivision: $longDivision,'
//         ' radiusDivision: $radiusDivision,'
//         ' lengthDivision: $lengthDivision,'
//         '}';
//   }
//
//   Tube copyWith({
//     String? origin,
//     double? radius,
//     double? length,
//     int? longDivision,
//     int? radiusDivision,
//     int? lengthDivision,
//   }) {
//     return Tube(
//       origin: origin ?? this.origin,
//       radius: radius ?? this.radius,
//       length: length ?? this.length,
//       longDivision: longDivision ?? this.longDivision,
//       radiusDivision: radiusDivision ?? this.radiusDivision,
//       lengthDivision: lengthDivision ?? this.lengthDivision,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'origin': origin,
//       'radius': radius,
//       'length': length,
//       'longDivision': longDivision,
//       'radiusDivision': radiusDivision,
//       'lengthDivision': lengthDivision,
//     };
//   }
//
//   factory Tube.fromMap(Map<String, dynamic> map) {
//     return Tube(
//       origin: map['origin'] as String,
//       radius: map['radius'] as double,
//       length: map['length'] as double,
//       longDivision: map['longDivision'] as int,
//       radiusDivision: map['radiusDivision'] as int,
//       lengthDivision: map['lengthDivision'] as int,
//     );
//   }
//
// //</editor-fold>
// }
