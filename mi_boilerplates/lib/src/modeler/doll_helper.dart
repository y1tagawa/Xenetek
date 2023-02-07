import './basic.dart';
import './doll.dart';

// スクリプト的ドール(mk1)モデラ拡張

extension NodeHelper on Node {
// ポージング

  Node _rotate(String path, Vector3 axis, double? radians, double? degrees) => transform(
        path: Doll.rShoulder,
        matrix: Matrix4.fromAxisAngleRotation(
          axis: -Vector3.unitZ,
          radians: radians,
          degrees: degrees,
        ),
      );

  Node bendRShoulder({double? radians, double? degrees}) =>
      _rotate(Doll.rShoulder, -Vector3.unitZ, radians, degrees);

  Node bendLShoulder({double? radians, double? degrees}) =>
      _rotate(Doll.lShoulder, Vector3.unitZ, radians, degrees);

  Node bendRElbow({double? radians, double? degrees}) =>
      _rotate(Doll.rElbow, Vector3.unitY, radians, degrees);

  Node bendLElbow({double? radians, double? degrees}) =>
      _rotate(Doll.lElbow, -Vector3.unitY, radians, degrees);
}
