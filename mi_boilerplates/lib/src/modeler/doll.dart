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
  final Vector3 pelvisPosition; // rootから仙骨への相対位置
  final double bellyLength; // 腹部の長さ
  final double chestLength; // 胸郭の長さ
  final double neckLength; // 頸部の長さ
  final Vector3 scPosition; // 首の根から胸鎖関節の相対位置（胸の厚さ）
  final Vector3 shoulderPosition; // 胸鎖関節から右肩関節の相対位置（肩幅）
  // 右上肢
  final double upperArmLength; // 上腕の長さ
  final double foreArmLength; // 前腕の長さ
  // 右下肢
  final Vector3 coxaPosition; // 仙骨から右股関節への相対位置
  final double thighLength; // 大腿長
  final double shankLength; // 下腿長
  // 左は右の反転

  // TODO: 適当な初期値を適正に
  // https://www.airc.aist.go.jp/dhrt/91-92/data/search2.html
  const DollRigBuilder({
    this.pelvisPosition = Vector3.zero,
    this.bellyLength = 0.3,
    this.chestLength = 0.5,
    this.neckLength = 0.2,
    this.scPosition = const Vector3(0.0, 0.0, -0.2),
    this.shoulderPosition = const Vector3(0.0, 0.25, 0.2),
    this.upperArmLength = 0.4,
    this.foreArmLength = 0.5,
    this.coxaPosition = const Vector3(0.1, 0.0, 0.0),
    this.thighLength = 0.6,
    this.shankLength = 0.7,
  });

  @protected

  /// 脊柱生成
  Node addSpine(Node root) {
    return root.addLimb(
      joints: <String, Matrix4>{
        'pelvis': Matrix4.fromTranslation(pelvisPosition),
        'chest': Matrix4.fromTranslation(Vector3.unitY * bellyLength),
        'neck': Matrix4.fromTranslation(Vector3.unitY * chestLength),
        'head': Matrix4.fromTranslation(Vector3.unitY * neckLength),
      }.entries,
    );
  }

  /// 左下肢生成
  @protected
  Node addRLeg(Node root) {
    return root.addLimb(
      path: 'pelvis',
      joints: <String, Matrix4>{
        'rCoxa': Matrix4.fromTranslation(coxaPosition),
        'knee': Matrix4.fromTranslation(Vector3.unitY * -thighLength),
        'ankle': Matrix4.fromTranslation(Vector3.unitY * -shankLength),
      }.entries,
    );
  }

  /// 左下肢生成
  @protected
  Node addLLeg(Node root) {
    return root.addLimb(
      path: 'pelvis',
      joints: <String, Matrix4>{
        'lCoxa': Matrix4.fromTranslation(coxaPosition.mirrored()),
        'knee': Matrix4.fromTranslation(Vector3.unitY * -thighLength),
        'ankle': Matrix4.fromTranslation(Vector3.unitY * -shankLength),
      }.entries,
    );
  }

  /// 右上肢生成
  @protected
  Node addRArm(Node root) {
    return root.addLimb(
      path: 'pelvis.chest.neck',
      joints: <String, Matrix4>{
        'rSc': Matrix4.fromTranslation(scPosition),
        'shoulder': Matrix4.fromTranslation(shoulderPosition),
        'elbow': Matrix4.fromTranslation(Vector3.unitX * upperArmLength),
        'wrist': Matrix4.fromTranslation(Vector3.unitX * foreArmLength),
      }.entries,
    );
  }

  /// 左上肢生成
  @protected
  Node addLArm(Node root) {
    return root.addLimb(
      path: 'pelvis.chest.neck',
      joints: <String, Matrix4>{
        'lSc': Matrix4.fromTranslation(scPosition.mirrored()),
        'shoulder': Matrix4.fromTranslation(shoulderPosition.mirrored()),
        'elbow': Matrix4.fromTranslation(Vector3.unitX * -upperArmLength),
        'wrist': Matrix4.fromTranslation(Vector3.unitX * -foreArmLength),
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

/// ドールリグにメッシュを置く
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
  static const rCoxa = 'pelvis.rCoxa';
  static const lCoxa = 'pelvis.lCoxa';
  static const rKnee = 'pelvis.rCoxa.knee';
  static const lKnee = 'pelvis.lCoxa.knee';
  static const rAnkle = 'pelvis.rCoxa.knee.ankle';
  static const lAnkle = 'pelvis.lCoxa.knee.ankle';

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
    // return Tube(
    //   origin: origin,
    //   target: target,
    //   beginRadius: 0.12,
    //   endRadius: 0.1,
    //   heightDivision: 8,
    //   beginShape: const ConeEnd(height: 0.4, division: 8),
    //   endShape: const ConeEnd(height: 0.2, division: 3),
    // ).toMeshData(root: root);
    return Pin(
      origin: origin,
      target: target,
      scale: const Vector3(0.25, 1, 0.25),
    ).toMeshData(root: root);
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
    buffer['rThigh'] = makePin(origin: rCoxa, target: rKnee);
    buffer['rShank'] = makePin(origin: rKnee, target: rAnkle);
    // todo: foot
    return buffer;
  }

  @protected
  Map<String, List<MeshData>> makeLLeg() {
    final buffer = <String, List<MeshData>>{};
    buffer['lThigh'] = makePin(origin: lCoxa, target: lKnee);
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
