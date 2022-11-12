// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart' hide Matrix4;
import 'package:flutter_gl/flutter_gl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';
import 'package:three_dart/three_dart.dart' as three;

import 'ex_app_bar.dart';

//
// Three_dart examples page.
//
// https://pub.dev/packages/three_dart

class ThreePage extends ConsumerWidget {
  static const icon = MiRotate(angleDegree: 195, child: Icon(Icons.change_history_outlined));
  static const title = Text('Three dart');

  static final _logger = Logger((ThreePage).toString());

  static const _tabs = <Widget>[
    MiTab(
      tooltip: 'Checkbox',
      icon: icon,
    ),
    MiTab(
      tooltip: 'Toggle buttons',
      icon: Icon(Icons.more_horiz),
    ),
  ];

  const ThreePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);

    return MiDefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
      builder: (context) {
        return Scaffold(
          appBar: ExAppBar(
            prominent: ref.watch(prominentProvider),
            icon: icon,
            title: title,
            bottom: ExTabBar(
              enabled: enabled,
              tabs: _tabs,
            ),
          ),
          body: const SafeArea(
            minimum: EdgeInsets.all(8),
            child: TabBarView(
              children: [
                _ThreeTab(),
                _ThreeTab(),
              ],
            ),
          ),
          bottomNavigationBar: const ExBottomNavigationBar(),
        );
      },
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Checkbox tab
//

class _ThreeTab extends ConsumerWidget {
  const _ThreeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    three.WebGLRenderer? renderer;
    var three3dRender = FlutterGlPlugin();
    // await three3dRender.initialize(options: {"width": 1024, "height": 1024, "dpr": 1.0});
    // await three3dRender.prepareContext();

    //example
    final camera = three.PerspectiveCamera(40, 1, 0.1, 10);
    camera.position.z = 3;
    final scene = three.Scene();
    camera.lookAt(scene.position);
    final geometryCylinder = three.CylinderGeometry(0.5, 0.5, 1, 32);
    final materialCylinder = three.MeshPhongMaterial({"color": 0xff0000});
    final mesh = three.Mesh(geometryCylinder, materialCylinder);
    scene.add(mesh);

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
          ),
        ],
      ),
    );
  }
}
