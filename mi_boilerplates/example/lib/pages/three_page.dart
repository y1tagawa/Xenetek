// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart' as cube;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math.dart' as vm;

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
                  fileName: 'assets/stanford-bunny.obj',
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

//
// Modeler tab
//

const _x = mi.Vector3.unitX;
const _y = mi.Vector3.unitY;
const _z = mi.Vector3.unitZ;
const _identity = mi.Matrix4.identity;
final _xz = _x + _z;

mi.Matrix4 _rotation(mi.Vector3 axis, double angleDegree) =>
    mi.Matrix4.rotation(axis, vm.radians(angleDegree));
mi.Matrix4 _translation(mi.Vector3 translation) => mi.Matrix4.translation(translation);

mi.Node? _rootNode;

final _meshes = <mi.Mesh>[];

void _setup(StringSink sink) {
  var root = const mi.Node();
  _meshes.clear();
  // var n3 = mi.Node(
  //   matrix: _translation(_y * 2) * _rotation(_x, 45.0),
  // );
  // var n2 = mi.Node(
  //   matrix: _translation(_y * 2) * _rotation(_x, 45.0),
  //   children: {'n3': n3},
  // );
  // var n1 = mi.Node(
  //   matrix: _identity,
  //   children: {'n2': n2},
  // );
  // root = root.put('n1', n1);

  root = root.putDescendants(
    <String, mi.Matrix4>{
      'n1': _identity,
      'n2': _translation(_y * 2) * _rotation(_x, 45.0),
      'n3': _translation(_y * 2) * _rotation(_x, 45.0),
    }.entries,
  );

  _meshes.add(mi.BoxMesh(origin: 'n1', scale: _y * 1.5 + _xz));
  _meshes.add(mi.BoxMesh(origin: 'n1.n2', scale: _y * 1.5 + _xz));
  _meshes.add(const mi.BoxMesh(origin: 'n1.n2.n3', scale: 0.3));
  _rootNode = root;

  final meshDataList = <mi.MeshData>[];
  for (final mesh in _meshes) {
    meshDataList.add(mesh.toMeshData(root));
  }
  mi.toWavefrontObj(meshDataList, sink);
}

final _documentsDirectoryProvider = FutureProvider<Directory>((ref) async {
  return await getApplicationDocumentsDirectory();
});

class _ModelerTab extends ConsumerWidget {
  static final _logger = Logger((_ModelerTab).toString());

  const _ModelerTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsDirectory = ref.watch(_documentsDirectoryProvider);

    return Column(
      children: [
        mi.ButtonListTile(
          enabled: documentsDirectory.hasValue,
          text: const Text('Write'),
          onPressed: () {
            final file = File('${documentsDirectory.value!.path}/temp.obj');
            _logger.fine('output file path=${file.path}');
            final sink = file.openWrite();
            _setup(sink);
            sink.close();
          },
        ),
      ],
    );
  }
}
