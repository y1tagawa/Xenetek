// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../mi_boilerplates.dart';

// スクリプト的ドールモデラ

/// ドールモデル(mk1)のリグを生成する。
///
/// カスタマイズの基底クラス。
/// todo: copyWithなど
class DollRigBuilder {
  final Vector3 pelvis; // rootから腰椎底の相対位置
  final double chest; // 胸椎底（腰椎の長さ）
  final double neck; // 頸椎底（胸椎の長さ）
  final double head; // 頭蓋底（頸椎の長さ）
  final double collar; // 胸鎖関節のZ位置（胸の厚さ）
  final double shoulder; // 右肩関節のX位置（肩幅）
  // 右上肢
  final double elbow; // 上腕長
  final double wrist; // 前腕長
  // 右下肢
  final double hip; // 腰幅
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
    this.collar = -0.2,
    this.shoulder = 0.25,
    this.elbow = 0.4,
    this.wrist = 0.5,
    this.hip = 0.1,
    this.knee = 0.6,
    this.ankle = 0.7,
  });

  @protected

  /// 脊柱生成
  Node addSpine(Node root) {
    return root.addLimb(
      joints: <String, Matrix4>{
        'pelvis': Matrix4.fromTranslation(pelvis),
        'chest': Matrix4.fromTranslation(Vector3.unitY * chest),
        'neck': Matrix4.fromTranslation(Vector3.unitY * neck),
        'head': Matrix4.fromTranslation(Vector3.unitY * head),
      }.entries,
    );
  }

  /// 左下肢生成
  @protected
  Node addRLeg(Node root) {
    return root.addLimb(
      path: 'pelvis',
      joints: <String, Matrix4>{
        'rHip': Matrix4.fromTranslation(Vector3(hip, 0.0, 0.0)),
        'knee': Matrix4.fromTranslation(Vector3.unitY * -knee),
        'ankle': Matrix4.fromTranslation(Vector3.unitY * -ankle),
      }.entries,
    );
  }

  /// 左下肢生成
  @protected
  Node addLLeg(Node root) {
    return root.addLimb(
      path: 'pelvis',
      joints: <String, Matrix4>{
        'lHip': Matrix4.fromTranslation(Vector3(-hip, 0.0, 0.0)),
        'knee': Matrix4.fromTranslation(Vector3.unitY * -knee),
        'ankle': Matrix4.fromTranslation(Vector3.unitY * -ankle),
      }.entries,
    );
  }

  /// 右上肢生成
  @protected
  Node addRArm(Node root) {
    return root.addLimb(
      path: 'pelvis.chest.neck',
      joints: <String, Matrix4>{
        'rSc': Matrix4.fromTranslation(Vector3(0.0, 0.0, collar)),
        'shoulder': Matrix4.fromTranslation(Vector3(shoulder, 0.0, -collar)),
        'elbow': Matrix4.fromTranslation(Vector3.unitX * elbow),
        'wrist': Matrix4.fromTranslation(Vector3.unitX * wrist),
      }.entries,
    );
  }

  /// 左上肢生成
  @protected
  Node addLArm(Node root) {
    return root.addLimb(
      path: 'pelvis.chest.neck',
      joints: <String, Matrix4>{
        'lSc': Matrix4.fromTranslation(Vector3(0.0, 0.0, collar)),
        'shoulder': Matrix4.fromTranslation(Vector3(-shoulder, 0.0, -collar)),
        'elbow': Matrix4.fromTranslation(Vector3.unitX * -elbow),
        'wrist': Matrix4.fromTranslation(Vector3.unitX * -wrist),
      }.entries,
    );
  }

  /// リグ生成
  Node build() {
    Node root = const Node();
    root = addSpine(root);
    root = addRLeg(root);
    root = addLLeg(root);
    root = addRArm(root);
    root = addLArm(root);
    return root;
  }
}

/// ドールリグにメッシュを当てはめる
///
/// デフォルトはピンを置くだけ。カスタマイズの基底クラス。
class DollMeshBuilder {
  // ignore: unused_field
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
  final MeshData? headMesh;

  const DollMeshBuilder({
    required this.root,
    this.headMesh,
  });

  @protected
  List<MeshData> makePin({
    required String origin,
    required String target,
  }) {
    return Tube(
      origin: origin,
      target: target,
      beginRadius: 0.12,
      endRadius: 0.1,
      heightDivision: 8,
    ).toMeshData(root: root);
    // return Pin(
    //   origin: origin,
    //   target: target,
    //   scale: const Vector3(0.25, 1, 0.25),
    // ).toMeshData(root: root);
  }

  @protected
  List<MeshData> makeMesh({
    required String origin,
    String target = '',
    required MeshData data,
  }) {
    return Mesh(
      origin: origin,
      target: target,
      // 1x1x1の頭モデルの大きさ
      scale: const Vector3(0.3, 0.3, 0.3),
      data: data,
    ).toMeshData(root: root);
  }

  @protected
  Map<String, List<MeshData>> makeBody() {
    final buffer = <String, List<MeshData>>{};
    buffer['waist'] = makePin(origin: pelvis, target: chest);
    buffer['chest'] = makePin(origin: chest, target: neck);
    buffer['neck'] = makePin(origin: neck, target: head);
    if (headMesh != null) {
      buffer['head'] = makeMesh(origin: head, data: headMesh!);
    }
    return buffer;
  }

  @protected
  Map<String, List<MeshData>> makeRArm() {
    final buffer = <String, List<MeshData>>{};
    buffer['rCollar'] = makePin(origin: rSc, target: rShoulder);
    buffer['rUpperArm'] = makePin(origin: rShoulder, target: rElbow);
    buffer['rForeArm'] = makePin(origin: rElbow, target: rWrist);
    // todo: hand
    return buffer;
  }

  @protected
  Map<String, List<MeshData>> makeLArm() {
    final buffer = <String, List<MeshData>>{};
    buffer['lCollar'] = makePin(origin: lSc, target: lShoulder);
    buffer['lUpperArm'] = makePin(origin: lShoulder, target: lElbow);
    buffer['lForeArm'] = makePin(origin: lElbow, target: lWrist);
    // todo: hand
    return buffer;
  }

  @protected
  Map<String, List<MeshData>> makeRLeg() {
    final buffer = <String, List<MeshData>>{};
    buffer['rThigh'] = makePin(origin: rHip, target: rKnee);
    buffer['rShank'] = makePin(origin: rKnee, target: rAnkle);
    // todo: foot
    return buffer;
  }

  @protected
  Map<String, List<MeshData>> makeLLeg() {
    final buffer = <String, List<MeshData>>{};
    buffer['lThigh'] = makePin(origin: lHip, target: lKnee);
    buffer['lShank'] = makePin(origin: lKnee, target: lAnkle);
    // todo: foot
    return buffer;
  }

  Map<String, List<MeshData>> build() {
    final buffer = <String, List<MeshData>>{};
    buffer.addAll(makeBody());
    buffer.addAll(makeRArm());
    buffer.addAll(makeLArm());
    buffer.addAll(makeRLeg());
    buffer.addAll(makeLLeg());
    return buffer;
  }
}
