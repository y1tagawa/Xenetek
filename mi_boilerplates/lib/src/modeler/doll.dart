// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'basic.dart';
import 'mesh_builder.dart';
import 'mesh_modifier.dart';

// スクリプト的モデラ
//
// ドール(mk1)

extension _NodeHelper on Node {
  Node _rotateX(String path, double radians) => transform(
        path: path,
        matrix: Matrix4.fromAxisAngleRotation(
          axis: Vector3.unitX,
          radians: radians,
        ),
      );
}

/// ドールモデル(mk1)を生成する。
///
/// カスタマイズの基底クラス。
/// todo: copyWithなど
class HumanRig {
  // ignore: unused_field
  static final _logger = Logger('DollBuilder');

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

  // 骨格
  final Vector3 pelvisPosition; // rootから仙骨への相対位置
  final double bellyLength; // 腹部の長さ
  final double chestLength; // 胸郭の長さ
  final double neckLength; // 頸部の長さ
  // 右上肢（左は反転）
  final Vector3 scPosition; // 首の根から胸鎖関節の相対位置（胸の厚さ）
  final Vector3 shoulderPosition; // 胸鎖関節から右肩関節の相対位置（肩幅）
  final double upperArmLength; // 上腕の長さ
  final double foreArmLength; // 前腕の長さ
  // 右下肢（左は反転）
  final Vector3 coxaPosition; // 仙骨から右股関節への相対位置
  final double thighLength; // 大腿長
  final double shankLength; // 下腿長
  // ゼロポジション
  final double bellyAngle; // 腹部の傾き
  final double chestAngle; // 胸部の傾き
  final double neckAngle; // 頸部の傾き
  final double thighAngle; // 大腿の傾き
  final double footAngle; // 足首の傾き
  // 頸の太さ
  final double neckRadius;
  // 上肢の太さ
  final double shoulderRadius;
  final double elbowRadius;
  final double wristRadius;
  // 下肢の太さ
  final double coxaRadius;
  final double kneeRadius;
  final double ankleRadius;
  // メッシュ
  final MeshData? headMesh; // 頭
  final MeshData? footMesh; // 右足

  // TODO: 適当な初期値を適正に
  // https://www.airc.aist.go.jp/dhrt/91-92/data/search2.html
  const HumanRig({
    // 骨格
    this.pelvisPosition = Vector3.zero,
    this.bellyLength = 0.3,
    this.chestLength = 0.5,
    this.neckLength = 0.2,
    this.scPosition = const Vector3(0.0, -0.02, -0.15),
    this.shoulderPosition = const Vector3(0.25, 0.02, 0.15),
    this.upperArmLength = 0.4,
    this.foreArmLength = 0.5,
    this.coxaPosition = const Vector3(0.13, 0.0, -0.05),
    this.thighLength = 0.6,
    this.shankLength = 0.7,
    this.bellyAngle = -10.0 * math.pi / 180.0,
    this.chestAngle = 20.0 * math.pi / 180.0,
    this.neckAngle = -10.0 * math.pi / 180.0,
    this.thighAngle = 5.0 * math.pi / 180.0,
    this.footAngle = 5.0 * math.pi / 180.0,
    //
    this.neckRadius = 0.06,
    this.shoulderRadius = 0.08,
    this.elbowRadius = 0.08,
    this.wristRadius = 0.06,
    this.coxaRadius = 0.1,
    this.kneeRadius = 0.1,
    this.ankleRadius = 0.08,
    //
    this.headMesh,
    this.footMesh,
  });

  /// リグ生成
  Node build() {
    Node root = const Node()
        // 脊柱
        .addLimb(
          joints: <String, Matrix4>{
            'pelvis': Matrix4.fromTranslation(pelvisPosition),
            'chest': Matrix4.fromTranslation(Vector3.unitY * bellyLength),
            'neck': Matrix4.fromTranslation(Vector3.unitY * chestLength),
            'head': Matrix4.fromTranslation(Vector3.unitY * neckLength),
          }.entries,
        )
        // 右下肢
        .addLimb(
          path: 'pelvis',
          joints: <String, Matrix4>{
            'rCoxa': Matrix4.fromTranslation(coxaPosition),
            'knee': Matrix4.fromTranslation(Vector3.unitY * -thighLength),
            'ankle': Matrix4.fromTranslation(Vector3.unitY * -shankLength),
          }.entries,
        )
        // 左下肢
        .addLimb(
          path: 'pelvis',
          joints: <String, Matrix4>{
            'lCoxa': Matrix4.fromTranslation(coxaPosition.mirrored()),
            'knee': Matrix4.fromTranslation(Vector3.unitY * -thighLength),
            'ankle': Matrix4.fromTranslation(Vector3.unitY * -shankLength),
          }.entries,
        )
        // 右上肢
        .addLimb(
          path: 'pelvis.chest.neck',
          joints: <String, Matrix4>{
            'rSc': Matrix4.fromTranslation(scPosition),
            'shoulder': Matrix4.fromTranslation(shoulderPosition),
            'elbow': Matrix4.fromTranslation(Vector3.unitX * upperArmLength),
            'wrist': Matrix4.fromTranslation(Vector3.unitX * foreArmLength),
          }.entries,
        )
        // 左上肢
        .addLimb(
          path: 'pelvis.chest.neck',
          joints: <String, Matrix4>{
            'lSc': Matrix4.fromTranslation(scPosition.mirrored()),
            'shoulder': Matrix4.fromTranslation(shoulderPosition.mirrored()),
            'elbow': Matrix4.fromTranslation(Vector3.unitX * -upperArmLength),
            'wrist': Matrix4.fromTranslation(Vector3.unitX * -foreArmLength),
          }.entries,
        )
        // ゼロポジション
        ._rotateX(pelvis, bellyAngle)
        ._rotateX(chest, chestAngle)
        ._rotateX(neck, neckAngle)
        ._rotateX(rCoxa, thighAngle)
        ._rotateX(rAnkle, footAngle)
        ._rotateX(lCoxa, thighAngle)
        ._rotateX(lAnkle, footAngle);
    return root;
  }

  // メッシュデータ

  @protected
  MeshData makePin({
    required Node root,
    required String origin,
    required String target,
  }) {
    return Mesh(
      origin: origin,
      modifier: LookAtModifier(
        target: target,
        connect: true,
        proportional: true,
      ),
      // todo: scale
    ).toMeshData(root: root);
  }

  @protected
  MeshData makeTube({
    required Node root,
    required String origin,
    required String target,
    required double beginRadius,
    required double endRadius,
    int heightDivision = 1,
  }) {
    return Mesh(
      data: TubeBuilder(
        beginRadius: beginRadius,
        endRadius: endRadius,
        heightDivision: heightDivision,
        beginShape: const DomeEnd(),
        endShape: const DomeEnd(),
      ),
      origin: origin,
      modifier: LookAtModifier(
        target: target,
        connect: true,
      ),
      // todo: scale
    ).toMeshData(root: root);
  }

  @protected
  MeshData makeBox({
    required Node root,
    required Node initRoot,
    required String origin,
    required String target,
  }) {
    return Mesh(
      data: BoxBuilder(
        beginRect: math.Rectangle<double>(
          -shoulderPosition.x * 0.8,
          scPosition.z,
          shoulderPosition.x * 1.6,
          -scPosition.z,
        ),
        height: chestLength,
        widthDivision: 4,
        heightDivision: 4,
        depthDivision: 4,
      ),
      origin: origin,
      // modifier: LookAtModifier(
      //   target: target,
      //   connect: true,
      // ),
      modifier: SkinModifier(
        bones: {
          chest: const BoneData(),
          neck: const BoneData(),
        }.entries.toList(),
        initRoot: initRoot,
      ),
    ).toMeshData(root: root);
  }

  @protected
  MeshData makeMesh({
    required Node root,
    required String origin,
    String target = '',
    required MeshData data,
  }) {
    return Mesh(
      origin: origin,
      data: data,
    ).toMeshData(root: root);
  }

  // メッシュデータ生成
  // todo: extensionへ

  Map<String, MeshData> toMeshData({
    required final Node root,
    Node? initRoot, // 初期姿勢
  }) {
    initRoot = initRoot ?? root;

    final buffer = <String, MeshData>{};
    // 胴体・頭
    buffer['waist'] = makePin(root: root, origin: pelvis, target: chest);
    //buffer['chest'] = makePin(root: root, origin: chest, target: neck);
    buffer['chest'] = makeBox(
      root: root,
      initRoot: initRoot,
      origin: chest,
      target: neck,
    );
    buffer['neck'] = makeTube(
      root: root,
      origin: neck,
      target: head,
      beginRadius: neckRadius,
      endRadius: neckRadius,
      heightDivision: 4,
    );
    if (headMesh != null) {
      buffer['head'] = makeMesh(root: root, origin: head, data: headMesh!);
    }
    // 右下肢
    buffer['rThigh'] = makeTube(
      root: root,
      origin: rCoxa,
      target: rKnee,
      beginRadius: coxaRadius,
      endRadius: kneeRadius,
    );
    buffer['rShank'] = makeTube(
      root: root,
      origin: rKnee,
      target: rAnkle,
      beginRadius: kneeRadius,
      endRadius: ankleRadius,
    );
    if (footMesh != null) {
      buffer['rFoot'] = makeMesh(root: root, origin: rAnkle, data: footMesh!);
    }
    // 左下肢
    buffer['lThigh'] = makeTube(
      root: root,
      origin: lCoxa,
      target: lKnee,
      beginRadius: coxaRadius,
      endRadius: kneeRadius,
    );
    buffer['lShank'] = makeTube(
      root: root,
      origin: lKnee,
      target: lAnkle,
      beginRadius: kneeRadius,
      endRadius: ankleRadius,
    );
    if (footMesh != null) {
      buffer['lFoot'] = makeMesh(root: root, origin: lAnkle, data: footMesh!.mirrored());
    }
    // 右上肢
    buffer['rCollarBone'] = makePin(root: root, origin: rSc, target: rShoulder);
    buffer['rUpperArm'] = makeTube(
      root: root,
      origin: rShoulder,
      target: rElbow,
      beginRadius: shoulderRadius,
      endRadius: elbowRadius,
    );
    buffer['rForeArm'] = makeTube(
      root: root,
      origin: rElbow,
      target: rWrist,
      beginRadius: elbowRadius,
      endRadius: wristRadius,
    );
    // 左上肢
    buffer['lCollarBone'] = makePin(root: root, origin: lSc, target: lShoulder);
    buffer['lUpperArm'] = makeTube(
      root: root,
      origin: lShoulder,
      target: lElbow,
      beginRadius: shoulderRadius,
      endRadius: elbowRadius,
    );
    buffer['lForeArm'] = makeTube(
      root: root,
      origin: lElbow,
      target: lWrist,
      beginRadius: elbowRadius,
      endRadius: wristRadius,
    );
    return buffer;
  }
}
