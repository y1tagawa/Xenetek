// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Matrix4;
import 'package:flutter/services.dart';
import 'package:flutter_cube/flutter_cube.dart' as cube;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;
import 'package:path_provider/path_provider.dart';

import 'ex_app_bar.dart' as ex;

typedef BoneData = mi.BoneData;
typedef BoneType = mi.BoneType;
typedef FlatEnd = mi.FlatEnd;
typedef MagnetData = mi.MagnetData;
typedef MagnetModifier = mi.MagnetModifier;
typedef Matrix4 = mi.Matrix4;
typedef Mesh = mi.Mesh;
typedef MeshData = mi.MeshData;
typedef MeshDataHelper = mi.MeshDataHelper;
typedef Node = mi.Node;
typedef OpenEnd = mi.OpenEnd;
typedef SkinModifier = mi.SkinModifier;
typedef SphereBuilder = mi.SphereBuilder;
typedef TubeBuilder = mi.TubeBuilder;
typedef Vector3 = mi.Vector3;
const octahedronMeshObject = mi.octahedronMeshObject;

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

Future<void> _createMtl() async {
  final tempDir = await _getModelTempFileDir();
  final file = File('$tempDir/x11.mtl');
  final sink = file.openWrite();

  for (int i = 0; i < mi.X11Colors.colors.length; ++i) {
    final c = mi.X11Colors.colors[i];
    sink.writeln('newmtl ${mi.x11ColorNames[i]}');
    sink.writeln('Ka 1 1 1');
    sink.writeln(
      'Kd '
      '${(c.red / 255.0).toStringAsFixed(4)} '
      '${(c.green / 255.0).toStringAsFixed(4)} '
      '${(c.blue / 255.0).toStringAsFixed(4)} ',
    );
    //Ks 0.5 0.5 0.5
    //#Ns 96.078431
    //#Ni 1
    sink.writeln('d 1\n');
    //#illum 0
  }

  await sink.close();
}

// cube.Mesh _toMesh(Map<String, MeshData> meshDataArray) {
//   final vertices = <cube.Vector3>[];
//   final indices = <cube.Polygon>[];
//   int vertexIndex = 0;
//   for (final data in meshDataArray.values) {
//     vertices.addAll(data.vertices.map((it) => cube.Vector3(it.x, it.y, it.z)));
//     for (final face in data.faces) {
//       for (int i = 1; i < face.length - 1; ++i) {
//         indices.add(cube.Polygon(
//           face[0].vertexIndex + vertexIndex,
//           face[i].vertexIndex + vertexIndex,
//           face[i + 1].vertexIndex + vertexIndex,
//         ));
//       }
//     }
//     vertexIndex += data.vertices.length;
//   }
//   return cube.Mesh(vertices: vertices, indices: indices);
// }
//
// cube.Cube _toCube(Map<String, MeshData> meshDataArray) {
//   final mesh = _toMesh(meshDataArray);
//   ++_cubeKey;
//   return cube.Cube(
//     key: Key(_cubeKey.toString()),
//     onSceneCreated: (cube.Scene scene) {
//       scene.camera = cube.Camera(
//         position: cube.Vector3(-0.05, 0.3, 1.5),
//         target: cube.Vector3(-0.05, 0.3, 0),
//         fov: 35.0,
//       );
//       scene.world.add(
//         cube.Object(
//           mesh: mesh,
//           lighting: true,
//         ),
//       );
//     },
//   );
// }

Future<void> _setup(StringSink sink) async {
  // ignore: unused_local_variable
  final logger = Logger('_setup');

  final headObj = await rootBundle.loadString('assets/3d/head.obj');
  final headMesh = mi.MeshDataHelper.fromWavefrontObj(headObj).transformed(Matrix4.fromScale(0.3));
  final footObj = await rootBundle.loadString('assets/3d/foot.obj');
  final footMesh = mi.MeshDataHelper.fromWavefrontObj(footObj);

  const dollBuilder = mi.BipedRigBuilder();
  var root = dollBuilder.build();
  final initRoot = root;

  root = root.add(
    path: 'lathe',
    child: Node(
      matrix: Matrix4.fromTranslation(
        const mi.Vector3(-2, 1, 0),
      ),
    ),
  );
  root = root.add(
    path: 'spindle',
    child: Node(
      matrix: Matrix4.fromTranslation(
        const mi.Vector3(-1, 1, 0),
      ),
    ),
  );
  root = root.add(
    path: 'ball',
    child: Node(
      matrix: Matrix4.fromTranslation(
        const mi.Vector3(1, 1, 0),
      ),
    ),
  );
  root = root.add(
    path: 'ball.magnet',
    child: Node(
      matrix: Matrix4.fromTranslation(const mi.Vector3(0.7, 0, 0)),
    ),
  );
  root = root.add(
    path: 'ball.magnet2',
    child: Node(
      matrix: Matrix4.fromTranslation(const mi.Vector3(0.65, 0, -0.1)),
    ),
  );
  root = root.add(
    path: 'ball.magnet3',
    child: Node(
      matrix: Matrix4.fromTranslation(const mi.Vector3(0.65, 0, 0.1)),
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
        matrix: Matrix4.fromAxisAngleRotation(axis: mi.Vector3.unitY, degrees: 30),
      );
  //
  final dollMeshBuilder = mi.BipedMeshBuilder(
    rigBuilder: dollBuilder,
    referencePosition: initRoot,
    root: root,
    headMesh: headMesh,
    footMesh: footMesh,
  );
  final dollMeshData = dollMeshBuilder.build();

  const tempData =
      'M 0.0 0.0 C 0.15 0.0 0.3057 -0.0314 0.35 0.15 0.3747 0.2513 0.3074 0.3213 0.3048 0.4443 0.3027 0.5392 0.35 0.6649 0.35 0.75 0.35 0.95 0.0 1.0 0.0 1.0';
  const tempData2 =
      'M 0 0 C 0.15 0 0.3057 -0.0314 0.35 0.15 0.3747 0.2513 0.0827 0.3232 0.0801 0.4462 0.078 0.5412 0.2337 0.6649 0.2337 0.75 0.2337 0.95 0 1 0 1';
  //'M 5.0000001e-7,99.999995 C 15.000001,99.999995 30.574827,103.13506 35,84.999996 37.471943,74.869578 8.2709862,67.675817 8.0073172,55.375716 7.8037912,45.881285 23.371028,33.509487 23.371028,24.999999 23.371028,4.9999998 5.0000001e-7,0 5.0000001e-7,0';
  final tempPoints = mi.SvgPathParser.fromString(tempData)
      // .transformed(
      //   Matrix4.fromScale(const mi.Vector3(0.01, -0.01, 0.01)) *
      //       Matrix4.fromTranslation(const mi.Vector3(-50, -100, 0)),
      // )
      .toList();
  final tempPoints2 = mi.SvgPathParser.fromString(tempData2)
      // .transformed(
      //   Matrix4.fromScale(const mi.Vector3(0.01, -0.01, 0.01)) *
      //       Matrix4.fromTranslation(const mi.Vector3(0, -100, 0)),
      // )
      .toList();
  final tempBezier = mi.Bezier<mi.Vector3>(points: tempPoints);
  final tempBezier2 = mi.Bezier<mi.Vector3>(points: tempPoints2);
  logger.fine('t1=${tempBezier.points.toSvgPathData()}');
  logger.fine('t2=${tempBezier2.points.toSvgPathData()}');

  const tempPoints3 = [
    mi.Vector3.zero,
    mi.Vector3(0, 0.2, -0.2),
    mi.Vector3(0, 0.5, 0.1),
    mi.Vector3(0, 0.3, 0.2),
  ];
  final tempBezier3 = mi.Bezier<mi.Vector3>(points: tempPoints3);
  final tempMesh3 = Mesh(
    origin: 'ball',
    data: mi.octahedronMeshObject,
    modifiers: [
      mi.MultipleModifier(
        matrices: [
          for (int i = 0; i < 10; ++i)
            () {
              final t = i / 10;
              final p = tempBezier3.transform(t);
              return Matrix4.fromTranslation(p) * Matrix4.fromScale(i == 0 ? 0.1 : 0.05);
            }(),
        ],
      ),
    ],
  ).toMeshData(root: root);

  final tempMesh = Mesh(
    origin: 'ball',
    // data: mi.ParametricBuilder.fromRLFBCurves(
    //   right: tempBezier,
    //   left: tempBezier,
    //   front: tempBezier2,
    //   back: tempBezier,
    // ),
    data: const mi.TeardropBuilder(
      //shape: 0.85,
      heightDivision: 24,
      radius: mi.Vector3(0.5, 1, 0.2),
    ),
    modifiers: [
      mi.ParametricModifier(
        bend: mi.Bezier(points: tempPoints3),
        //twist: mi.Bezier(points: const <double>[0.0, math.pi * 0.5]),
      ),
    ],
  ).toMeshData(root: root);

  final spindle = Mesh(
    origin: 'spindle',
    data: const mi.SpindleBuilder(
      materialLibrary: 'x11.mtl',
      material: 'firebrick',
      radius: 0.5,
      longitudeDivision: 12,
      heightDivision: 6,
    ),
    modifiers: [
      mi.ParametricModifier(
        //wicking: mi.Bezier<mi.Vector3>(points: const [mi.Vector3.zero, mi.Vector3.unitY]),
        // <mi.Vector3>[
        //   mi.Vector3(0, 0, 0),
        //   mi.Vector3(0, 1, 0),
        //   mi.Vector3(0, 1, 0),
        //   mi.Vector3(1, 1, 0),
        // ],
        twist: mi.Bezier(points: const <double>[0.0, math.pi]),
      ),
    ],
  ).toMeshData(root: root);
  // meshDataArray['ball'] = Mesh(
  //   origin: 'ball',
  //   data: const mi.SorBuilder(
  //     shape: mi.SorShape.ellipsoid,
  //     radius: 1.0, //mi.Vector3(0.5, 0.7, 0.3),
  //     longitudeDivision: 64,
  //     heightDivision: 32,
  //   ),
  //   modifiers: [
  //     const mi.BoxModifier(
  //       min: mi.Vector3(-0.5, -0.5, -0.5),
  //       max: mi.Vector3(0.5, 0.5, 0.5),
  //     ),
  //     MagnetModifier(
  //       magnets: const <String, MagnetData>{
  //         'ball.magnet': MagnetData(
  //           force: 0.2,
  //           power: -4,
  //         ),
  //         'ball.magnet2': MagnetData(
  //           force: -0.3,
  //           power: -2,
  //           mirror: true,
  //         ),
  //       }.entries.toList(),
  //     ),
  //   ],
  // ).toMeshData(root: root);

  // meshDataArray['magnet'] = const Mesh(
  //   origin: 'ball.magnet',
  //   modifiers: mi.LookAtModifier(
  //     target: 'ball',
  //   ),
  // ).toMeshData(root: root);

  const tempData4 = 'M 2,0 C 2,0 0,2 0,0 0,2 -2,-0 -2,-0 -4,-1.3 -1.5,-2 0,-2 c 1.5,0 4,1.3 2,2';
  final latheMesh = Mesh(
    origin: 'lathe',
    data: mi.SphereBuilder(
      materialLibrary: 'x11.mtl',
      material: 'cadetBlue',
      radius: 0.25,
      longitudeDivision: 36,
      latitudeDivision: 36,
      equator: mi.Bezier<mi.Vector3>(points: mi.SvgPathParser.fromString(tempData4)),
    ),
  ).toMeshData(root: root);

  [
    ...latheMesh,
    ...tempMesh3,
    ...dollMeshData,
    ...spindle,
    ...tempMesh,
  ].toWavefrontObj(sink: sink);
  //[...tempMesh].toWavefrontObj(sink: sink);
}

Future<void> _setup2(StringSink sink) async {
  // ignore: unused_local_variable
  final logger = Logger('_setup2');

  const eyePosition = mi.Vector3(-0.12, 0.0, -0.13);
  var root = const Node(
    matrix: Matrix4.identity,
  ).addAll(
    entries: {
      'rEye': Node(
        matrix: Matrix4.fromTranslation(eyePosition),
      ),
      'lEye': Node(
        matrix: Matrix4.fromTranslation(eyePosition.mirrored()),
      ),
    }.entries,
  );

  final face = Mesh(
    origin: '',
    data: const SphereBuilder(
      radius: Vector3(0.28, 0.3, 0.3),
      longitudeDivision: 96,
      latitudeDivision: 48,
    ),
    modifiers: [
      MagnetModifier(
        magnets: [
          ...{
            // flat face
            const Vector3(0.0, 0.0, -0.22): const MagnetData(
              //radius: 0.6,
              strength: -0.1,
              exponent: -6,
              type: BoneType.type2,
            ),
            //chin
            const Vector3(0.0, -0.3, -0.4): const MagnetData(
              radius: 0.6,
              strength: 0.2,
              exponent: 2,
            ),
            // nose
            // const Vector3(0.0, 0.02, -0.35): MagnetData(
            //   radius: 0.15,
            //   strength: 1.0,
            //   type: BoneType.type2,
            //   matrix: Matrix4.fromScale(const Vector3(1.4, 1.2, 1)) *
            //       Matrix4.fromAxisAngleRotation(axis: Vector3.unitX, degrees: 5.0),
            // ),
            // eye sockets
            eyePosition.copyWith(z: -0.35): const MagnetData(
              radius: 1.0,
              strength: -0.05,
              exponent: 5,
              mirror: true,
            ),
          }.entries
        ],
      ),
    ],
  ).toMeshData(root: root);
  final rEye = const Mesh(
    origin: 'rEye',
    data: SphereBuilder(
      radius: 0.1,
    ),
  ).toMeshData(root: root);
  final lEye = const Mesh(
    origin: 'lEye',
    data: SphereBuilder(
      radius: 0.1,
    ),
  ).toMeshData(root: root);
  [...face, ...rEye, ...lEye].toWavefrontObj(sink: sink);
}

Future<void> _setup3(StringSink sink) async {
  // ignore: unused_local_variable
  final logger = Logger('_setup3');

  Node addArmRig({
    required Node root,
    required String path,
    required Matrix4 matrix,
  }) {
    root = root.add(
      path: path,
      child: Node(matrix: matrix),
    );
    root = root.add(
      path: '$path.elbow',
      child: Node(matrix: Matrix4.fromTranslation(const Vector3(0, 0.5, 0))),
    );
    root = root.add(
      path: '$path.elbow.wrist',
      child: Node(matrix: Matrix4.fromTranslation(const Vector3(0, 0.5, -0))),
    );
    return root;
  }

  const int ii = 4;
  var root = const Node(matrix: Matrix4.identity);
  for (int i = 0; i <= ii; ++i) {
    root = addArmRig(
      root: root,
      path: 'arm$i',
      matrix: Matrix4.fromTranslation(Vector3.unitX * 0.2 * i),
    );
  }
  final ref = root;

  for (int i = 0; i <= ii; ++i) {
    root = root.transform(
      path: 'arm$i.elbow',
      matrix: Matrix4.fromAxisAngleRotation(axis: Vector3.unitX, degrees: 30.0 * i),
    );
  }

  MeshData addArmMeshes({
    required Node root,
    required Node refRoot,
    required String path,
  }) {
    final marks = [
      Mesh(
        origin: path,
        data: octahedronMeshObject.transformed(Matrix4.fromScale(0.05)),
      ).toMeshData(root: root),
      Mesh(
        origin: '$path.elbow',
        data: octahedronMeshObject.transformed(Matrix4.fromScale(0.05)),
      ).toMeshData(root: root),
      Mesh(
        origin: '$path.elbow.wrist',
        data: octahedronMeshObject.transformed(Matrix4.fromScale(0.05)),
      ).toMeshData(root: root),
    ].flattened;

    final arm = Mesh(
      origin: path,
      data: const TubeBuilder(
        heightDivision: 48,
        beginRadius: 0.05,
        endRadius: 0.05,
        beginShape: FlatEnd(),
        endShape: OpenEnd(),
      ),
      modifier: SkinModifier(
        bones: <String, BoneData>{
          path: const BoneData(radius: 0.6),
          //'elbow': const BoneData(radius: 0.1),
          '$path.elbow.wrist': const BoneData(radius: 0.6),
        }.entries.toList(),
        referencePosition: refRoot,
      ),
    ).toMeshData(root: root);

    return [...marks, ...arm];
  }

  [
    for (int i = 0; i <= ii; ++i)
      ...addArmMeshes(
        root: root,
        refRoot: ref,
        path: 'arm$i',
      ),
  ].toWavefrontObj(sink: sink);
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
            //await _createMtl();
            final tempDir = await _getModelTempFileDir();
            final file = File('$tempDir/temp.obj');
            final sink = file.openWrite();
            await _setup(sink);
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
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//</editor-fold>
