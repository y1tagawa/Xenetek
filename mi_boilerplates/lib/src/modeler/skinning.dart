import '../../mi_boilerplates.dart';

///
/// スキニング
///
/// Meshと合体しても良いかもだ

class Skin extends Shape {
  // 原型の原点
  final String origin;
  // 原型の図形
  final MeshData data;
  // 変形コントローラ(rootおよびbasePositionから存在する必要がある)
  final List<String> controllers;
  // 原型のroot
  final Node basePosition;

  const Skin({
    required this.origin,
    required this.data,
    required this.controllers,
    required this.basePosition,
  });

  /// [origin]に置いた[data]の各頂点を、
  /// 各[controllers]の[basePosition]と[root]からの相対位置の差に従って変形する。
  @override
  List<MeshData> toMeshData({required Node root}) {
    // TODO: implement toMeshData
    throw UnimplementedError();
  }
}
