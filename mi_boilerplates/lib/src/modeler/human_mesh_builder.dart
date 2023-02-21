import 'package:logging/logging.dart';

import 'basic.dart';
import 'human_rig.dart';
import 'mesh_builder.dart';
import 'mesh_modifier.dart';

// スクリプト的モデラ
//
// ドール(mk1)リグ用メッシュビルダ。

/// ピン
MeshData _pin({
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
  ).toMeshData(root: root);
}

MeshData _limb({
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
  ).toMeshData(root: root);
}

MeshData _mesh({
  required Node root,
  required String origin,
  required MeshData data,
}) {
  return Mesh(
    origin: origin,
    data: data,
  ).toMeshData(root: root);
}

MeshData _chest({
  required HumanRig rig,
  required Node root,
  required Node initRoot,
  required String origin,
  required String target,
}) {
  return Mesh(
    data: CubeBuilder(
      min: Vector3(-rig.shoulderPosition.x * 0.8, 0, rig.scPosition.z),
      max: Vector3(rig.shoulderPosition.x * 0.8, rig.chestLength, -rig.scPosition.z * 0.5),
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
        referencePosition: initRoot,
      ),
    ],
  ).toMeshData(root: root);
}

MeshData _belly({
  required HumanRig rig,
  required Node root,
  required Node initRoot,
  required String origin,
}) {
  return Mesh(
    data: CubeBuilder(
      min: Vector3(-rig.coxaPosition.x * 1.5, 0, rig.scPosition.z),
      max: Vector3(rig.coxaPosition.x * 1.5, rig.bellyLength, -rig.scPosition.z * 0.5),
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
      referencePosition: initRoot,
    ),
  ).toMeshData(root: root);
}

//

/// ドール(mk1)リグに合わせてメッシュを配置する。
class HumanMeshBuilder extends MeshBuilder {
  // ignore: unused_field
  static final _logger = Logger('HumanMeshBuilder');

  final HumanRig rigBuilder;
  final Node referencePosition;
  final Node root;
  final MeshData? headMesh; // 頭
  final MeshData? footMesh; // 右足

  const HumanMeshBuilder({
    required this.rigBuilder,
    required this.referencePosition,
    required this.root,
    this.headMesh,
    this.footMesh,
  });

  // メッシュデータ生成
  @override
  MeshData build() {
    final buffer = <String, MeshData>{};
    // 胴体・頭
    buffer['belly'] = _belly(
      rig: rigBuilder,
      root: root,
      initRoot: referencePosition,
      origin: HumanRig.pelvis,
    );
    buffer['chest'] = _chest(
      rig: rigBuilder,
      root: root,
      initRoot: referencePosition,
      origin: HumanRig.chest,
      target: HumanRig.neck,
    );
    buffer['neck'] = _limb(
      root: root,
      origin: HumanRig.neck,
      target: HumanRig.head,
      beginRadius: rigBuilder.neckRadius,
      endRadius: rigBuilder.neckRadius,
      heightDivision: 4,
    );
    if (headMesh != null) {
      buffer['head'] = _mesh(root: root, origin: HumanRig.head, data: headMesh!);
    }
    // 右下肢
    buffer['rThigh'] = _limb(
      root: root,
      origin: HumanRig.rCoxa,
      target: HumanRig.rKnee,
      beginRadius: rigBuilder.coxaRadius,
      endRadius: rigBuilder.kneeRadius,
    );
    buffer['rShank'] = _limb(
      root: root,
      origin: HumanRig.rKnee,
      target: HumanRig.rAnkle,
      beginRadius: rigBuilder.kneeRadius,
      endRadius: rigBuilder.ankleRadius,
    );
    if (footMesh != null) {
      buffer['rFoot'] = _mesh(root: root, origin: HumanRig.rAnkle, data: footMesh!);
    }
    // 左下肢
    buffer['lThigh'] = _limb(
      root: root,
      origin: HumanRig.lCoxa,
      target: HumanRig.lKnee,
      beginRadius: rigBuilder.coxaRadius,
      endRadius: rigBuilder.kneeRadius,
    );
    buffer['lShank'] = _limb(
      root: root,
      origin: HumanRig.lKnee,
      target: HumanRig.lAnkle,
      beginRadius: rigBuilder.kneeRadius,
      endRadius: rigBuilder.ankleRadius,
    );
    if (footMesh != null) {
      buffer['lFoot'] = _mesh(root: root, origin: HumanRig.lAnkle, data: footMesh!.mirrored());
    }
    // 右上肢
    buffer['rCollarBone'] = _pin(root: root, origin: HumanRig.rSc, target: HumanRig.rShoulder);
    buffer['rUpperArm'] = _limb(
      root: root,
      origin: HumanRig.rShoulder,
      target: HumanRig.rElbow,
      beginRadius: rigBuilder.shoulderRadius,
      endRadius: rigBuilder.elbowRadius,
    );
    buffer['rForeArm'] = _limb(
      root: root,
      origin: HumanRig.rElbow,
      target: HumanRig.rWrist,
      beginRadius: rigBuilder.elbowRadius,
      endRadius: rigBuilder.wristRadius,
    );
    // 左上肢
    buffer['lCollarBone'] = _pin(root: root, origin: HumanRig.lSc, target: HumanRig.lShoulder);
    buffer['lUpperArm'] = _limb(
      root: root,
      origin: HumanRig.lShoulder,
      target: HumanRig.lElbow,
      beginRadius: rigBuilder.shoulderRadius,
      endRadius: rigBuilder.elbowRadius,
    );
    buffer['lForeArm'] = _limb(
      root: root,
      origin: HumanRig.lElbow,
      target: HumanRig.lWrist,
      beginRadius: rigBuilder.elbowRadius,
      endRadius: rigBuilder.wristRadius,
    );
    return buffer.values.joinMeshData();
  }
}
