// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

// スクリプト的モデラ

/// immutableの３次元ベクトル
@immutable
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
    if (other is num) {
      return Vector3(other * x, other * y, other * z);
    } else if (other is Vector3) {
      return Vector3(other.x * x, other.y * y, other.z * z);
    } else {
      throw UnimplementedError();
    }
  }

  /// スカラ商
  Vector3 operator /(double other) => this * (1.0 / other);

  /// ドット積
  double dot(Vector3 other) => x * other.x + y * other.y + z * other.z;

  /// クロス積
  Vector3 cross(Vector3 other) => Vector3(
        y * other.z - z * other.y,
        z * other.x - x * other.z,
        x * other.y - y * other.x,
      );

  /// 左右反転
  Vector3 mirrored() => Vector3(-x, y, z);

  /// 正規化
  Vector3 normalized() => Vector3.fromVmVector(toVmVector().normalized());

  /// 変換結果
  Vector3 transformed(Matrix4 matrix) =>
      Vector3.fromVmVector(matrix.toVmMatrix().transform3(toVmVector()));

  /// vm.Vector3から変換
  Vector3.fromVmVector(vm.Vector3 value)
      : x = value.x,
        y = value.y,
        z = value.z;

  /// vm.Vector3に変換
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
  Iterable<Vector3> scaled(dynamic scale) {
    if (scale is num) {
      return map((it) => Vector3(scale * it.x, scale * it.y, scale * it.z));
    } else if (scale is Vector3) {
      return map((it) => Vector3(scale.x * it.x, scale.y * it.y, scale.z * it.z));
    } else {
      throw UnimplementedError();
    }
  }

  Iterable<Vector3> mirrored() => map((value) => value.mirrored()).toList();
  Iterable<Vector3> transformed(Matrix4 matrix) =>
      map((value) => value.transformed(matrix)).toList();
}

/// immutableの4x4行列
@immutable
class Matrix4 {
  // ignore: unused_field
  static final _logger = Logger('Matrix4');

  static const identity = Matrix4._(<double>[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
  static const zero = Matrix4._(<double>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

  final List<double> elements;

  const Matrix4._(this.elements);

  /// 回転行列
  static Matrix4 fromAxisAngleRotation({
    required Vector3 axis,
    double? radians,
    double? degrees,
  }) {
    assert(radians != null || degrees != null || !(radians != null && degrees != null));
    return Matrix4.fromVmMatrix(
      vm.Matrix4.compose(
        vm.Vector3.zero(),
        vm.Quaternion.axisAngle(axis.toVmVector(), radians ?? degrees! * math.pi / 180.0),
        vm.Vector3(1, 1, 1),
      ),
    );
  }

  /// 回転行列
  static Matrix4 fromForwardTargetRotation({
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
  static Matrix4 fromScale(dynamic scale) {
    if (scale is num) {
      final scale_ = scale as double;
      return Matrix4.fromVmMatrix(vm.Matrix4.identity().scaled(scale_, scale_, scale_));
    } else if (scale is Vector3) {
      return Matrix4.fromVmMatrix(vm.Matrix4.identity().scaled(scale.x, scale.y, scale.z));
    } else {
      throw UnimplementedError();
    }
  }

  /// 要素リストから変換(並びはvm.Matrix4と同様。[12][13][14]が併進成分)
  const Matrix4.fromList(this.elements) : assert(elements.length == 16);

  /// vm.Matrix4から変換
  Matrix4.fromVmMatrix(vm.Matrix4 value) : elements = value.storage;

  /// vm.Matrix4に変換
  vm.Matrix4 toVmMatrix() {
    assert(elements.length == 16);
    return vm.Matrix4.fromList(elements);
  }

  /// 回転成分
  Matrix4 get rotation => Matrix4._(
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

  /// 逆行列
  Matrix4 inverted() => Matrix4.fromVmMatrix(vm.Matrix4.inverted(toVmMatrix()));

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

/// パラメトリック曲線の基底クラス
@immutable
abstract class Parametric<T, U> {
  const Parametric();
  U transform(T t);
}

/// Bezier補間
@immutable
abstract class Bezier<T> extends Parametric<double, T> {
  factory Bezier({
    required List<T> points,
  }) {
    if (points is List<double>) {
      return BezierDouble(points: points as List<double>) as Bezier<T>;
    } else if (points is List<Vector3>) {
      return BezierVector3(points: points as List<Vector3>) as Bezier<T>;
    } else {
      throw UnimplementedError();
    }
  }

  List<T> get points;

  @override
  T transform(double t);
}

/// Bezier補間(double)
@internal
@immutable
class BezierDouble implements Bezier<double> {
  // ignore: unused_field
  static final _logger = Logger('BezierDouble');

  final List<double> _points;

  const BezierDouble({
    required List<double> points,
  }) : _points = points;

  @override
  List<double> get points => _points;

  @override
  double transform(double t) {
    assert(_points.isNotEmpty);
    if (_points.length <= 4) {
      // 0次～3次
      return _transform(0, _points.length - 1, t);
    } else if ((_points.length - 1) % 3 == 0) {
      // 複数のセグメントがある場合は、[0,1]を等分割してそれぞれのセグメントに割り当てる。
      // ただしt<0またはt>1の場合は、それぞれ最初・最後のセグメントで外挿する。
      final m = (_points.length - 1) ~/ 3;
      if (t < 0.0) {
        return _transform(0, 3, t / m);
      } else if (t == 1.0) {
        return _points.last;
      } else if (t > 1.0) {
        return _transform(_points.length - 4, 3, (t - 1.0) / m);
      } else {
        return _transform((t * m).truncate() * 3, 3, (t * m) % 1.0);
      }
    } else {
      throw UnimplementedError();
    }
  }

  // [o]:セグメントの開始オフセット [n]:次数
  // [t]:セグメント内の媒介変数、[0,1]が始点終点に対応するが、その範囲外である場合もある。
  double _transform(int o, int n, double t) {
    assert(_points.isNotEmpty);
    final t_ = 1.0 - t;
    switch (n) {
      case 0:
        return _points[o];
      case 1:
        return _points[o] * t_ + _points[o + 1] * t;
      case 2:
        return _points[o] * (t_ * t_) + _points[o + 1] * (2.0 * t * t_) + _points[o + 2] * (t * t);
      case 3:
        return _points[o] * (t_ * t_ * t_) +
            _points[o + 1] * (3.0 * t * t_ * t_) +
            _points[o + 2] * (3.0 * t * t * t_) +
            _points[o + 3] * (t * t * t);
      default:
        throw UnimplementedError();
    }
  }
}

/// Bezier補間(Vector3)
@internal
@immutable
class BezierVector3 implements Bezier<Vector3> {
  // ignore: unused_field
  static final _logger = Logger('BezierVector3');

  final List<Vector3> _points;

  const BezierVector3({
    required List<Vector3> points,
  }) : _points = points;

  @override
  List<Vector3> get points => _points;

  @override
  Vector3 transform(double t) {
    assert(_points.isNotEmpty);
    if (_points.length <= 4) {
      // 0次～3次
      return _transform(0, _points.length - 1, t);
    } else if ((_points.length - 1) % 3 == 0) {
      // 複数のセグメントがある場合は、[0,1]を等分割してそれぞれのセグメントに割り当てる。
      // ただしt<0またはt>1の場合は、それぞれ最初・最後のセグメントで外挿する。
      final m = (_points.length - 1) ~/ 3;
      if (t < 0.0) {
        return _transform(0, 3, t / m);
      } else if (t == 1.0) {
        return _points.last;
      } else if (t > 1.0) {
        return _transform(_points.length - 4, 3, (t - 1.0) / m);
      } else {
        return _transform((t * m).truncate() * 3, 3, (t * m) % 1.0);
      }
    } else {
      throw UnimplementedError();
    }
  }

  // [o]:セグメントの開始オフセット [n]:次数
  // [t]:セグメント内の媒介変数、[0,1]が始点終点に対応するが、その範囲外である場合もある。
  Vector3 _transform(int o, int n, double t) {
    //_logger.fine('_transform $offset $t');
    final t_ = 1.0 - t;
    switch (n) {
      case 0:
        return _points[o];
      case 1:
        return _points[o] * t_ + _points[o + 1] * t;
      case 2:
        return _points[o] * (t_ * t_) + _points[o + 1] * (2.0 * t * t_) + _points[o + 2] * (t * t);
      case 3:
        return _points[o] * (t_ * t_ * t_) +
            _points[o + 1] * (3.0 * t * t_ * t_) +
            _points[o + 2] * (3.0 * t * t * t_) +
            _points[o + 3] * (t * t * t);
      default:
        throw UnimplementedError();
    }
  }
}

/// 始点からの曲線に沿った距離（近似値）に比例した位置を返すパラメトリック関数
///
/// 原始関数F(0),F(1)がf(0),f(1)に対応する。
@immutable
abstract class _Itinerary<U> extends Parametric<double, U> {
  final Parametric<double, U> primitive;
  final int resolution;

  const _Itinerary({
    required this.primitive,
    this.resolution = 100,
  })  : assert(resolution > 0),
        super();

  List<MapEntry<double, U>> get points;

  @override
  U transform(double t) {
    if (t < 0.0) {
      return points.first.value;
    } else if (t > 1.0) {
      return points.last.value;
    } else {
      assert(points.last.key >= 1e-4);
      final t_ = t / points.last.key;
      // todo: binary search
      for (final u in points) {
        if (u.key >= t_) {
          return u.value;
        }
      }
      return points.last.value;
    }
  }
}

/// 始点からの曲線に沿った距離（近似値）に比例した位置を返すパラメトリック関数(Vector3)
@immutable
class ItineraryVector3 extends _Itinerary<Vector3> {
  final _points = <MapEntry<double, Vector3>>[];

  ItineraryVector3({
    required super.primitive,
    super.resolution = 100,
  });

  @override
  List<MapEntry<double, Vector3>> get points {
    if (_points.isEmpty) {
      _makePoints();
    }
    return _points;
  }

  void _makePoints() {
    List<Vector3> t = <Vector3>[];
    for (int i = 0; i < resolution; ++i) {
      final u = i / resolution;
      t.add(primitive.transform(u));
    }
    Map<double, Vector3> u = <double, Vector3>{};
    double p = 0;
    for (int i = 0; i < resolution - 1; ++i) {
      u[p] = t[i];
      p += (t[i + 1] - t[i]).length;
    }
    u[p] = t.last;
    _points.addAll(u.entries.toList());
  }
}

//
// リグ
//

/// ノード検索結果
@immutable
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
@immutable
class Node {
  static const pathDelimiter = '.';

  // ignore: unused_field
  static final _logger = Logger((Node).toString());

  // ノードパス可読化
  // ignore: unused_element
  static String formatPath(Iterable<String> path) => '[\'${path.join('\',\'')}\']';

  // (文字列等で与えられた)ノードパス正規化
  static Iterable<String> _toPath(dynamic path) {
    if (path is Iterable<String>) {
      return path;
    } else if (path is String) {
      return path.isEmpty ? const <String>[] : path.split(pathDelimiter);
    } else {
      throw UnimplementedError('path=$path');
    }
  }

  // todo: bending
  final Matrix4 matrix;
  final Map<String, Node> children;

  const Node({
    this.matrix = Matrix4.identity,
    this.children = const <String, Node>{},
  });

  /// [path]で指定するノードを検索し、(対象のノード, ルートからの相対変換, 直接の親)を返す。
  /// 見つからなければ`null`を返す。
  NodeFind? find({
    dynamic path,
  }) {
    NodeFind? find_({
      required Node this_,
      required Iterable<String> path,
      required Matrix4 matrix,
      Node? parent,
    }) {
      if (path.isEmpty) {
        return NodeFind(node: this_, matrix: matrix * this_.matrix, parent: parent);
      }
      final child = this_.children[path.first];
      if (child == null) {
        return null;
      }
      return find_(this_: child, path: path.skip(1), matrix: matrix * this_.matrix, parent: this_);
    }

    final it = find_(this_: this, path: _toPath(path), matrix: Matrix4.identity, parent: null);
    if (it == null) {
      _logger.fine('path $path not found.');
    }
    return it;
  }

  /// ディープコピー
  Node copy() {
    return Node(
      matrix: matrix,
      children: <String, Node>{
        ...children.map((key, value) => MapEntry(key, value.copy())),
      },
    );
  }

  /// [path]で指定するノードを[child]で置換または削除したコピーを返す。
  Node _modified({
    required Iterable<String> path,
    required Node Function(Node, String) modifier,
  }) {
    assert(path.isNotEmpty);
    // [path]が指すノードの親であれば
    if (path.length == 1) {
      // 指定の子を追加、置換または削除する。
      return modifier(this, path.first);
    }
    // パスを途中で辿れなくなったらエラー
    assert(children.containsKey(path.first));
    // パスの途中の子を更新して返す
    final children_ = {...children};
    children_[path.first] = children[path.first]!._modified(
      path: path.skip(1),
      modifier: modifier,
    );
    return Node(matrix: matrix, children: children_);
  }

  /// [path]で指定するノードを[child]で置換または追加したコピーを返す。
  /// 親までの[path]が見つからなければ例外送出。
  Node add({
    required dynamic path,
    required Node child,
  }) {
    final path_ = _toPath(path);
    return _modified(
        path: path_,
        modifier: (node, key) {
          final children_ = {...node.children};
          children_[key] = child;
          return node.copyWith(children: children_);
        });
  }

  Node addAll({required Iterable<MapEntry<dynamic, Node>> entries}) {
    var this_ = this;
    for (final entry in entries) {
      this_ = this_.add(path: entry.key, child: entry.value);
    }
    return this_;
  }

  // 連続した関節ノードを生成する。
  Node _makeLimb({
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
      child: Node(matrix: joints.first.value)._makeLimb(joints: joints.skip(1), children: children),
    );
  }

  /// [path]で指定するノードに、連続した関節ノードを追加したコピーを返す。
  Node addLimb({
    dynamic path = const <String>[],
    required Iterable<MapEntry<String, Matrix4>> joints,
    Map<String, Node>? children,
  }) {
    // 一時ノードの下に関節ノードsを生成し……
    assert(joints.isNotEmpty);
    final t = const Node()._makeLimb(joints: joints, children: children);
    assert(t.children.length == 1);
    // 生成された関節ノードsを[path]に追加したコピーを返す。
    final child = t.children.entries.first;
    return add(
      path: [..._toPath(path), child.key],
      child: child.value,
    );
  }

  /// [path]で指定するノードを変換したコピーを返す。
  Node transform({
    dynamic path = const <String>[],
    required Matrix4 matrix,
  }) {
    final path_ = _toPath(path);
    if (path_.isEmpty) {
      return Node(matrix: this.matrix * matrix, children: children);
    }
    final node = find(path: path_)!.node;
    return add(
      path: path_,
      child: Node(matrix: node.matrix * matrix, children: node.children),
    );
  }

  /// [path]で指定したノードが、[targetPath]の原点を向くよう変換したコピーを返す。
  Node lookAt({
    dynamic path = const <String>[],
    required dynamic targetPath,
    Vector3 forward = Vector3.unitY, // todo: -unitZ
  }) {
    final path_ = _toPath(path);
    final matrix = find(path: path_)!.matrix;
    final targetPath_ = _toPath(targetPath);
    final targetMatrix = find(path: targetPath_)!.matrix;
    return transform(
      path: path_,
      matrix: Matrix4.fromForwardTargetRotation(
        forward: forward,
        target: (matrix.inverted() * targetMatrix).translation,
      ),
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

//
// メッシュデータ
//

/// 頂点データ
///
/// 大体Wavefront .objの頂点データ。ただし、
/// - インデックスは0から。
/// - テクスチャ、法線インデックスを省略する場合は-1。
@immutable
class MeshVertex {
  final int vertexIndex;
  final int textureVertexIndex;
  final int normalIndex;

  const MeshVertex(
    this.vertexIndex, [
    this.textureVertexIndex = -1,
    this.normalIndex = -1,
  ]);

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

/// 面データ
typedef MeshFace = List<MeshVertex>;

/// 面グループ
///
/// マテリアル等を共有する面のグループ。
@immutable
class MeshFaceGroup {
  // ignore: unused_field
  static final _logger = Logger('MeshFaceGroup');

  final List<MeshFace> faces;
  final String materialLibrary;
  final String material;
  final bool smooth;

  const MeshFaceGroup({
    this.faces = const <MeshFace>[],
    this.materialLibrary = '',
    this.material = '',
    this.smooth = false,
  });

  /// 面を表裏反転したコピーを返す。
  MeshFaceGroup reversed() {
    final faces_ = <MeshFace>[];
    for (final face in faces) {
      assert(face.isNotEmpty);
      faces_.add([face[0], ...face.skip(1).toList().reversed]);
    }
    return copyWith(faces: faces_);
  }

//<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeshFaceGroup &&
          runtimeType == other.runtimeType &&
          faces == other.faces &&
          materialLibrary == other.materialLibrary &&
          material == other.material &&
          smooth == other.smooth);

  @override
  int get hashCode =>
      faces.hashCode ^ materialLibrary.hashCode ^ material.hashCode ^ smooth.hashCode;

  @override
  String toString() {
    return 'MeshFaceGroup{'
        ' faces: $faces,'
        ' materialLibrary: $materialLibrary,'
        ' material: $material,'
        ' smooth: $smooth,'
        '}';
  }

  MeshFaceGroup copyWith({
    List<MeshFace>? faces,
    String? materialLibrary,
    String? material,
    bool? smooth,
  }) {
    return MeshFaceGroup(
      faces: faces ?? this.faces,
      materialLibrary: materialLibrary ?? this.materialLibrary,
      material: material ?? this.material,
      smooth: smooth ?? this.smooth,
    );
  }

//</editor-fold>
}

/// メッシュオブジェクト
@immutable
class MeshObject {
  // ignore: unused_field
  static final _logger = Logger('MeshObject');

  final List<Vector3> vertices;
  final List<Vector3> normals;
  final List<Vector3> textureVertices;
  final List<MeshFaceGroup> faceGroups;
  final String tag;

  const MeshObject({
    this.vertices = const <Vector3>[],
    this.normals = const <Vector3>[],
    this.textureVertices = const <Vector3>[],
    this.faceGroups = const <MeshFaceGroup>[],
    this.tag = '',
  });

  /// 変換
  MeshObject transformed(Matrix4 matrix) => copyWith(
        vertices: vertices.transformed(matrix).toList(),
        normals: normals.transformed(matrix.rotation).toList(),
      );

  /// 左右反転したコピーを返す。
  MeshObject mirrored() => copyWith(
        vertices: vertices.mirrored().toList(),
        normals: normals.mirrored().toList(),
      ).reversed();

  /// 面を表裏反転したコピーを返す。
  MeshObject reversed() => copyWith(
        faceGroups: faceGroups.map((it) => it.reversed()).toList(),
      );

  /// 面を再分割する。
  ///
  /// 三角ポリゴンは三鱗型、四角ポリゴンは田の字型に分割する。
  /// todo: normals, textureVertices, helper送り
  MeshObject tessellated([final int level = 0]) {
    assert(level >= 0);
    if (level == 0) return this;

    // 辺と中点のリスト
    final vertices_ = vertices.toList();
    final midPoints = <MapEntry<int, int>, int>{};
    int getMidPoint(final int v0, final int v1) {
      assert(v0 >= 0 && v0 < vertices_.length);
      assert(v1 >= 0 && v1 < vertices_.length);
      assert(v0 != v1);
      final key = v0 < v1 ? MapEntry(v0, v1) : MapEntry(v1, v0);
      final vertexIndex = midPoints[key];
      if (vertexIndex != null) {
        return vertexIndex;
      }
      vertices_.add((vertices_[v0] + vertices_[v1]) * 0.5);
      midPoints[key] = vertices_.length - 1;
      return vertices_.length - 1;
    }

    final faceGroups_ = <MeshFaceGroup>[];
    for (final faceGroup in faceGroups) {
      final faces_ = <MeshFace>[];
      for (final face in faceGroup.faces) {
        switch (face.length) {
          case 3:
            //    v0
            //  v3  v5
            // v1 v4 v2
            final v0 = face[0].vertexIndex;
            final v1 = face[1].vertexIndex;
            final v2 = face[2].vertexIndex;
            final v3 = getMidPoint(v0, v1);
            final v4 = getMidPoint(v1, v2);
            final v5 = getMidPoint(v2, v0);
            faces_.addAll(
              <MeshFace>[
                <MeshVertex>[MeshVertex(v0), MeshVertex(v3), MeshVertex(v5)],
                <MeshVertex>[MeshVertex(v1), MeshVertex(v4), MeshVertex(v3)],
                <MeshVertex>[MeshVertex(v2), MeshVertex(v5), MeshVertex(v4)],
                <MeshVertex>[MeshVertex(v3), MeshVertex(v4), MeshVertex(v5)],
              ],
            );
            break;
          case 4:
            // v0 v7 v3
            // v4 v8 v6
            // v1 v5 v2
            final v0 = face[0].vertexIndex;
            final v1 = face[1].vertexIndex;
            final v2 = face[2].vertexIndex;
            final v3 = face[3].vertexIndex;
            final v4 = getMidPoint(v0, v1);
            final v5 = getMidPoint(v1, v2);
            final v6 = getMidPoint(v2, v3);
            final v7 = getMidPoint(v3, v0);
            final v8 = getMidPoint(v4, v6);
            faces_.addAll(
              <MeshFace>[
                <MeshVertex>[MeshVertex(v0), MeshVertex(v4), MeshVertex(v8), MeshVertex(v7)],
                <MeshVertex>[MeshVertex(v1), MeshVertex(v5), MeshVertex(v8), MeshVertex(v4)],
                <MeshVertex>[MeshVertex(v2), MeshVertex(v6), MeshVertex(v8), MeshVertex(v5)],
                <MeshVertex>[MeshVertex(v3), MeshVertex(v7), MeshVertex(v8), MeshVertex(v6)],
              ],
            );
            break;
          default:
            //todo:
            assert(false);
        }
      }
      faceGroups_.add(faceGroup.copyWith(faces: faces_));
    }

    return copyWith(
      vertices: vertices_,
      textureVertices: const <Vector3>[], //todo:
      normals: const <Vector3>[], //todo:
      faceGroups: faceGroups_,
    ).tessellated(level - 1);
  }

//<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeshObject &&
          runtimeType == other.runtimeType &&
          normals == other.normals &&
          textureVertices == other.textureVertices &&
          vertices == other.vertices &&
          faceGroups == other.faceGroups &&
          tag == other.tag);

  @override
  int get hashCode =>
      vertices.hashCode ^
      normals.hashCode ^
      textureVertices.hashCode ^
      faceGroups.hashCode ^
      tag.hashCode;

  @override
  String toString() {
    return 'MeshObject{ vertices: $vertices, '
        'normals: $normals, '
        'textureVertices: $textureVertices, '
        'faceGroups: $faceGroups}, '
        'tag: $tag}';
  }

  MeshObject copyWith({
    List<Vector3>? vertices,
    List<Vector3>? normals,
    List<Vector3>? textureVertices,
    List<MeshFaceGroup>? faceGroups,
    String? tag,
  }) {
    return MeshObject(
      vertices: vertices ?? this.vertices,
      normals: normals ?? this.normals,
      textureVertices: textureVertices ?? this.textureVertices,
      faceGroups: faceGroups ?? this.faceGroups,
      tag: tag ?? this.tag,
    );
  }

//</editor-fold>
}

/// メッシュデータ
///
/// immutableにできないか？
typedef MeshData = List<MeshObject>;

class MeshDataHelper {
  static MeshData fromWavefrontObj(String data) => WavefrontObjReader.fromWavefrontObj(data);
}

extension MeshObjectIterableHelper on Iterable<MeshObject> {
  MeshData transformed(Matrix4 matrix) => map((it) => it.transformed(matrix)).toList();
  MeshData mirrored() => map((it) => it.mirrored()).toList();
  MeshData reversed() => map((it) => it.reversed()).toList();
  MeshData tessellated([int level = 0]) => map((it) => it.tessellated(level)).toList();

  MeshData tagged(String tag) {
    assert(length == 1);
    return <MeshObject>[first.copyWith(tag: tag)];
  }
}

//
// メッシュ
//

/// メッシュビルダの基底クラス
@immutable
abstract class MeshBuilder {
  const MeshBuilder();
  MeshData build();
}

/// 単一のメッシュオブジェクトからなるメッシュデータを生成するメッシュビルダの基底クラス
@immutable
abstract class PrimitiveBuilder extends MeshBuilder {
  final String materialLibrary;
  final String material;
  final bool smooth;
  final bool reverse;

  const PrimitiveBuilder({
    this.materialLibrary = '',
    this.material = '',
    this.smooth = true,
    this.reverse = false,
  });

  MeshObject makeObject();

  @override
  MeshData build() {
    final object = makeObject();
    final faceGroups = [
      ...object.faceGroups.map(
        (it) => it
            .copyWith(
              materialLibrary: materialLibrary,
              material: material,
              smooth: smooth,
            )
            .let((it) => reverse ? it.reversed() : it),
      ),
    ];
    return <MeshObject>[
      object.copyWith(faceGroups: faceGroups),
    ];
  }
}

/// メッシュモディファイアの基底クラス
@immutable
abstract class MeshModifier {
  static const MeshModifier invalid = _InvalidModifier();

  const MeshModifier();

  MeshData transform({
    required Mesh mesh,
    required MeshData data,
    required Node root,
  });
}

/// 無効値
@immutable
class _InvalidModifier extends MeshModifier {
  const _InvalidModifier();
  @override
  MeshData transform({required Mesh mesh, required MeshData data, required Node root}) {
    throw UnimplementedError();
  }
}

/// メッシュ
///
/// リグ上にメッシュデータを配置する。
/// [modifier]と[modifiers]はどちらか一方しか指定できない。
@immutable
class Mesh {
  // ignore: unused_field
  static final _logger = Logger('Mesh');

  final dynamic data;
  final String origin;
  final MeshModifier modifier;
  final List<MeshModifier> modifiers;

  const Mesh({
    required this.data,
    required this.origin,
    this.modifier = MeshModifier.invalid,
    this.modifiers = const <MeshModifier>[],
  }) : assert(data is MeshObject || data is MeshData || data is MeshBuilder);

  MeshData toMeshData({required final Node root}) {
    // メッシュデータ生成
    MeshData data_;
    if (data is MeshObject) {
      data_ = [data as MeshObject];
    } else if (data is MeshData) {
      data_ = data as MeshData;
    } else if (data is MeshBuilder) {
      data_ = (data as MeshBuilder).build();
    } else {
      throw UnimplementedError();
    }
    // 変形
    if (modifier != MeshModifier.invalid) {
      assert(modifiers.isEmpty);
      data_ = modifier.transform(mesh: this, data: data_, root: root);
    } else if (modifiers.isNotEmpty) {
      assert(modifier == MeshModifier.invalid);
      for (final modifier_ in modifiers) {
        assert(modifier_ != MeshModifier.invalid);
        data_ = modifier_.transform(mesh: this, data: data_, root: root);
      }
    }
    // root座標に変換
    return data_.transformed(root.find(path: origin)!.matrix);
  }
}
