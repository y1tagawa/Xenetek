// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

//
// 3D stick figure representation
//

import 'package:vector_math/vector_math.dart';

class Node {
  final Vector3 position;
  final Matrix3 rotation;
  final Map<String, Node> children;

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

  /// [path]に対応する子ノード、またはそのプロパティを入れ替えたコピーを返す。
  Node modified({
    required Iterable<String> path,
    Vector3? position,
    Matrix3? rotation,
    Map<String, Node>? children,
  }) {
    if (path.isEmpty) {
      return copyWith(
        position: position,
        rotation: rotation,
        children: children,
      );
    }

    if (!this.children.containsKey(path.first)) {
      throw Exception();
    }

    final children_ = <String, Node>{};
    for (final key in this.children.keys) {
      final child = this.children[key]!;
      if (path.first == key) {
        children_[key] = modified(
          path: path.skip(1),
          position: position,
          rotation: rotation,
          children: children,
        );
      }
      // さもなくばそのまま残す。
      children_[key] = child;
    }
    return copyWith(children: children_);
  }

  Node added({
    required Iterable<String> path,
    required String key,
    required Node child,
  }) {
    final node = find(path: path);
    if (node == null) {
      throw Exception(); // TODO:
    }
    if (node.children.containsKey(key)) {
      throw Exception(); // TODO:
    }
    final children_ = {...node.children};
    children_[key] = child;
    return modified(path: path, children: children_);
  }

  Node removed({
    required Iterable<String> path,
    required String key,
  }) {
    final node = find(path: path);
    if (node == null) {
      throw Exception(); // TODO:
    }
    final children_ = {...node.children};
    children_.remove(key);
    return modified(path: path, children: children_);
  }

  // todo: rotated, positioned
//<editor-fold desc="Data Methods">

  const Node({
    required this.position,
    required this.rotation,
    required this.children,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Node &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          rotation == other.rotation &&
          children == other.children);

  @override
  int get hashCode => position.hashCode ^ rotation.hashCode ^ children.hashCode;

  @override
  String toString() {
    return 'Node{' +
        ' position: $position,' +
        ' rotation: $rotation,' +
        ' children: $children,' +
        '}';
  }

  Node copyWith({
    Vector3? position,
    Matrix3? rotation,
    Map<String, Node>? children,
  }) {
    return Node(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'position': this.position,
      'rotation': this.rotation,
      'children': this.children,
    };
  }

  factory Node.fromMap(Map<String, dynamic> map) {
    return Node(
      position: map['position'] as Vector3,
      rotation: map['rotation'] as Matrix3,
      children: map['children'] as Map<String, Node>,
    );
  }

//</editor-fold>
}
