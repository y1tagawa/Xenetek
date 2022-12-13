// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;
import 'ex_widgets.dart' as ex;

//
// Overflow bar example page.
//

const _items = [
  mi.Tag(
    icon: Text('\u{1F410}', style: TextStyle(fontSize: 24)),
    spacing: 4,
    text: Text('GaraDon'),
  ),
  mi.Tag(
    icon: Text('\u{1F410}', style: TextStyle(fontSize: 36)),
    spacing: 6,
    text: Text('GaraGaraDon'),
  ),
  mi.Tag(
    icon: Text('\u{1F410}', style: TextStyle(fontSize: 48)),
    spacing: 8,
    text: Text('GaraGaraGaraDon'),
  ),
];

final _trollHpProvider = StateProvider((ref) => 100);

class OverflowBarPage extends ConsumerWidget {
  static const icon = Icon(Icons.air_outlined);
  static const title = Text('Overflow bar');

  const OverflowBarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(ex.enableActionsProvider);
    final trollHp = ref.watch(_trollHpProvider);

    return Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ex.ResetButtonListTile(
                enabled: enableActions && trollHp < 100,
                onPressed: () => ref.invalidate(_trollHpProvider),
              ),
              const Divider(),
              Center(
                child: Text(
                  trollHp >= 0 ? '\u{1F9CC}' : '\u{1FAA6}',
                  style: TextStyle(
                    color: enableActions ? null : Theme.of(context).disabledColor,
                    fontSize: trollHp > 0 ? trollHp.toDouble() + 18 : 18,
                  ),
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
      ),
      floatingActionButton: OverflowBar(
        overflowAlignment: OverflowBarAlignment.end,
        children: _items
            .map(
              (item) => TextButton(
                onPressed: enableActions
                    ? () {
                        if (trollHp >= 0) {
                          ref.read(_trollHpProvider.notifier).state = trollHp - 10;
                        }
                      }
                    : null,
                child: item,
              ),
            )
            .toList(),
      ),
      bottomNavigationBar: const ex.BottomNavigationBar(),
    );
  }
}
