// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

///
/// Overflow bar example page.
///

const _goatIconData = IconData(0x1F410);

const _items = [
  MiIcon(
    icon: Icon(_goatIconData, size: 24),
    spacing: 4,
    text: Text('GaraDon'),
  ),
  MiIcon(
    icon: Icon(_goatIconData, size: 36),
    spacing: 6,
    text: Text('GaraGaraDon'),
  ),
  MiIcon(
    icon: Icon(_goatIconData, size: 48),
    spacing: 8,
    text: Text('GaraGaraGaraDon'),
  ),
];

//
// OverflowBar trial page.
//

final _trollHpProvider = StateProvider((ref) => 100);

class OverflowBarPage extends ConsumerWidget {
  static const icon = Icon(Icons.air_outlined);
  static const title = Text('Overflow bar');

  const OverflowBarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final trollHpState = ref.watch(_trollHpProvider.state);
    final trollHp = trollHpState.state;

    return Scaffold(
      appBar: ExAppBar(
        prominent: ref.watch(prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Wrap(
                children: [
                  MiTextButton(
                    enabled: enableActions,
                    onPressed: () => ref.refresh(_trollHpProvider),
                    child: const MiIcon(
                      icon: Icon(Icons.refresh),
                      text: Text('Reset'),
                    ),
                  ),
                ],
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
              (item) => MiTextButton(
                enabled: enableActions,
                onPressed: () {
                  if (trollHp >= 0) {
                    trollHpState.state -= 10;
                  }
                },
                child: item,
              ),
            )
            .toList(),
      ),
      bottomNavigationBar: const ExBottomNavigationBar(),
    );
  }
}
