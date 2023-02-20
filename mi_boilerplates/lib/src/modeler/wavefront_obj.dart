// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:logging/logging.dart';

import '../scope_functions.dart';
import 'basic.dart';

extension MeshDataHelper on MeshData {
  // ignore: unused_field
  static final _logger = Logger('MeshDataHelper');

  /// 単純なWavefront .objリーダ
  static MeshData fromWavefrontObj(String data) {
    _logger.fine('[i] fromWavefrontObj');

    Vector3? tryGetVector3(String x, String y, String z) {
      final x_ = double.tryParse(x);
      final y_ = double.tryParse(y);
      final z_ = double.tryParse(z);
      if (x_ != null || y_ != null || z_ == null) {
        return Vector3(x_!, y_!, z_!);
      }
      return null;
    }

    final vertices = <Vector3>[];
    final normals = <Vector3>[];
    final faces = <MeshFace>[];
    final lines = data.split('\n');
    linesLoop:
    for (var line in lines) {
      line = line.split('#').let((it) => it.isNotEmpty ? it[0].trim() : '');
      if (line.isEmpty) {
        continue linesLoop;
      }
      final fields = line.split(' ').map((it) => it.trim()).toList();
      assert(fields.isNotEmpty);
      switch (fields[0]) {
        case 'v':
          if (fields.length == 4) {
            final vertex = tryGetVector3(fields[1], fields[2], fields[3]);
            if (vertex != null) {
              vertices.add(vertex);
              continue linesLoop;
            }
          }
          throw FormatException('vertex format error: $line');
        case 'vn':
          if (fields.length == 4) {
            final normal = tryGetVector3(fields[1], fields[2], fields[3]);
            if (normal != null) {
              normals.add(normal);
              continue linesLoop;
            }
          }
          throw FormatException('normal format error: $line');
        case 'f':
          {
            final vertices = <MeshVertex>[];
            for (final field in fields.skip(1)) {
              // 1～を0～に
              final vertexIndex = (int.tryParse(field) ?? 0) - 1;
              if (vertexIndex < 0 && vertexIndex >= vertices.length) {
                throw FormatException('vertex index error: $line');
              }
//todo: normal
              vertices.add(MeshVertex(vertexIndex, -1, -1));
            }
            if (vertices.length < 3) {
              throw FormatException('number of face vertices < 3: $line');
            }
            faces.add(vertices);
            continue linesLoop;
          }
        case 's': //todo
        case 'usemtl': // todo
        case 'mtllib': // todo
        case 'o':
        case 'g':
          continue linesLoop;
        default:
          throw FormatException('unimplemented format: $line');
      }
    }

    return MeshData(
      vertices: vertices,
      normals: normals,
      faceGroups: <MapEntry<String, MeshFaceGroup>>[
        MapEntry('', MeshFaceGroup(faces: faces)),
      ],
    ).also((it) {
      _logger.fine(
        '[o] fromWavefrontObj'
        ' ${vertices.length} vertices,'
        ' ${normals.length} normals,'
        ' ${faces.length} faces.',
      );
    });
  }

  //
  // Wavefront .obj出力
  //

  // 出力フォーマット
  static const _fractionDigits = 4;

  /// Wavefront .obj出力
  void toWavefrontObj(StringSink sink) {
    _logger.fine('[i] toWavefrontObj');
    _logger.fine('${vertices.length} vertices');
    _logger.fine('${textureVertices.length} texture vertices');
    _logger.fine('${normals.length} normals');
    _logger.fine('${faceGroups.length} face groups');
    _logger.fine('${faceGroups.fold(0, (value, it) => value + it.value.faces.length)} faces');

    // 使用されているmtllibを最初にまとめてインポートする
    final materialLibraries = <String>{};
    for (var it in faceGroups) {
      if (it.value.materialLibrary.isNotEmpty) {
        materialLibraries.add(it.value.materialLibrary);
      }
    }
    for (var it in materialLibraries) {
      sink.writeln('mtllib $it');
    }

    // 頂点
    for (final vertex in vertices) {
      sink.writeln(
        'v'
        ' ${vertex.x.toStringAsFixed(_fractionDigits)}'
        ' ${vertex.y.toStringAsFixed(_fractionDigits)}'
        ' ${vertex.z.toStringAsFixed(_fractionDigits)}',
      );
    }
    for (final textureVertex in textureVertices) {
      sink.writeln(
        'vt'
        ' ${textureVertex.x.toStringAsFixed(_fractionDigits)}'
        ' ${textureVertex.y.toStringAsFixed(_fractionDigits)}'
        ' ${textureVertex.z.toStringAsFixed(_fractionDigits)}',
      );
    }
    for (final normal in normals) {
      sink.writeln(
        'vn'
        ' ${normal.x.toStringAsFixed(_fractionDigits)}'
        ' ${normal.y.toStringAsFixed(_fractionDigits)}'
        ' ${normal.z.toStringAsFixed(_fractionDigits)}',
      );
    }
    // 面グループ
    for (final faceGroup in faceGroups) {
      sink.writeln('# ${faceGroup.key}');
      sink.writeln('s ${faceGroup.value.smooth ? 1 : 0}');
      sink.writeln('usemtl ${faceGroup.value.material}'); // マテリアルが空ならデフォルトに戻る
      // 面頂点
      for (final face in faceGroup.value.faces) {
        assert(face.length >= 3);
        sink.write('f');
        for (final vertex in face) {
          // 頂点インデックス
          assert(vertex.vertexIndex >= 0 && vertex.vertexIndex < vertices.length);
          sink.write(' ${vertex.vertexIndex + 1}');
          if (vertex.normalIndex >= 0 || vertex.textureVertexIndex >= 0) {
            sink.write('/');
            // テクスチャ頂点インデックス
            if (vertex.textureVertexIndex >= 0) {
              assert(vertex.textureVertexIndex < textureVertices.length);
              sink.write('${vertex.textureVertexIndex + 1}');
            }
            sink.write('/');
            // 法線インデックス
            if (vertex.normalIndex >= 0) {
              assert(vertex.normalIndex < normals.length);
              sink.write('${vertex.normalIndex + 1}');
            }
          }
        }
        sink.writeln();
      }
    }
    _logger.fine('[o] toWavefrontObj');
  }
}
