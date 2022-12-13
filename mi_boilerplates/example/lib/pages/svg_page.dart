// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../my_flutter_app_icons.dart';
import 'ex_app_bar.dart' as ex;

const _mediaUrl = 'https://upload.wikimedia.org/wikipedia/commons/f/fd/Ghostscript_Tiger.svg';
const _mediaPageUrl = 'https://commons.wikimedia.org/wiki/File:Ghostscript_Tiger.svg';

class SvgPage extends ConsumerWidget {
  static const icon = Icon(MyFlutterApp.svg);
  static const title = Text('SVG');

  const SvgPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = SvgPicture.network(
      _mediaUrl,
      placeholderBuilder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(30.0),
        child: const CircularProgressIndicator(),
      ),
    );

    return Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              FittedBox(
                child: image,
              ),
              const Text(_mediaPageUrl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ex.BottomNavigationBar(),
    );
  }
}
