// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';
import 'ex_bottom_navigation_bar.dart';

enum _Class { fighter, cleric, mage, thief }

class _RadioItem {
  final Widget Function(bool checked) iconBuilder;
  final Widget text;
  const _RadioItem({required this.iconBuilder, required this.text});
}

final _radioItems = <_Class, _RadioItem>{
  _Class.fighter: _RadioItem(
    iconBuilder: (_) => const Icon(Icons.shield_outlined),
    text: const Text('Fighter'),
  ),
  _Class.cleric: _RadioItem(
    iconBuilder: (_) => const Icon(Icons.emergency_outlined),
    text: const Text('Cleric'),
  ),
  _Class.mage: _RadioItem(
    iconBuilder: (_) => const Icon(Icons.auto_fix_normal_outlined),
    text: const Text('Mage'),
  ),
  _Class.thief: _RadioItem(
    iconBuilder: (checked) =>
        checked ? const Icon(Icons.lock_open) : const Icon(Icons.lock_outlined),
    text: const Text('Thief'),
  ),
};

final _classProvider = StateProvider((ref) => _Class.fighter);

class RadiosPage extends ConsumerWidget {
  static const icon = Icon(Icons.radio_button_checked_outlined);
  static const title = Text('Radios');

  static final _logger = Logger((RadiosPage).toString());

  const RadiosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final class_ = ref.watch(_classProvider);

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
              ..._radioItems.keys.map(
                (key) {
                  final item = _radioItems[key]!;
                  return MiRadioListTile<_Class>(
                    enabled: enableActions,
                    value: key,
                    groupValue: class_,
                    title: MiIcon(
                      icon: item.iconBuilder(key == class_),
                      text: item.text,
                    ),
                    onChanged: (value) {
                      ref.read(_classProvider.state).state = value!;
                    },
                  );
                },
              ),
              const Divider(),
              Container(
                padding: const EdgeInsets.all(10),
                child: IconTheme(
                  data: IconThemeData(
                    color: Theme.of(context).disabledColor,
                    size: 60,
                  ),
                  child: _radioItems[class_]!.iconBuilder(true),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ExBottomNavigationBar(),
    );
  }
}
