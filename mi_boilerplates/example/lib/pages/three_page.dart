// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' hide Matrix4;
import 'package:flutter/services.dart';
import 'package:flutter_cube/flutter_cube.dart' as cube;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;
import 'package:path_provider/path_provider.dart';

import 'ex_app_bar.dart' as ex;

//
// 3D examples page.
//
// https://pub.dev/packages/flutter_cube
// https://pub.dev/packages/three_dart

class ThreePage extends ConsumerWidget {
  static const icon = Icon(Icons.view_in_ar_outlined);
  static const title = Text('3D');

  static final _logger = Logger((ThreePage).toString());

  static const _tabs = <Widget>[
    mi.Tab(
      tooltip: 'Bunny',
      icon: Icon(Icons.cruelty_free_outlined),
    ),
    mi.Tab(
      tooltip: 'Modeler',
      icon: icon,
    ),
  ];

  const ThreePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);

    return mi.DefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
      builder: (context) {
        return ex.Scaffold(
          appBar: ex.AppBar(
            prominent: ref.watch(ex.prominentProvider),
            icon: icon,
            title: title,
            bottom: ex.TabBar(
              enabled: enabled,
              tabs: _tabs,
            ),
          ),
          body: const TabBarView(
            children: [
              _BunnyTab(),
              _ModelerTab(),
            ],
          ),
          bottomNavigationBar: const ex.BottomNavigationBar(),
        );
      },
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Bunny tab
//

//<editor-fold>

extension ColorHelper on Color {
  static const _k = 1.0 / 255.0;
  cube.Vector3 toVector() => cube.Vector3(red * _k, green * _k, blue * _k);
}

class _BunnyTab extends ConsumerWidget {
  static final _logger = Logger((_BunnyTab).toString());

  const _BunnyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: cube.Cube(
              onSceneCreated: (cube.Scene scene) {
                final bunny = cube.Object(
                  fileName: 'assets/3d/stanford-bunny.obj',
                  lighting: true,
                );
                _logger.fine('bunny.mesh.colors=${bunny.mesh.colors}');
                bunny.mesh.colors.add(Colors.red);
                bunny.mesh.material.ambient = Colors.brown.toVector() * 0.95;
                bunny.mesh.material.diffuse = Colors.red.toVector() * 0.15;
                bunny.mesh.material.specular = Colors.white.toVector() * 0.05;
                scene.world.add(bunny);
                scene.camera = cube.Camera(
                  position: cube.Vector3(-0.05, 0.3, 1.5),
                  target: cube.Vector3(-0.05, 0.3, 0),
                  fov: 35.0,
                );
                _logger.fine('fov = ${scene.camera.fov}');
                _logger.fine('pos = ${scene.camera.position}');
                _logger.fine('ambient = ${bunny.mesh.material.ambient}');
                _logger.fine('diffuse = ${bunny.mesh.material.diffuse}');
                _logger.fine('specular = ${bunny.mesh.material.specular}');
                _logger.fine('bunny.mesh.colors=${bunny.mesh.colors}');
              },
            ),
          ),
        ),
      ],
    );
  }
}

//</editor-fold>

//
// Modeler tab
//

//<editor-fold>

cube.Mesh _toMesh(Map<String, mi.MeshData> meshDataArray) {
  final vertices = <cube.Vector3>[];
  final indices = <cube.Polygon>[];
  int vertexIndex = 0;
  for (final data in meshDataArray.values) {
    vertices.addAll(data.vertices.map((it) => cube.Vector3(it.x, it.y, it.z)));
    for (final face in data.faces) {
      for (int i = 1; i < face.length - 1; ++i) {
        indices.add(cube.Polygon(
          face[0].vertexIndex + vertexIndex,
          face[i].vertexIndex + vertexIndex,
          face[i + 1].vertexIndex + vertexIndex,
        ));
      }
    }
    vertexIndex += data.vertices.length;
  }
  return cube.Mesh(vertices: vertices, indices: indices);
}

cube.Cube _toCube(Map<String, mi.MeshData> meshDataArray) {
  final mesh = _toMesh(meshDataArray);
  ++_cubeKey;
  return cube.Cube(
    key: Key(_cubeKey.toString()),
    onSceneCreated: (cube.Scene scene) {
      scene.camera = cube.Camera(
        position: cube.Vector3(-0.05, 0.3, 1.5),
        target: cube.Vector3(-0.05, 0.3, 0),
        fov: 35.0,
      );
      scene.world.add(
        cube.Object(
          mesh: mesh,
          lighting: true,
        ),
      );
    },
  );
}

Future<Map<String, mi.MeshData>> _setup(StringSink sink) async {
  final logger = Logger('_setup');

  final headObj = await rootBundle.loadString('assets/3d/head.obj');
  final headMesh =
      mi.MeshDataHelper.fromWavefrontObj(headObj).transformed(mi.Matrix4.fromScale(0.3));
  final footObj = await rootBundle.loadString('assets/3d/foot.obj');
  final footMesh = mi.MeshDataHelper.fromWavefrontObj(footObj);

  final dollBuilder = mi.HumanRig(
    headMesh: headMesh,
    footMesh: footMesh,
  );
  var root = dollBuilder.build();
  final initRoot = root;

  root = root.add(
    path: 'ball',
    child: mi.Node(
      matrix: mi.Matrix4.fromTranslation(
        const mi.Vector3(1, 1, 0),
      ),
    ),
  );
  root = root.add(
    path: 'ball.magnet',
    child: mi.Node(
      matrix: mi.Matrix4.fromTranslation(const mi.Vector3(0.7, 0, 0)),
    ),
  );
  root = root.add(
    path: 'ball.magnet2',
    child: mi.Node(
      matrix: mi.Matrix4.fromTranslation(const mi.Vector3(0.65, 0, -0.1)),
    ),
  );
  root = root.add(
    path: 'ball.magnet3',
    child: mi.Node(
      matrix: mi.Matrix4.fromTranslation(const mi.Vector3(0.65, 0, 0.1)),
    ),
  );

  //logger.fine('root');
  //logger.fine(root.format(sink: StringBuffer()).toString());

  // ポージング
  root = root
      .bendNeck(degrees: 10)
      .twistNeck(degrees: 60)
      //
      .twistRCoxa(degrees: -10)
      .swingRCoxa(degrees: 5)
      .swingRAnkle(degrees: -5)
      //
      .twistLCoxa(degrees: 10)
      .swingLCoxa(degrees: -5)
      .swingLAnkle(degrees: 5)
      //
      .bendRShoulder(degrees: 30.0)
      .bendLShoulder(degrees: 45.0)
      .bendRElbow(degrees: 60.0)
      .bendLElbow(degrees: 120.0);
  //
  root = root
      .lookAt(
        path: 'ball.magnet',
        targetPath: 'ball',
      )
      .transform(
        path: 'ball.magnet',
        matrix: mi.Matrix4.fromAxisAngleRotation(axis: mi.Vector3.unitY, degrees: 30),
      );
  //
  final meshDataArray = dollBuilder.toMeshData(root: root, initRoot: initRoot);

  meshDataArray['ball'] = mi.Mesh(
    origin: 'ball',
    data: const mi.LongLatSphereBuilder(
      radius: 0.5, //mi.Vector3(0.5, 0.7, 0.3),
      longitudeDivision: 64,
      latitudeDivision: 32,
    ),
    modifiers: [
      mi.MagnetModifier(
        magnets: const <String, mi.MagnetData>{
          'ball.magnet': mi.MagnetData(
            force: 0.2,
            power: -4,
          ),
          'ball.magnet2': mi.MagnetData(
            radius: 0.1,
            force: -0.2,
            power: -2,
          ),
          'ball.magnet3': mi.MagnetData(
            radius: 0.1,
            force: -0.2,
            power: -2,
          ),
        }.entries.toList(),
      ),
    ],
  ).toMeshData(root: root);

  // meshDataArray['magnet'] = const mi.Mesh(
  //   origin: 'ball.magnet',
  //   modifiers: mi.LookAtModifier(
  //     target: 'ball',
  //   ),
  // ).toMeshData(root: root);

  meshDataArray.toWavefrontObj(sink);

  return meshDataArray;
}

Future<String> _getModelTempFileDir() async {
  final docDir = await getApplicationDocumentsDirectory();
  return docDir.path;
}

int _cubeKey = 0;

Future<cube.Cube> _getCube() async {
  final tempDir = await _getModelTempFileDir();
  ++_cubeKey;
  return cube.Cube(
    key: Key(_cubeKey.toString()),
    onSceneCreated: (cube.Scene scene) {
      scene.camera = cube.Camera(
        position: cube.Vector3(-0.05, 0.3, 1.5),
        target: cube.Vector3(-0.05, 0.3, 0),
        fov: 35.0,
      );
      scene.world.add(
        cube.Object(
          fileName: '$tempDir/temp.obj',
          isAsset: false,
          lighting: true,
        ),
      );
    },
  );
}

final _cubeDataStream = StreamController<cube.Cube>();
final _cubeDataProvider = StreamProvider<cube.Cube>(
  (ref) async* {
    _cubeDataStream.add(await _getCube());
    await for (final cube in _cubeDataStream.stream) {
      yield cube;
    }
  },
);

class _ModelerTab extends ConsumerWidget {
  // ignore: unused_field
  static final _logger = Logger((_ModelerTab).toString());

  const _ModelerTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');
    final cubeData = ref.watch(_cubeDataProvider);
    return Column(
      children: [
        mi.ButtonListTile(
          enabled: cubeData.hasValue,
          text: const Text('Update'),
          onPressed: () async {
            final tempDir = await _getModelTempFileDir();
            final file = File('$tempDir/temp.obj');
            final sink = file.openWrite();
            final meshDataArray = await _setup(sink);
            await sink.close();
            //_cubeDataStream.add(_toCube(meshDataArray));
            _cubeDataStream.add(await _getCube());
          },
        ),
        Expanded(
          child: Center(
            child: cubeData.when(
              data: (data) => data,
              error: (error, stackTrace) {
                debugPrintStack(label: error.toString(), stackTrace: stackTrace);
                return Text(error.toString());
              },
              loading: () => const CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }
}

//</editor-fold>
