// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:example/data/open_moji_svgs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;
import 'ex_widgets.dart' as ex;

//
// Overflow bar example page.
//

const _trollText = Text('\u{1F9CC}');
const _tombText = Text('\u{1FAA6}');
const _goatText = Text('\u{1F410}');

final _trollSvg = openMojiSvgTroll;
final _tombSvg = SvgPicture.asset('assets/open_moji/1FAA6.svg');
final _goatSvg = openMojiSvgGoat;

final _trollHpProvider = StateProvider((ref) => 100);

class OverflowBarPage extends ConsumerWidget {
  static const icon = Icon(Icons.air_outlined);
  static const title = Text('Overflow bar');

  const OverflowBarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(ex.enableActionsProvider);
    final trollHp = ref.watch(_trollHpProvider);

    final theme = Theme.of(context);

    return ex.Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ex.ResetButtonListTile(
              enabled: enableActions && trollHp < 100,
              onPressed: () => ref.invalidate(_trollHpProvider),
            ),
            const Divider(),
            Center(
              child: theme.platform == TargetPlatform.android
                  ? SizedBox.square(
                      dimension: math.max(trollHp.toDouble() + 18, 18),
                      child: trollHp >= 0 ? _trollSvg : _tombSvg,
                    )
                  : DefaultTextStyle(
                      style: TextStyle(
                        color: enableActions ? null : theme.disabledColor,
                        fontSize: math.max(trollHp.toDouble() + 18, 18),
                      ),
                      child: trollHp >= 0 ? _trollText : _tombText,
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: const Text(
                'OverflowBar lays out its children in a row unless they "overflow" the available '
                'horizontal space, in which case it lays them out in a column instead.',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: OverflowBar(
        overflowAlignment: OverflowBarAlignment.end,
        children: [
          for (int i = 0; i < 3; ++i)
            TextButton(
              onPressed: enableActions
                  ? () {
                      if (trollHp >= 0) {
                        ref.read(_trollHpProvider.notifier).state = trollHp - 10;
                      }
                    }
                  : null,
              child: mi.Label(
                icon: theme.platform == TargetPlatform.android
                    ? SizedBox.square(
                        dimension: i * 12 + 48,
                        child: _goatSvg,
                      )
                    : DefaultTextStyle(
                        style: TextStyle(fontSize: i * 12 + 24), // 24, 36, 48
                        child: _goatText,
                      ),
                text: const Text('GaraGaraDon'),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const ex.BottomNavigationBar(),
    );
  }
}
