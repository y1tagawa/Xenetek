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

Future<void> _setup(StringSink sink) async {
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
      matrix: mi.Matrix4.fromTranslation(
        const mi.Vector3(1, 0, 0),
      ),
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
  root = root.lookAt(
    path: 'ball.magnet',
    targetPath: 'ball',
  );
  //
  final meshDataArray = dollBuilder.toMeshData(root: root, initRoot: initRoot);

  meshDataArray['ball'] = mi.Mesh(
    origin: 'ball',
    data: const mi.LongLatSphereBuilder(
      radius: 0.5, //mi.Vector3(0.5, 0.7, 0.3),
      longitudeDivision: 36,
      latitudeDivision: 24,
    ),
    modifiers: mi.MagnetModifier(
      magnets: const <String, mi.BoneData>{
        'ball.magnet': mi.BoneData(),
      }.entries.toList(),
    ),
  ).toMeshData(root: root);

  meshDataArray['magnet'] = const mi.Mesh(
    origin: 'ball.magnet',
    // data: mi.LongLatSphereBuilder(
    //   radius: mi.Vector3(0.05, 0.3, 0.1),
    //   longitudeDivision: 8,
    //   latitudeDivision: 4,
    // ),
  ).toMeshData(root: root);

  meshDataArray.toWavefrontObj(sink);
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
            await _setup(sink);
            await sink.close();
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
