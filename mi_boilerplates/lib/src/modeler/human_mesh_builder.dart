import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'basic.dart';
import 'human_rig.dart';
import 'mesh_builder.dart';
import 'mesh_modifier.dart';

// スクリプト的モデラ
//
// ドール(mk1)リグに合わせてメッシュを配置する。

class HumanMeshBuilder extends MeshBuilder {
  // ignore: unused_field
  static final _logger = Logger('HumanMeshBuilder');

  // 体格パラメタ
  final HumanRig rigBuilder;
  // 初期姿勢root
  final Node rRoot;
  final Node root;

  const HumanMeshBuilder({
    required this.rigBuilder,
    required this.rRoot,
    required this.root,
  });

  // メッシュデータ

  @protected
  MeshData makePin({
    required Node root,
    required String origin,
    required String target,
  }) {
    return Mesh(
      origin: origin,
      data: pinMeshData,
      modifiers: LookAtModifier(
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
      modifiers: LookAtModifier(
        target: target,
        connect: true,
        minSlice: 0.0,
        maxSlice: 1.0,
      ),
      // todo: scale
    ).toMeshData(root: root);
  }

  @protected
  MeshData makeChest({
    required Node root,
    required Node initRoot,
    required String origin,
    required String target,
  }) {
    return Mesh(
      data: CubeBuilder(
        min: Vector3(-rigBuilder.shoulderPosition.x * 0.8, 0, rigBuilder.scPosition.z),
        max: Vector3(rigBuilder.shoulderPosition.x * 0.8, rigBuilder.chestLength,
            -rigBuilder.scPosition.z * 0.5),
        tessellationLevel: 3,
      ),
      origin: origin,
      modifiers: [
        SkinModifier(
          bones: {
            HumanRig.chest: const BoneData(power: -8),
            HumanRig.rSc: const BoneData(power: -8),
            HumanRig.lSc: const BoneData(power: -8),
          }.entries.toList(),
          rRoot: initRoot,
        ),
        // MagnetModifier(
        //   magnets: <String, BoneData>{
        //     head: const BoneData(force: -1),
        //   }.entries.toList(),
        // ),
      ],
    ).toMeshData(root: root);
  }

  @protected
  MeshData makeBelly({
    required Node root,
    required Node initRoot,
    required String origin,
  }) {
    return Mesh(
      data: CubeBuilder(
        min: Vector3(-rigBuilder.coxaPosition.x * 1.5, 0, rigBuilder.scPosition.z),
        max: Vector3(rigBuilder.coxaPosition.x * 1.5, rigBuilder.bellyLength,
            -rigBuilder.scPosition.z * 0.5),
        tessellationLevel: 3,
      ),
      origin: origin,
      modifiers: SkinModifier(
        bones: {
          HumanRig.pelvis: const BoneData(power: -6),
          HumanRig.chest: const BoneData(power: -6),
          HumanRig.rCoxa: const BoneData(power: -6),
          HumanRig.lCoxa: const BoneData(power: -6),
        }.entries.toList(),
        rRoot: initRoot,
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
  @override
  MeshData build() {
    final buffer = <String, MeshData>{};
    // 胴体・頭
    //buffer['waist'] = makePin(root: root, origin: pelvis, target: chest);
    buffer['belly'] = makeBelly(
      root: root,
      initRoot: rRoot,
      origin: HumanRig.pelvis,
    );
    //buffer['chest'] = makePin(root: root, origin: chest, target: neck);
    buffer['chest'] = makeChest(
      root: root,
      initRoot: rRoot,
      origin: HumanRig.chest,
      target: HumanRig.neck,
    );
    buffer['neck'] = makeTube(
      root: root,
      origin: HumanRig.neck,
      target: HumanRig.head,
      beginRadius: rigBuilder.neckRadius,
      endRadius: rigBuilder.neckRadius,
      heightDivision: 4,
    );
    if (rigBuilder.headMesh != null) {
      buffer['head'] = makeMesh(root: root, origin: HumanRig.head, data: rigBuilder.headMesh!);
    }
    // 右下肢
    buffer['rThigh'] = makeTube(
      root: root,
      origin: HumanRig.rCoxa,
      target: HumanRig.rKnee,
      beginRadius: rigBuilder.coxaRadius,
      endRadius: rigBuilder.kneeRadius,
    );
    buffer['rShank'] = makeTube(
      root: root,
      origin: HumanRig.rKnee,
      target: HumanRig.rAnkle,
      beginRadius: rigBuilder.kneeRadius,
      endRadius: rigBuilder.ankleRadius,
    );
    if (rigBuilder.footMesh != null) {
      buffer['rFoot'] = makeMesh(root: root, origin: HumanRig.rAnkle, data: rigBuilder.footMesh!);
    }
    // 左下肢
    buffer['lThigh'] = makeTube(
      root: root,
      origin: HumanRig.lCoxa,
      target: HumanRig.lKnee,
      beginRadius: rigBuilder.coxaRadius,
      endRadius: rigBuilder.kneeRadius,
    );
    buffer['lShank'] = makeTube(
      root: root,
      origin: HumanRig.lKnee,
      target: HumanRig.lAnkle,
      beginRadius: rigBuilder.kneeRadius,
      endRadius: rigBuilder.ankleRadius,
    );
    if (rigBuilder.footMesh != null) {
      buffer['lFoot'] =
          makeMesh(root: root, origin: HumanRig.lAnkle, data: rigBuilder.footMesh!.mirrored());
    }
    // 右上肢
    buffer['rCollarBone'] = makePin(root: root, origin: HumanRig.rSc, target: HumanRig.rShoulder);
    buffer['rUpperArm'] = makeTube(
      root: root,
      origin: HumanRig.rShoulder,
      target: HumanRig.rElbow,
      beginRadius: rigBuilder.shoulderRadius,
      endRadius: rigBuilder.elbowRadius,
    );
    buffer['rForeArm'] = makeTube(
      root: root,
      origin: HumanRig.rElbow,
      target: HumanRig.rWrist,
      beginRadius: rigBuilder.elbowRadius,
      endRadius: rigBuilder.wristRadius,
    );
    // 左上肢
    buffer['lCollarBone'] = makePin(root: root, origin: HumanRig.lSc, target: HumanRig.lShoulder);
    buffer['lUpperArm'] = makeTube(
      root: root,
      origin: HumanRig.lShoulder,
      target: HumanRig.lElbow,
      beginRadius: rigBuilder.shoulderRadius,
      endRadius: rigBuilder.elbowRadius,
    );
    buffer['lForeArm'] = makeTube(
      root: root,
      origin: HumanRig.lElbow,
      target: HumanRig.lWrist,
      beginRadius: rigBuilder.elbowRadius,
      endRadius: rigBuilder.wristRadius,
    );
    return buffer.values.joinMeshData();
  }
}
