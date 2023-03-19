// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:logging/logging.dart';

import '../helpers.dart';
import 'basic.dart';

class WavefrontObjReader {
  // ignore: unused_field
  static final _logger = Logger('WavefrontObjReader');

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

    return <MeshObject>[
      MeshObject(
        vertices: vertices,
        normals: normals,
        faceGroups: <MeshFaceGroup>[MeshFaceGroup(faces: faces)],
      ).also((it) {
        _logger.fine(
          '[o] fromWavefrontObj'
          ' ${vertices.length} vertices,'
          ' ${normals.length} normals,'
          ' ${faces.length} faces.',
        );
      }),
    ];
  }
}

extension WavefrontObjWriter on Iterable<MeshObject> {
  // ignore: unused_field
  static final _logger = Logger('WavefrontObjWriter');

  /// Wavefront .obj出力
  void toWavefrontObj({
    required StringSink sink,
  }) {
    _logger.fine('[i] toWavefrontObj');

    const fractionDigits = 4;

    // 使用されているmtllibを最初にまとめてインポートする
    final materialLibraries = <String>{};
    for (final object in this) {
      for (final faceGroup in object.faceGroups) {
        if (faceGroup.materialLibrary.isNotEmpty) {
          materialLibraries.add(faceGroup.materialLibrary);
        }
      }
    }
    for (var materialLibrary in materialLibraries) {
      sink.writeln('mtllib $materialLibrary');
    }

    int vertexIndex = 1;
    int textureVertexIndex = 1;
    int normalIndex = 1;
    int faceCount = 0;

    for (final object in this) {
      if (object.tag.isNotEmpty) {
        sink.writeln('# tag: ${object.tag}');
      }
      sink.writeln('# vertex: $vertexIndex - ${vertexIndex + object.vertices.length - 1}');
      if (object.textureVertices.isNotEmpty) {
        sink.writeln('# texture vertex: '
            '$textureVertexIndex - ${textureVertexIndex + object.textureVertices.length - 1}');
      }
      if (object.normals.isNotEmpty) {
        sink.writeln('# normal: $normalIndex - ${normalIndex + object.normals.length - 1}');
      }

      for (final vertex in object.vertices) {
        sink.writeln(
          'v'
          ' ${vertex.x.toStringAsFixed(fractionDigits)}'
          ' ${vertex.y.toStringAsFixed(fractionDigits)}'
          ' ${vertex.z.toStringAsFixed(fractionDigits)}',
        );
      }
      for (final textureVertex in object.textureVertices) {
        sink.writeln(
          'vt'
          ' ${textureVertex.x.toStringAsFixed(fractionDigits)}'
          ' ${textureVertex.y.toStringAsFixed(fractionDigits)}'
          ' ${textureVertex.z.toStringAsFixed(fractionDigits)}',
        );
      }
      for (final normal in object.normals) {
        sink.writeln(
          'vn'
          ' ${normal.x.toStringAsFixed(fractionDigits)}'
          ' ${normal.y.toStringAsFixed(fractionDigits)}'
          ' ${normal.z.toStringAsFixed(fractionDigits)}',
        );
      }
      // 面グループ
      for (final faceGroup in object.faceGroups) {
        sink.writeln('s ${faceGroup.smooth ? 1 : 0}');
        if (materialLibraries.isNotEmpty) {
          sink.writeln('usemtl ${faceGroup.material}'); // マテリアルが空ならデフォルトに戻る
        }
        // 面頂点
        for (final face in faceGroup.faces) {
          assert(face.length >= 3);
          sink.write('f');
          for (final vertex in face) {
            // 頂点インデックス
            assert(vertex.vertexIndex >= 0 && vertex.vertexIndex < object.vertices.length);
            sink.write(' ${vertex.vertexIndex + vertexIndex}');
            if (vertex.normalIndex >= 0 || vertex.textureVertexIndex >= 0) {
              sink.write('/');
              // テクスチャ頂点インデックス
              if (vertex.textureVertexIndex >= 0) {
                assert(vertex.textureVertexIndex < object.textureVertices.length);
                sink.write('${vertex.textureVertexIndex + textureVertexIndex}');
              }
              sink.write('/');
              // 法線インデックス
              if (vertex.normalIndex >= 0) {
                assert(vertex.normalIndex < object.normals.length);
                sink.write('${vertex.normalIndex + normalIndex}');
              }
            }
          }
          sink.writeln();
        }
        if (materialLibraries.isNotEmpty) {
          sink.writeln('usemtl'); // マテリアルをデフォルトに
        }
      }

      vertexIndex += object.vertices.length;
      textureVertexIndex += object.textureVertices.length;
      normalIndex += object.normals.length;
      faceCount += object.faceGroups.fold(0, (value, it) => value + it.faces.length);
    }
    _logger.fine('toWavefrontObj: ${vertexIndex - 1} vertices');
    _logger.fine('toWavefrontObj: ${textureVertexIndex - 1} vertices');
    _logger.fine('toWavefrontObj: ${normalIndex - 1} normals');
    _logger.fine('toWavefrontObj: $faceCount faces');
    _logger.fine('[o] toWavefrontObj');
  }
}
