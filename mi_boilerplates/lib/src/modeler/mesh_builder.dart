// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../helpers.dart';
import 'basic.dart';

// スクリプト的モデラ、メッシュデータ生成

// 立方体メッシュデータ (0,0,0)-(1,1,1)
// todo: default texture vertex
//<editor-fold>

const _cubeVertices = <Vector3>[
  Vector3(1, 1, 0),
  Vector3(1, 0, 0),
  Vector3(1, 1, 1),
  Vector3(1, 0, 1),
  Vector3(0, 1, 0),
  Vector3(0, 0, 0),
  Vector3(0, 1, 1),
  Vector3(0, 0, 1),
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

const _cubeMeshObject = MeshObject(
  vertices: _cubeVertices,
  normals: _cubeNormals,
  faceGroups: <MeshFaceGroup>[MeshFaceGroup(faces: _cubeFaces)],
);

//</editor-fold>

/// 直方体メッシュビルダ
@immutable
class CubeBuilder extends MeshBuilder {
  final Vector3 min;
  final Vector3 max;
  final int tessellationLevel;

  const CubeBuilder({
    this.min = const Vector3(-0.5, 0, -0.5),
    this.max = const Vector3(0.5, 1, 0.5),
    this.tessellationLevel = 0,
  }) : assert(tessellationLevel >= 0);

  @override
  MeshData build() {
    final vertices = _cubeVertices
        .map(
          (it) => Vector3(
            it.x == 0 ? min.x : max.x,
            it.y == 0 ? min.y : max.y,
            it.z == 0 ? min.z : max.z,
          ),
        )
        .toList();
    return <MeshObject>[
      _cubeMeshObject.copyWith(vertices: vertices).tessellated(tessellationLevel),
    ];
  }
}

// 正八面体メッシュデータ
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

// ignore: unused_element
const _octahedronMeshObject = MeshObject(
  vertices: _octahedronVertices,
  faceGroups: <MeshFaceGroup>[MeshFaceGroup(faces: _octahedronFaces)],
);

//</editor-fold>

/// ピンメッシュデータ (-0.1,0,-0.1)-(0.1,1,0.1)
//<editor-fold>

const _pinVertices = <Vector3>[
  Vector3(0.1, 0.25, 0),
  Vector3(-0.1, 0.25, 0),
  Vector3(0, 1, 0),
  Vector3(0, 0, 0),
  Vector3(0, 0.25, 0.1),
  Vector3(0, 0.25, -0.1),
];

const pinMeshObject = MeshObject(
  vertices: _pinVertices,
  faceGroups: <MeshFaceGroup>[MeshFaceGroup(faces: _octahedronFaces)],
);

//</editor-fold>

/// 回転体メッシュビルダ基底クラス
@immutable
abstract class _SorBuilder extends MeshBuilder {
  // ignore: unused_field
  static final _logger = Logger('_SorBuilder');

  final int longitudeDivision;
  final Vector3 axis;
  final String materialLibrary;
  final String material;
  final bool smooth;
  final bool reverse;

  const _SorBuilder({
    this.longitudeDivision = 24,
    this.axis = Vector3.unitY,
    this.materialLibrary = '',
    this.material = '',
    this.smooth = true,
    this.reverse = false,
  }) : assert(longitudeDivision >= 2);

  /// 母線生成(Y軸周り)
  @protected
  List<Vector3> makeGeneratingLine();

  /// 経線生成(Y軸周り)
  @protected
  List<Vector3> makeLineOfLongitude({
    required List<Vector3> generatingLine,
    required int index,
  }) =>
      generatingLine
          .transformed(
            Matrix4.fromAxisAngleRotation(
              axis: Vector3.unitY,
              radians: index * math.pi * 2.0 / longitudeDivision,
            ),
          )
          .toList();

  /// 頂点生成
  @protected
  List<Vector3> makeVertices() {
    final generatingLine = makeGeneratingLine();
    final vertices = makeLineOfLongitude(
      generatingLine: generatingLine,
      index: 0,
    );
    final n = vertices.length;
    assert(n >= 2);
    for (int i = 1; i < longitudeDivision; ++i) {
      final lineOfLongitude = makeLineOfLongitude(
        generatingLine: generatingLine,
        index: i,
      );
      // 全ての経線の頂点数は同一でなければならない
      assert(lineOfLongitude.length == n);
      vertices.addAll(lineOfLongitude);
    }
    return vertices;
  }

  /// 面生成
  @protected
  List<MeshFace> makeFaces({
    required List<Vector3> vertices,
  }) {
    assert(vertices.length % longitudeDivision == 0);
    final n = vertices.length ~/ longitudeDivision;
    assert(n >= 2);
    final faces = <MeshFace>[];
    void addFaces(final int j0, final int j1) {
      for (int i = 0; i < n - 1; ++i) {
        faces.add(<MeshVertex>[
          MeshVertex(j0 + i),
          MeshVertex(j1 + i),
          MeshVertex(j1 + i + 1),
          MeshVertex(j0 + i + 1),
        ]);
      }
    }

    for (int i = 0; i < longitudeDivision - 1; ++i) {
      addFaces(i * n, (i + 1) * n);
    }
    addFaces((longitudeDivision - 1) * n, 0);
    return faces;
  }

  /// メッシュデータ生成
  /// todo: axis
  @override
  MeshData build() {
    assert(longitudeDivision >= 2);
    final vertices = makeVertices();
    final faces = makeFaces(vertices: vertices);
    final object = MeshObject(
      vertices: vertices,
      faceGroups: <MeshFaceGroup>[
        MeshFaceGroup(
          faces: faces,
          materialLibrary: materialLibrary,
          material: material,
          smooth: smooth,
        ),
      ],
    ).let((it) => reverse ? it.reversed() : it);
    return <MeshObject>[object];
  }
}

/// 扁球体メッシュビルダ
///
/// 原点を中心とする扁球体
@immutable
class EllipsoidBuilder extends _SorBuilder {
  // ignore: unused_field
  static final _logger = Logger('EllipsoidBuilder');

  final int latitudeDivision;
  final dynamic radius;

  const EllipsoidBuilder({
    super.longitudeDivision = 24,
    this.latitudeDivision = 12,
    this.radius = 0.5,
    super.axis = Vector3.unitY,
    super.materialLibrary = '',
    super.material = '',
    super.smooth = true,
    super.reverse = false,
  })  : assert(longitudeDivision >= 2),
        assert(latitudeDivision >= 1),
        assert(radius is double || radius is Vector3);

  /// 母線生成(Y軸周り)
  @protected
  @override
  List<Vector3> makeGeneratingLine() {
    // 扁球面
    final vertices = <Vector3>[const Vector3(0.0, -0.5, 0.0)];
    for (int i = 1; i < latitudeDivision; ++i) {
      final t = i * math.pi / latitudeDivision;
      vertices.add(Vector3(math.sin(t), -math.cos(t), 0.0));
    }
    vertices.add(const Vector3(0.0, 0.5, 0.0));
    return vertices;
  }

  /// メッシュデータ生成
  /// todo: axis
  @override
  MeshData build() {
    return super.build().transformed(Matrix4.fromScale(radius));
  }
}

/// 紡錘体メッシュビルダ
///
/// 原点を始点とする、母線が正弦曲線の紡錘形。
@immutable
class SpindleBuilder extends _SorBuilder {
  // ignore: unused_field
  static final _logger = Logger('SpindleBuilder');

  final int heightDivision;
  final double height;
  final dynamic radius; // ベクトルの場合Y成分は無視される

  const SpindleBuilder({
    super.longitudeDivision = 24,
    this.heightDivision = 12,
    this.height = 1.0,
    this.radius = Vector3.one,
    super.axis = Vector3.unitY,
    super.materialLibrary = '',
    super.material = '',
    super.smooth = true,
    super.reverse = false,
  })  : assert(longitudeDivision >= 2),
        assert(heightDivision >= 2),
        assert(radius is double || radius is Vector3);

  /// 母線生成(Y軸周り)
  @protected
  @override
  List<Vector3> makeGeneratingLine() {
    // 紡錘面(正弦曲線)
    final vertices = <Vector3>[Vector3.zero];
    for (int i = 0; i < heightDivision; ++i) {
      final h = i / heightDivision;
      vertices.add(Vector3(math.sin(h * math.pi) * 0.5, h, 0.0));
    }
    vertices.add(Vector3.unitY);
    return vertices;
  }

  /// メッシュデータ生成
  /// todo: axis
  @override
  MeshData build() {
    var radius_ = radius;
    if (radius is Vector3) {
      radius_ = (radius as Vector3).copyWith(y: height);
    }
    return super.build().transformed(Matrix4.fromScale(radius_));
  }
}

/// 輪郭線回転表面ビルダ
///
/// Bezier曲線を輪郭とする形状を生成する。
/// todo: 曲線一般化
class BezierBuilder extends _SorBuilder {
  // ignore: unused_field
  static final _logger = Logger('BezierBuilder');

  final int heightDivision;
  final Bezier<Vector3> xCurve; // X座標が幅(X)を表す
  final Bezier<Vector3> zCurve; // X座標が厚さ(Z)を表す

  const BezierBuilder({
    super.longitudeDivision = 24,
    this.heightDivision = 12,
    required Bezier<Vector3> curve,
    super.axis = Vector3.unitY,
    super.materialLibrary = '',
    super.material = '',
    super.smooth = true,
    super.reverse = false,
  })  : assert(longitudeDivision >= 2),
        assert(heightDivision >= 1),
        xCurve = curve,
        zCurve = curve;

  const BezierBuilder.fromXZ({
    super.longitudeDivision = 24,
    this.heightDivision = 12,
    required this.xCurve,
    required this.zCurve,
    super.axis = Vector3.unitY,
    super.materialLibrary = '',
    super.material = '',
    super.smooth = true,
    super.reverse = false,
  })  : assert(longitudeDivision >= 2),
        assert(heightDivision >= 2);

  /// 母線(Y軸周り)は使用しない
  @protected
  @override
  List<Vector3> makeGeneratingLine() => <Vector3>[];

  /// 経線生成(Y軸周り)
  @protected
  @override
  List<Vector3> makeLineOfLongitude({
    required List<Vector3> generatingLine, //使用しない
    required int index,
  }) {
    final longitude = index * 2.0 * math.pi / longitudeDivision;
    final cosL = math.cos(longitude), sinL = math.sin(longitude);
    final vertices = <Vector3>[];
    for (int i = 0; i <= heightDivision; ++i) {
      final t = i / heightDivision;
      final x = xCurve.transform(t);
      final z = zCurve.transform(t); //todo: zCurveは前後で変えらるよう
      // 半径とy座標は経度をもとに重みづけ
      final r = math.sqrt(math.pow(cosL * x.x, 2) + math.pow(sinL * z.x, 2));
      final y = math.sqrt(math.pow(cosL * x.y, 2) + math.pow(sinL * z.y, 2));
      vertices.add(Vector3(r, y, 0.0));
    }
    return vertices
        .transformed(
          Matrix4.fromAxisAngleRotation(
            axis: Vector3.unitY,
            radians: longitude,
          ),
        )
        .toList();
  }
}

// 円筒などの末端形状

/// 末端形状の基底クラス
@immutable
abstract class EndShape {
  const EndShape();
}

/// 開
@immutable
class OpenEnd extends EndShape {
  const OpenEnd();
}

/// 錐
@immutable
class ConeEnd extends EndShape {
  final double height;
  final int division;
  const ConeEnd({this.height = double.infinity, this.division = 1});
}

/// 閉
@immutable
class FlatEnd extends ConeEnd {
  const FlatEnd({super.division = 1}) : super(height: 0.0);
}

/// 曲面
@immutable
class DomeEnd extends EndShape {
  final double height;
  final int division;
  const DomeEnd({this.height = double.infinity, this.division = 4});
}

/// 円筒メッシュビルダ
@immutable
class TubeBuilder extends _SorBuilder {
  // ignore: unused_field
  static final _logger = Logger('TubeBuilder');

  final double height;
  final int heightDivision;
  final double beginRadius;
  final double endRadius;
  final EndShape beginShape;
  final EndShape endShape;

  const TubeBuilder({
    super.axis = Vector3.unitY,
    super.longitudeDivision = 12,
    this.height = 1.0,
    this.heightDivision = 1,
    this.beginRadius = 0.5,
    this.endRadius = 0.5,
    this.beginShape = const OpenEnd(),
    this.endShape = const OpenEnd(),
    super.materialLibrary = '',
    super.material = '',
    super.smooth = true,
    super.reverse = false,
  })  : assert(longitudeDivision >= 2),
        assert(heightDivision >= 1);

  /// 母線生成(Y軸周り)
  @protected
  @override
  List<Vector3> makeGeneratingLine() {
    // todo: 母線再利用
    assert(longitudeDivision >= 2);
    assert(heightDivision >= 1);

    // 母線頂点生成
    final vertices = <Vector3>[];
    // 始端
    switch (beginShape.runtimeType) {
      case ConeEnd:
      case FlatEnd:
        final coneEnd = beginShape as ConeEnd;
        final coneHeight = coneEnd.height == double.infinity ? beginRadius : coneEnd.height;
        for (int i = 0; i < coneEnd.division; ++i) {
          final t = i / coneEnd.division;
          vertices.add(Vector3(t * beginRadius, (1.0 - t) * -coneHeight, 0.0));
        }
        break;
      case DomeEnd:
        final domeEnd = beginShape as DomeEnd;
        final domeHeight = domeEnd.height == double.infinity ? beginRadius : domeEnd.height;
        for (int i = 0; i < domeEnd.division; ++i) {
          final t = i / domeEnd.division;
          final a = (1.0 - t) * math.pi * 0.5;
          vertices.add(Vector3(math.cos(a) * beginRadius, math.sin(a) * -domeHeight, 0.0));
        }
        break;
      default: // OpenEnd
        break;
    }
    // 胴
    for (int i = 0; i < heightDivision; ++i) {
      final t = i / heightDivision;
      vertices.add(Vector3((endRadius - beginRadius) * t + beginRadius, t * height, 0.0));
    }
    vertices.add(Vector3(endRadius, height, 0.0));
    // 終端
    switch (endShape.runtimeType) {
      case ConeEnd:
      case FlatEnd:
        final coneEnd = endShape as ConeEnd;
        final coneHeight = coneEnd.height == double.infinity ? endRadius : coneEnd.height;
        for (int i = 1; i <= coneEnd.division; ++i) {
          final t = i / coneEnd.division;
          vertices.add(Vector3((1.0 - t) * endRadius, t * coneHeight + height, 0.0));
        }
        break;
      case DomeEnd:
        final domeEnd = endShape as DomeEnd;
        final domeHeight = domeEnd.height == double.infinity ? endRadius : domeEnd.height;
        for (int i = 1; i <= domeEnd.division; ++i) {
          final t = i / domeEnd.division;
          final a = t * math.pi * 0.5;
          vertices.add(Vector3(math.cos(a) * endRadius, math.sin(a) * domeHeight + height, 0.0));
        }
        break;
      default: // OpenEnd
        break;
    }
    return vertices;
  }
}

// /// 箱メッシュビルダ
// todo: radiataを削除し、_Sorからの派生でなんとかする。
// @immutable
// class BoxBuilder extends RadiataBuilder {
//   // ignore: unused_field
//   static final _logger = Logger('BoxBuilder');
//
//   final math.Rectangle<double> beginRect;
//   final math.Rectangle<double>? endRect;
//   final double height;
//   final int widthDivision;
//   final int heightDivision;
//   final int depthDivision;
//   final EndShape beginShape;
//   final EndShape endShape;
//
//   const BoxBuilder({
//     this.beginRect = const math.Rectangle<double>(-0.5, -0.5, 1.0, 1.0),
//     this.endRect,
//     this.height = 1.0,
//     this.widthDivision = 1,
//     this.heightDivision = 1,
//     this.depthDivision = 1,
//     this.beginShape = const FlatEnd(),
//     this.endShape = const FlatEnd(),
//     super.smooth = true,
//     super.reverse = false,
//   }) : super(circleDivision: (widthDivision + depthDivision) * 2);
//
//   @override
//   List<Vector3> makeEdge({required final int index}) {
//     assert(widthDivision >= 1);
//     assert(heightDivision >= 1);
//     assert(depthDivision >= 1);
//
//     // (0.0, 0.0)-(1.0, 1.0)
//     Vector3 iToXz(final int index) {
//       int i = circleDivision - index;
//       if (i <= widthDivision) {
//         return Vector3(i.toDouble() / widthDivision, 0.0, 0.0);
//       }
//       i -= widthDivision;
//       if (i <= depthDivision) {
//         return Vector3(1.0, 0.0, i.toDouble() / depthDivision);
//       }
//       i -= depthDivision;
//       if (i <= widthDivision) {
//         return Vector3((widthDivision - i).toDouble() / widthDivision, 0.0, 1.0);
//       }
//       i -= widthDivision;
//       return Vector3(0.0, 0.0, (depthDivision - i).toDouble() / depthDivision);
//     }
//
//     // 断面
//     math.Rectangle<double> yToRect(final double y) {
//       final endRect_ = endRect ?? beginRect;
//       return math.Rectangle<double>(
//         y * (endRect_.left - beginRect.left) + beginRect.left,
//         y * (endRect_.top - beginRect.top) + beginRect.top,
//         y * (endRect_.width - beginRect.width) + beginRect.width,
//         y * (endRect_.height - beginRect.height) + beginRect.height,
//       );
//     }
//
//     final vertices = <Vector3>[];
//     // todo: beginShape
//     // 側面
//     final xz = iToXz(index);
//     for (int h = 0; h <= heightDivision; ++h) {
//       final y = h.toDouble() / heightDivision;
//       final rect = yToRect(y);
//       vertices.add(
//         Vector3(
//           xz.x * rect.width + rect.left,
//           y * height,
//           xz.z * rect.height + rect.top,
//         ),
//       );
//     }
//     // todo: endShape
//
//     return vertices;
//   }
// }

// /// ボーン
// class Bone {
//   final double radius;
//   final double force;
//   const Bone({
//     this.radius = double.maxFinite,
//     this.force = 1.0,
//   });
// }
//
// /// スキニング変形
// class SkinTransformer {
//   final MeshData data;
//   final List<Matrix4> originPoints;
//   final List<Matrix4> targetPoints;
//   final List<Bone> bones;
//
//   const SkinTransformer({
//     required this.data,
//     required this.originPoints,
//     required this.targetPoints,
//     required this.bones,
//   });
//
//   MeshData build() {
//     assert(originPoints.length == targetPoints.length);
//     assert(originPoints.length == bones.length);
//
//     // 頂点変形
//     final vertices = <Vector3>[];
//     for (final vertex in data.vertices) {
//       // 試作: 頂点は各originPointsからの距離に
//
//       vertices.add(vertex);
//     }
//
//     // TODO: 法線
//     return data.copyWith(
//       vertices: vertices,
//       normals: const <Vector3>[],
//     );
//   }
// }
//
// /// スキニング
// class Skin extends Shape {
//   final Map<String, Bone> bones;
//   final MeshData data;
//   final Node zeroPosition;
//
//   const Skin({
//     required this.bones,
//     required this.data,
//     required this.zeroPosition,
//   });
//
//   @override
//   List<MeshData> toMeshData({required final Node root}) {
//     // TODO: implement toMeshData
//     throw UnimplementedError();
//   }
// }

/// beam, mesh, skinは統一したい。
///
///
/// mesh: meshDataを外から渡す
/// beam: origin, target
/// skin: bone、zeroPosition beamとは排他かな
/// 統一すればいつでも切り替えられるようにできる。

/// メッシュデータをListや<key, data>{}に統一できないか
///

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
