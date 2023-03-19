import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

import 'basic.dart';
import 'human_rig_builder.dart';
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
    data: const [pinMeshObject],
    modifier: LookAtModifier(
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
    modifier: LookAtModifier(
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
  required HumanRigBuilder rig,
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
          HumanRigBuilder.chest: const BoneData(),
          HumanRigBuilder.rSc: const BoneData(),
          HumanRigBuilder.lSc: const BoneData(),
        }.entries.toList(),
        referencePosition: initRoot,
      ),
    ],
  ).toMeshData(root: root);
}

MeshData _belly({
  required HumanRigBuilder rig,
  required Node root,
  required Node initRoot,
  required String origin,
}) {
  return Mesh(
    data: CubeBuilder(
      min: Vector3(-rig.coxaPosition.x * 1.5, 0, rig.scPosition.z),
      max: Vector3(rig.coxaPosition.x * 1.5, rig.bellyLength, -rig.scPosition.z * 0.5),
      tessellationLevel: 3,
      materialLibrary: 'x11.mtl',
      material: 'cornflowerBlue',
    ),
    origin: origin,
    modifier: SkinModifier(
      bones: {
        HumanRigBuilder.pelvis: const BoneData(),
        HumanRigBuilder.chest: const BoneData(),
        HumanRigBuilder.rCoxa: const BoneData(),
        HumanRigBuilder.lCoxa: const BoneData(),
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

  final HumanRigBuilder rigBuilder;
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
      origin: HumanRigBuilder.pelvis,
    );
    buffer['chest'] = _chest(
      rig: rigBuilder,
      root: root,
      initRoot: referencePosition,
      origin: HumanRigBuilder.chest,
      target: HumanRigBuilder.neck,
    );
    buffer['neck'] = _limb(
      root: root,
      origin: HumanRigBuilder.neck,
      target: HumanRigBuilder.head,
      beginRadius: rigBuilder.neckRadius,
      endRadius: rigBuilder.neckRadius,
      heightDivision: 4,
    );
    if (headMesh != null) {
      buffer['head'] = _mesh(root: root, origin: HumanRigBuilder.head, data: headMesh!);
    }
    // 右下肢
    buffer['rThigh'] = _limb(
      root: root,
      origin: HumanRigBuilder.rCoxa,
      target: HumanRigBuilder.rKnee,
      beginRadius: rigBuilder.coxaRadius,
      endRadius: rigBuilder.kneeRadius,
    );
    buffer['rShank'] = _limb(
      root: root,
      origin: HumanRigBuilder.rKnee,
      target: HumanRigBuilder.rAnkle,
      beginRadius: rigBuilder.kneeRadius,
      endRadius: rigBuilder.ankleRadius,
    );
    if (footMesh != null) {
      buffer['rFoot'] = _mesh(root: root, origin: HumanRigBuilder.rAnkle, data: footMesh!);
    }
    // 左下肢
    buffer['lThigh'] = _limb(
      root: root,
      origin: HumanRigBuilder.lCoxa,
      target: HumanRigBuilder.lKnee,
      beginRadius: rigBuilder.coxaRadius,
      endRadius: rigBuilder.kneeRadius,
    );
    buffer['lShank'] = _limb(
      root: root,
      origin: HumanRigBuilder.lKnee,
      target: HumanRigBuilder.lAnkle,
      beginRadius: rigBuilder.kneeRadius,
      endRadius: rigBuilder.ankleRadius,
    );
    if (footMesh != null) {
      buffer['lFoot'] =
          _mesh(root: root, origin: HumanRigBuilder.lAnkle, data: footMesh!.mirrored());
    }
    // 右上肢
    buffer['rCollarBone'] =
        _pin(root: root, origin: HumanRigBuilder.rSc, target: HumanRigBuilder.rShoulder);
    buffer['rUpperArm'] = _limb(
      root: root,
      origin: HumanRigBuilder.rShoulder,
      target: HumanRigBuilder.rElbow,
      beginRadius: rigBuilder.shoulderRadius,
      endRadius: rigBuilder.elbowRadius,
    );
    buffer['rForeArm'] = _limb(
      root: root,
      origin: HumanRigBuilder.rElbow,
      target: HumanRigBuilder.rWrist,
      beginRadius: rigBuilder.elbowRadius,
      endRadius: rigBuilder.wristRadius,
    );
    // 左上肢
    buffer['lCollarBone'] =
        _pin(root: root, origin: HumanRigBuilder.lSc, target: HumanRigBuilder.lShoulder);
    buffer['lUpperArm'] = _limb(
      root: root,
      origin: HumanRigBuilder.lShoulder,
      target: HumanRigBuilder.lElbow,
      beginRadius: rigBuilder.shoulderRadius,
      endRadius: rigBuilder.elbowRadius,
    );
    buffer['lForeArm'] = _limb(
      root: root,
      origin: HumanRigBuilder.lElbow,
      target: HumanRigBuilder.lWrist,
      beginRadius: rigBuilder.elbowRadius,
      endRadius: rigBuilder.wristRadius,
    );
    return buffer.entries.map((it) => it.value.tagged(it.key)).flattened.toList();
  }
}
