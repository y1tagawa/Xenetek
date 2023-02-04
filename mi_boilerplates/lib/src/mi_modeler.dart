// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' hide Vector3, Matrix4;
import 'package:vector_math/vector_math_64.dart' as vm;

// 出力フォーマット
const _fractionDigits = 4;

/// 不変のVector3
class Vector3 {
  static const unitX = Vector3(1, 0, 0);
  static const unitY = Vector3(0, 1, 0);
  static const unitZ = Vector3(0, 0, 1);
  static const zero = Vector3(0, 0, 0);
  static const one = Vector3(1, 1, 1);

  final double x;
  final double y;
  final double z;

  const Vector3(this.x, this.y, this.z);

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

  /// ドット積
  double dot(Vector3 other) => x * other.x + y * other.y + z * other.z;

  /// クロス積
  Vector3 cross(Vector3 other) =>
      Vector3(y * other.z - z * other.y, z * other.x - x * other.z, x * other.y - y * other.x);

  /// 左右反転
  Vector3 mirrored() => Vector3(-x, y, z);

  /// 正規化
  Vector3 normalized() => Vector3.fromVmVector(toVmVector().normalized());

  /// 変換結果
  Vector3 transformed(Matrix4 matrix) {
    return Vector3.fromVmVector(matrix.toVmMatrix().transform3(toVmVector()));
  }

  /// vector_math.vm.Vector3から変換
  Vector3.fromVmVector(vm.Vector3 value)
      : x = value.x,
        y = value.y,
        z = value.z;

  /// vector_math.vm.Vector3に変換
  vm.Vector3 toVmVector() => vm.Vector3(x, y, z);

  /// 可読だが正確でない出力
  StringSink format({
    required StringSink sink,
    int indent = 0,
    String? key,
  }) {
    sink.write(''.padLeft(indent));
    if (key != null) {
      sink.write('key: key ');
    }
    sink.writeln('(${x.toStringAsFixed(4)} ${y.toStringAsFixed(4)} ${z.toStringAsFixed(4)})');
    return sink;
  }

  // TODO: to/fromJSON

  //<editor-fold desc="Data Methods">

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

//</editor-fold>
}

extension Vector3ListHelper on Iterable<Vector3> {
  List<Vector3> transformed(Matrix4 matrix) => map((value) => value.transformed(matrix)).toList();
}

/// [vector_math]の[Matrix4]のimmutableなfacade
///
class Matrix4 {
  // ignore: unused_field
  static final _logger = Logger('Matrix4');

  static const identity = Matrix4._(<double>[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
  static const zero = Matrix4._(<double>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

  final List<double> elements;

  const Matrix4._(this.elements);

  /// 回転行列
  static Matrix4 fromRotationAxisAngle(Vector3 axis, double radians) => Matrix4.fromVmMatrix(
        vm.Matrix4.compose(
          vm.Vector3.zero(),
          vm.Quaternion.axisAngle(axis.toVmVector(), radians),
          vm.Vector3(1, 1, 1),
        ),
      );

  /// 回転行列
  static Matrix4 fromRotationAxisAngleDegree(Vector3 axis, double degrees) =>
      fromRotationAxisAngle(axis, vm.radians(degrees));

  static Matrix4 fromRotationForwardTarget({
    required Vector3 forward,
    required Vector3 target,
  }) =>
      Matrix4.fromVmMatrix(
        vm.Matrix4.compose(
          vm.Vector3.zero(),
          vm.Quaternion.fromTwoVectors(forward.toVmVector(), target.toVmVector()),
          vm.Vector3(1, 1, 1),
        ),
      );

  /// 併進行列
  static Matrix4 fromTranslation(Vector3 position) =>
      Matrix4.fromVmMatrix(vm.Matrix4.translation(position.toVmVector()));

  /// 拡縮行列
  static Matrix4 fromScale(Vector3 scale) =>
      Matrix4.fromVmMatrix(vm.Matrix4.identity().scaled(scale.x, scale.y, scale.z));

  Matrix4.fromList(this.elements) : assert(elements.length == 16);

  Matrix4.fromVmMatrix(vm.Matrix4 value) : elements = value.storage;

  vm.Matrix4 toVmMatrix() {
    assert(elements.length == 16);
    return vm.Matrix4.fromList(elements);
  }

  /// 回転成分
  Matrix4 get rotation => Matrix4.fromList(
        <double>[
          elements[0], elements[1], elements[2], 0, //
          elements[4], elements[5], elements[6], 0, //
          elements[8], elements[9], elements[10], 0, //
          0, 0, 0, 1
        ],
      );

  /// 併進成分
  Vector3 get translation => Vector3(elements[12], elements[13], elements[14]);

  /// 行列積
  Matrix4 operator *(Matrix4 other) => Matrix4.fromVmMatrix(toVmMatrix() * other.toVmMatrix());

  /// 可読だが正確でない出力
  StringSink format({
    required StringSink sink,
    int indent = 0,
    String? key,
  }) {
    if (key != null) {
      sink.writeln('key: key'.padLeft(indent));
    }
    sink.write(''.padLeft(indent));
    sink.writeln(
      '(${elements[0].toStringAsFixed(4)}'
      ' ${elements[1].toStringAsFixed(4)}'
      ' ${elements[2].toStringAsFixed(4)}'
      ' ${elements[3].toStringAsFixed(4)}',
    );
    sink.write(''.padLeft(indent));
    sink.writeln(
      ' ${elements[4].toStringAsFixed(4)}'
      ' ${elements[5].toStringAsFixed(4)}'
      ' ${elements[6].toStringAsFixed(4)}'
      ' ${elements[7].toStringAsFixed(4)}',
    );
    sink.write(''.padLeft(indent));
    sink.writeln(
      ' ${elements[8].toStringAsFixed(4)}'
      ' ${elements[9].toStringAsFixed(4)}'
      ' ${elements[10].toStringAsFixed(4)}'
      ' ${elements[11].toStringAsFixed(4)}',
    );
    sink.write(''.padLeft(indent));
    sink.write(
      ' ${elements[12].toStringAsFixed(4)}'
      ' ${elements[13].toStringAsFixed(4)}'
      ' ${elements[14].toStringAsFixed(4)}'
      ' ${elements[15].toStringAsFixed(4)})',
    );
    return sink;
  }

  //<editor-fold desc="Data Methods">

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

//

String _toString(Iterable<String> path) => '[\'${path.join('\',\'')}\']';

Iterable<String> _toPath(dynamic path) {
  switch (path.runtimeType) {
    case List<String>:
    case Iterable<String>:
      return path;
    case String:
      return path.isEmpty ? const <String>[] : path.split('.');
    default:
      throw UnimplementedError('path.runtimeType=${path.runtimeType}');
  }
}

/// ノード
///
/// モデルの制御点（関節）を定義する。
/// [matrix]は親ノードからの相対的な変換を表す。
class Node {
  // ignore: unused_field
  static final _logger = Logger((Node).toString());

  final Matrix4 matrix;
  final Map<String, Node> children;

  const Node({
    this.matrix = Matrix4.identity,
    this.children = const <String, Node>{},
  });

  // [path]で指定するノードを検索し、(対象のノード, ルートからの相対変換, 直接の親)を返す。
  // 見つからなければ`null`を返す。
  NodeFind? _find({
    required Iterable<String> path,
    required Matrix4 matrix,
    Node? parent,
  }) {
    if (path.isEmpty) {
      return NodeFind(node: this, matrix: matrix * this.matrix, parent: parent);
    }
    final child = children[path.first];
    if (child == null) {
      return null;
    }
    return child._find(path: path.skip(1), matrix: matrix * this.matrix, parent: this);
  }

  /// [path]で指定するノードを検索し、(対象のノード, ルートからの相対変換, 直接の親)を返す。
  /// 見つからなければ`null`を返す。
  NodeFind? find({
    dynamic path,
  }) {
    return _find(path: _toPath(path), matrix: Matrix4.identity, parent: null);
  }

  // [path]で指定するノードを[child]で置換または追加する。
  // 親までの[path]が見つからなければ例外送出。
  Node _add({
    required Iterable<String> path,
    required Node child,
  }) {
    assert(path.isNotEmpty);
    // [path]が指すノードの親であれば
    if (path.length == 1) {
      // 指定の子を追加または置換する。
      final children_ = {...children};
      children_[path.first] = child;
      return Node(matrix: matrix, children: children_);
    }
    // パスを途中で辿れなくなったらエラー
    assert(children.containsKey(path.first));
    // パスの途中の子を更新して返す
    final children_ = {...children};
    children_[path.first] = children[path.first]!._add(path: path.skip(1), child: child);
    return Node(matrix: matrix, children: children_);
  }

  /// [path]で指定するノードを[child]で置換または追加する。
  /// 親までの[path]が見つからなければ例外送出。
  Node add({
    required dynamic path,
    required Node child,
  }) {
    return _add(path: _toPath(path), child: child);
  }

//TODO: 必要ならremove

  // [joints]を順次生成し、末端に（もしあれば）[children]を追加する。
  Node _addLimb({
    required Iterable<MapEntry<String, Matrix4>> joints,
    Map<String, Node>? children,
  }) {
    if (joints.isEmpty) {
      if (children != null) {
        return Node(children: children);
      }
      return this;
    }
    return add(
      path: joints.first.key,
      child: Node(matrix: joints.first.value)._addLimb(joints: joints.skip(1), children: children),
    );
  }

  /// [path]で指定するノードに、[joints]（およびもしあれば[children]）を順次追加する。
  /// 省略されたらノード自身に対して行う。
  Node addLimb({
    dynamic path = const <String>[],
    required Iterable<MapEntry<String, Matrix4>> joints,
    Map<String, Node>? children,
  }) {
    assert(joints.isNotEmpty);
    final tempNode = const Node()._addLimb(joints: joints, children: children);
    assert(tempNode.children.length == 1);
    final child = tempNode.children.entries.first;
    return add(
      path: [..._toPath(path), child.key],
      child: child.value,
    );
  }

  // ルート空間内の位置
  Vector3? getPosition({
    required dynamic path,
  }) {
    _logger.fine('[i] getPosition ${_toString(_toPath(path))}');
    return find(path: _toPath(path))?.matrix.translation;
  }

  /// [path]で指定するノードの変換行列を再設定する。
  /// 省略されたらノード自身に対して行う。
  Node setMatrix({
    dynamic path = const <String>[],
    required Matrix4 matrix,
  }) {
    final path_ = _toPath(path);
    final node = find(path: _toPath(path))!.node;
    return add(
      path: path_,
      child: Node(matrix: matrix, children: node.children),
    );
  }

  /// [path]で指定するノードの変換行列に変換を加える。
  /// 省略されたらノード自身に対して行う。
  Node transform({
    dynamic path = const <String>[],
    required Matrix4 matrix,
  }) {
    final path_ = _toPath(path);
    final node = find(path: _toPath(path))!.node;
    return add(
      path: path_,
      child: Node(matrix: node.matrix * matrix, children: node.children),
    );
  }

  /// 可読だが正確でない出力
  StringSink format({
    required StringSink sink,
    int indent = 0,
    String? key,
  }) {
    void print_({
      required int indent,
      required String? key,
      required Node node,
    }) {
      if (key != null) {
        sink.writeln();
        sink.write(''.padLeft(indent));
        sink.writeln(key);
        indent += 2;
      }
      node.matrix.format(sink: sink, indent: indent);
      for (final child in node.children.entries) {
        print_(
          indent: indent,
          key: child.key,
          node: child.value,
        );
      }
    }

    print_(indent: indent, key: key, node: this);
    return sink;
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

//</editor-fold>
}

// ドール(mk1)

/// 最小限のパラメタかドールモデルのリグを生成するビルダ。
///
/// todo: copyWithなど
class DollRigBuilder {
  final Vector3 pelvis; // rootから腰椎底の相対位置
  final double chest; // 胸椎底（腰椎の長さ）
  final double neck; // 頸椎底（胸椎の長さ）
  final double head; // 頭蓋底（頸椎の長さ）
  // 胸鎖関節
  final Vector3 sc; // 頸椎底から右胸鎖関節の相対位置
  // 右上肢 (肩関節で、以下はY+が右を向くよう回転する)
  // TODO: いずれ回転は止めて、Shapeの方で形状補完を吸収
  final Vector3 shoulder; // 右胸鎖関節から肩への相対位置
  final double elbow; // 上腕長
  final double wrist; // 前腕長
  // 右下肢 (股関節で、以下はY+が下を向くようX軸回りに180°
  final Vector3 hip; // 腰椎底から右股関節の位置
  final double knee; // 大腿長
  final double ankle; // 下腿長
  // 左は右の反転

  // TODO: 適当な初期値を適正に
  // https://www.airc.aist.go.jp/dhrt/91-92/data/search2.html
  const DollRigBuilder({
    this.pelvis = Vector3.zero,
    this.chest = 0.3,
    this.neck = 0.5,
    this.head = 0.2,
    this.sc = const Vector3(0.01, 0.0, -0.08),
    this.shoulder = const Vector3(0.14, 0.0, 0.05), //ちょっと前
    this.elbow = 0.45,
    this.wrist = 0.45,
    this.hip = const Vector3(0.1, 0.05, 0.0),
    this.knee = 0.5,
    this.ankle = 0.5,
  });

  /// リグ生成
  Node build() {
    Node root = const Node();
    // 脊柱
    root = root.addLimb(
      joints: <String, Matrix4>{
        'pelvis': Matrix4.fromTranslation(pelvis),
        'chest': Matrix4.fromTranslation(Vector3.unitY * chest),
        'neck': Matrix4.fromTranslation(Vector3.unitY * neck),
        'head': Matrix4.fromTranslation(Vector3.unitY * head),
      }.entries,
    );
    // 右下肢
    final hipRotation = Matrix4.fromRotationAxisAngle(Vector3.unitX, math.pi);
    root = root.addLimb(
      path: 'pelvis',
      joints: <String, Matrix4>{
        'rHip': Matrix4.fromTranslation(hip) * hipRotation,
        'knee': Matrix4.fromTranslation(Vector3.unitY * knee),
        'ankle': Matrix4.fromTranslation(Vector3.unitY * ankle),
      }.entries,
    );
    // 左下肢
    root = root.addLimb(
      path: 'pelvis',
      joints: <String, Matrix4>{
        'lHip': Matrix4.fromTranslation(hip.mirrored()) * hipRotation,
        'knee': Matrix4.fromTranslation(Vector3.unitY * knee),
        'ankle': Matrix4.fromTranslation(Vector3.unitY * ankle),
      }.entries,
    );
    // 右上肢
    root = root.addLimb(
      path: 'pelvis.chest.neck',
      joints: <String, Matrix4>{
        'rSc': Matrix4.fromTranslation(sc),
        'shoulder': Matrix4.fromTranslation(shoulder) *
            Matrix4.fromRotationAxisAngleDegree(Vector3.unitZ, -120),
        'elbow': Matrix4.fromTranslation(Vector3.unitY * elbow),
        'wrist': Matrix4.fromTranslation(Vector3.unitY * wrist),
      }.entries,
    );
    // 左上肢
    root = root.addLimb(
      path: 'pelvis.chest.neck',
      joints: <String, Matrix4>{
        'lSc': Matrix4.fromTranslation(sc.mirrored()),
        'shoulder': Matrix4.fromTranslation(shoulder.mirrored()) *
            Matrix4.fromRotationAxisAngleDegree(Vector3.unitZ, 120),
        'elbow': Matrix4.fromTranslation(Vector3.unitY * elbow),
        'wrist': Matrix4.fromTranslation(Vector3.unitY * wrist),
      }.entries,
    );
    return root;
  }
}

class DollMeshBuilder {
  static final _logger = Logger('DollMeshBuilder');

  // ノードパス
  static const pelvis = 'pelvis';
  static const chest = 'pelvis.chest';
  static const neck = 'pelvis.chest.neck';
  static const head = 'pelvis.chest.neck.head';
  static const rSc = 'pelvis.chest.neck.rSc';
  static const lSc = 'pelvis.chest.neck.lSc';
  static const rShoulder = 'pelvis.chest.neck.rSc.shoulder';
  static const lShoulder = 'pelvis.chest.neck.lSc.shoulder';
  static const rElbow = 'pelvis.chest.neck.rSc.shoulder.elbow';
  static const lElbow = 'pelvis.chest.neck.lSc.shoulder.elbow';
  static const rWrist = 'pelvis.chest.neck.rSc.shoulder.elbow.wrist';
  static const lWrist = 'pelvis.chest.neck.lSc.shoulder.elbow.wrist';
  static const rHip = 'pelvis.rHip';
  static const lHip = 'pelvis.lHip';
  static const rKnee = 'pelvis.rHip.knee';
  static const lKnee = 'pelvis.lHip.knee';
  static const rAnkle = 'pelvis.rHip.knee.ankle';
  static const lAnkle = 'pelvis.lHip.knee.ankle';

  final Node root;

  const DollMeshBuilder({required this.root});

  @protected
  List<MeshData> makePin(String origin, String end) {
    //
    final originNode = root.find(path: origin)!;
    final endNode = root.find(path: end)!;
    final eye = originNode.matrix.translation;
    final at = endNode.matrix.translation;
    final matrix = Matrix4.fromRotationForwardTarget(
      forward: Vector3.unitY.transformed(originNode.matrix),
      target: at - eye,
    );
    final meshData = _cubeMeshData.transformed(
      Matrix4.fromTranslation(eye) *
          matrix *
          Matrix4.fromScale(Vector3(0.1, (at - eye).length, 0.1)),
    );
    // final meshData = _cubeMeshData
    //     .transformed(originNode.matrix * Matrix4.fromScale(Vector3(0.1, (at - eye).length, 0.1)));
    return [meshData];
  }

  @protected
  Map<String, List<MeshData>> makeBody() {
    final buffer = <String, List<MeshData>>{};
    makePin(pelvis, chest).let((it) => buffer['waist'] = it);
    makePin(chest, neck).let((it) => buffer['chest'] = it);
    makePin(neck, head).let((it) => buffer['neck'] = it);
    return buffer;
  }

  @protected
  Map<String, List<MeshData>> makeRArm() {
    final buffer = <String, List<MeshData>>{};
    makePin(rShoulder, rElbow).let((it) => buffer['rUpperArm'] = it);
    makePin(rElbow, rWrist).let((it) => buffer['rForeArm'] = it);
    // todo: hand
    return buffer;
  }

  @protected
  Map<String, List<MeshData>> makeLArm() {
    final buffer = <String, List<MeshData>>{};
    makePin(lShoulder, lElbow).let((it) => buffer['lUpperArm'] = it);
    makePin(lElbow, lWrist).let((it) => buffer['lForeArm'] = it);
    // todo: hand
    return buffer;
  }

  @protected
  Map<String, List<MeshData>> makeRLeg() {
    final buffer = <String, List<MeshData>>{};
    makePin(rHip, rKnee).let((it) => buffer['rThigh'] = it);
    makePin(rKnee, rAnkle).let((it) => buffer['rShank'] = it);
    // todo: foot
    return buffer;
  }

  @protected
  Map<String, List<MeshData>> makeLLeg() {
    final buffer = <String, List<MeshData>>{};
    makePin(lHip, lKnee).let((it) => buffer['lThigh'] = it);
    makePin(lKnee, lAnkle).let((it) => buffer['lShank'] = it);
    // todo: foot
    return buffer;
  }

  Map<String, List<MeshData>> build() {
    final buffer = <String, List<MeshData>>{};
    buffer.addAll(makeBody());
    buffer.addAll(makeRArm());
    //buffer.addAll(makeLArm());
    //buffer.addAll(makeRLeg());
    //buffer.addAll(makeLLeg());
    return buffer;
  }
}

/// メッシュ頂点データ
///
/// 大体Wavefront .objの頂点データ。ただし、
/// - インデックスは0から。
/// - テクスチャ、法線インデックスを省略する場合は-1。

class MeshVertex {
  final int vertexIndex;
  final int textureVertexIndex;
  final int normalIndex;

  const MeshVertex(
    this.vertexIndex,
    this.textureVertexIndex,
    this.normalIndex,
  );

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
/// 大体Wavefrontの.objみたいなやつ。
class MeshData {
  // ignore: unused_field
  static final _logger = Logger('MeshData');

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

  /// Y軸中心
  MeshData addBowl1({
    required double radius,
    double endAngle = math.pi * 0.5,
    required List<Vector3> points,
    required int latDivision,
    Matrix4 matrix = Matrix4.identity,
  }) {
    assert(latDivision >= 1);
    final xzRadius = (Vector3.unitX + Vector3.unitZ) * radius;
    final yRadius = Vector3.unitY * radius;
    // 頂点
    MeshData data = this;
    int index0 = vertices.length;
    final index1 = index0 + 1;
    final t = 1 * endAngle / latDivision;
    data = data
        .addVertices([
          yRadius,
          ...(points
              .transformed(Matrix4.fromScale(xzRadius * math.sin(t)))
              .transformed(Matrix4.fromTranslation(yRadius * math.cos(t))))
        ].transformed(matrix))
        .addCup(index0, index1, latDivision);
    index0 = index1;
    // 経線
    for (int i = 2; i <= latDivision; ++i) {
      final index1 = vertices.length;
      final t = i * endAngle / latDivision;
      data = data
          .addVertices(points
              .transformed(Matrix4.fromScale(xzRadius * math.sin(t)))
              .transformed(Matrix4.fromTranslation(yRadius * math.cos(t)))
              .transformed(matrix))
          .addTube(index0, index1, latDivision);
      index0 = index1;
    }
    return data;
  }

  /// Y軸中心の下半球状の面リスト追加
  MeshData addBowl({
    required double radius,
    double endAngle = math.pi * 0.5,
    required int latDivision,
    required int longDivision,
    Matrix4 matrix = Matrix4.identity,
  }) {
    assert(latDivision >= 2);
    assert(longDivision >= 3);
    return addBowl1(
      radius: radius,
      endAngle: endAngle,
      points: xzCircle(radius: radius, division: longDivision),
      latDivision: latDivision,
      matrix: matrix,
    );
  }

  /// 頂点と閉曲線間の盃状の面リスト追加
  MeshData addCup(int index0, int index1, int length) {
    assert(index0 >= 0 && index0 <= vertices.length);
    assert(index1 >= 0 && index1 + length <= vertices.length);
    final faces = <MeshFace>[];
    for (int i = 0; i < length - 1; ++i) {
      faces.add(<MeshVertex>[
        MeshVertex(index0, -1, -1),
        MeshVertex(index1 + i, -1, -1),
        MeshVertex(index1 + i + 1, -1, -1),
      ]);
    }
    faces.add(<MeshVertex>[
      MeshVertex(index0, -1, -1),
      MeshVertex(index1 + length - 1, -1, -1),
      MeshVertex(index1, -1, -1),
    ]);
    return addFaces(faces);
  }

  /// 閉曲線と頂点間の冠状の面リスト追加
  MeshData addCap(int index0, int length, index1) {
    assert(index0 >= 0 && index0 + length <= vertices.length);
    assert(index1 >= 0 && index1 <= vertices.length);
    final faces = <MeshFace>[];
    for (int i = 0; i < length - 1; ++i) {
      faces.add(<MeshVertex>[
        MeshVertex(index0 + i, -1, -1),
        MeshVertex(index1, -1, -1),
        MeshVertex(index0 + i + 1, -1, -1),
      ]);
    }
    faces.add(<MeshVertex>[
      MeshVertex(index0 + length - 1, -1, -1),
      MeshVertex(index1, -1, -1),
      MeshVertex(index0, -1, -1),
    ]);
    return addFaces(faces);
  }

  /// 二つの閉曲線間の帯状の面リスト追加
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

/// メッシュデータアレイ
extension MeshDataArrayHelper on Map<String, List<MeshData>> {
  // ignore: unused_field
  static final _logger = Logger('toWavefrontObj');

  /// Wavefront .obj出力
  void toWavefrontObj(StringSink sink) {
    int vertexIndex = 1;
    int textureVertexIndex = 1;
    int normalIndex = 1;
    for (final entry in entries) {
      sink.writeln('# ${entry.key}');
      for (final data in entry.value) {
        for (final vertex in data.vertices) {
          sink.writeln(
            'v'
            ' ${vertex.x.toStringAsFixed(_fractionDigits)}'
            ' ${vertex.y.toStringAsFixed(_fractionDigits)}'
            ' ${vertex.z.toStringAsFixed(_fractionDigits)}',
          );
        }
        for (final textureVertex in data.textureVertices) {
          sink.writeln(
            'vt'
            ' ${textureVertex.x.toStringAsFixed(_fractionDigits)}'
            ' ${textureVertex.y.toStringAsFixed(_fractionDigits)}'
            ' ${textureVertex.z.toStringAsFixed(_fractionDigits)}',
          );
        }
        for (final normal in data.normals) {
          sink.writeln(
            'vn'
            ' ${normal.x.toStringAsFixed(_fractionDigits)}'
            ' ${normal.y.toStringAsFixed(_fractionDigits)}'
            ' ${normal.z.toStringAsFixed(_fractionDigits)}',
          );
        }
        sink.writeln('s ${data.smooth ? 1 : 0}');
        for (final face in data.faces) {
          assert(face.length >= 3);
          sink.write('f');
          for (final vertex in face) {
            assert(vertex.vertexIndex >= 0 && vertex.vertexIndex < data.vertices.length);
            sink.write(' ${vertex.vertexIndex + vertexIndex}');
            if (vertex.normalIndex >= 0) {
              sink.write('/');
              if (vertex.textureVertexIndex >= 0) {
                assert(vertex.textureVertexIndex < data.textureVertices.length);
                sink.write('${vertex.textureVertexIndex + textureVertexIndex}');
              }
              sink.write('/');
              assert(vertex.normalIndex < data.normals.length);
              sink.write('${vertex.normalIndex + normalIndex}');
            }
          }
          sink.writeln();
        }
        vertexIndex += data.vertices.length;
        textureVertexIndex += data.textureVertices.length;
        normalIndex += data.normals.length;
      }
    }
  }
}

/// 立方体メッシュデータ
///
/// (-0.5,0,-0.5)-(0.5,1,0.5)

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
/// [origin]を上面中心として直方体を生成する。

class Cube extends Shape {
  static final _logger = Logger('Cube');

  final String origin;
  final Vector3 scale;

  const Cube({
    required this.origin,
    this.scale = const Vector3(1, 1, 1),
  });

  @override
  MeshData toMeshData(Node root) {
    final find = root.find(path: origin);
    if (find == null) {
      _logger.fine('toMeshData: \'$origin\' not found.');
      return const MeshData();
    }

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
    return 'CubeMesh{ path: $origin, scale: $scale,}';
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

/// 正八面体メッシュデータ
///
/// (-0.5,0,-0.5)-(0.5,1,0.5)

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
/// [origin]を上中心として八面体のピンを生成する。

class Pin extends Shape {
  static final _logger = Logger('Pin');

  final String origin;
  final Vector3 scale;

  const Pin({
    required this.origin,
    this.scale = Vector3.one,
  });

  @override
  MeshData toMeshData(Node root) {
    final find = root.find(path: origin);
    if (find == null) {
      _logger.fine('toMeshData: \'$origin\' not found.');
      return const MeshData();
    }

    final vertices = _octahedronVertices
        .map((it) => Vector3(it.x * 0.75, it.y == 0.5 ? 0.25 : it.y, it.z * 0.75))
        .toList(growable: false);
    final meshData = MeshData(
      vertices: vertices,
      faces: _octahedronFaces,
    );
    return meshData.transformed(find.matrix * Matrix4.fromScale(Vector3.one * scale));
  }

//<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pin &&
          runtimeType == other.runtimeType &&
          origin == other.origin &&
          scale == other.scale);

  @override
  int get hashCode => origin.hashCode ^ scale.hashCode;

  @override
  String toString() {
    return 'Pin{ origin: $origin, scale: $scale,}';
  }

  Pin copyWith({
    String? origin,
    dynamic scale,
  }) {
    return Pin(
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

  factory Pin.fromMap(Map<String, dynamic> map) {
    return Pin(
      origin: map['origin'] as String,
      scale: map['scale'] as Vector3,
    );
  }

//</editor-fold>
}

/// 積み上げ式円筒メッシュデータ生成
/// TODO: まずは回転体か
///
/// (-0.5,0,-0.5)-(0.5,1,0.5)
/// TODO: 底面形状ドーム、平面、その他。ドームのためにあとでScaleはできない。

MeshData _tubeMeshData({
  required double radius,
  required double length,
  required int longDivision,
  required int radiusDivision,
  required int lengthDivision,
}) {
  final logger = Logger('_tubeMeshData');

  var data = const MeshData();

  // 底面
  final circle = MeshData.xzCircle(radius: radius, division: longDivision);
  var matrix0 = Matrix4.identity;
  var index0 = data.vertices.length;
  data = data.addVertices(circle.transformed(matrix0));
  // 中間
  for (int i = 1; i <= lengthDivision; ++i) {
    final index1 = data.vertices.length;
    final matrix1 = Matrix4.fromTranslation(Vector3.unitY * (i * length / lengthDivision));
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
  final int longDivision;
  final int radiusDivision;
  final int lengthDivision;

  const Tube({
    required this.origin,
    this.radius = 0.5,
    this.length = 1.0,
    this.longDivision = 8,
    this.radiusDivision = 1,
    this.lengthDivision = 1,
  })  : assert(longDivision >= 3),
        assert(radiusDivision >= 1),
        assert(lengthDivision >= 1);

  @override
  MeshData toMeshData(Node root) {
    final find = root.find(path: origin)!;
    return _tubeMeshData(
      radius: radius,
      length: length,
      longDivision: longDivision,
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
          longDivision == other.longDivision &&
          radiusDivision == other.radiusDivision &&
          lengthDivision == other.lengthDivision);

  @override
  int get hashCode =>
      origin.hashCode ^
      radius.hashCode ^
      length.hashCode ^
      longDivision.hashCode ^
      radiusDivision.hashCode ^
      lengthDivision.hashCode;

  @override
  String toString() {
    return 'Tube{'
        ' origin: $origin,'
        ' radius: $radius,'
        ' length: $length,'
        ' longDivision: $longDivision,'
        ' radiusDivision: $radiusDivision,'
        ' lengthDivision: $lengthDivision,'
        '}';
  }

  Tube copyWith({
    String? origin,
    double? radius,
    double? length,
    int? longDivision,
    int? radiusDivision,
    int? lengthDivision,
  }) {
    return Tube(
      origin: origin ?? this.origin,
      radius: radius ?? this.radius,
      length: length ?? this.length,
      longDivision: longDivision ?? this.longDivision,
      radiusDivision: radiusDivision ?? this.radiusDivision,
      lengthDivision: lengthDivision ?? this.lengthDivision,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'origin': origin,
      'radius': radius,
      'length': length,
      'longDivision': longDivision,
      'radiusDivision': radiusDivision,
      'lengthDivision': lengthDivision,
    };
  }

  factory Tube.fromMap(Map<String, dynamic> map) {
    return Tube(
      origin: map['origin'] as String,
      radius: map['radius'] as double,
      length: map['length'] as double,
      longDivision: map['longDivision'] as int,
      radiusDivision: map['radiusDivision'] as int,
      lengthDivision: map['lengthDivision'] as int,
    );
  }

//</editor-fold>
}
