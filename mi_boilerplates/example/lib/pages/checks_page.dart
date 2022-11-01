// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';
import 'ex_bottom_navigation_bar.dart';

const _combinedIcons = <IconData?>[
  null,
  Icons.square_outlined, // 1
  Icons.subject, // 2
  Icons.article_outlined,
  Icons.check, // 4
  Icons.check_box_outlined,
  Icons.playlist_add_check_outlined,
  Icons.fact_check_outlined,
];

//
// Checkbox examples page.
//

// But see also https://pub.dev/packages/flutter_treeview ,
// https://pub.dev/packages/flutter_simple_treeview .

class _CheckItem {
  final StateProvider<bool> provider;
  final Widget title;
  const _CheckItem({required this.provider, required this.title});
}

final _boxCheckProvider = StateProvider((ref) => true);
final _textCheckProvider = StateProvider((ref) => true);
final _checkCheckProvider = StateProvider((ref) => true);

final _checkItems = [
  _CheckItem(
    provider: _boxCheckProvider,
    title: const MiIcon(
      icon: Icon(Icons.square_outlined),
      text: Text('Box'),
    ),
  ),
  _CheckItem(
    provider: _textCheckProvider,
    title: const MiIcon(
      icon: Icon(Icons.subject),
      text: Text('Text'),
    ),
  ),
  _CheckItem(
    provider: _checkCheckProvider,
    title: const MiIcon(
      icon: Icon(Icons.check),
      text: Text('Check'),
    ),
  ),
];

class ChecksPage extends ConsumerWidget {
  static const icon = Icon(Icons.check_box_outlined);
  static const title = Text('Checks');

  const ChecksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final box = ref.watch(_boxCheckProvider);
    final text = ref.watch(_textCheckProvider);
    final check = ref.watch(_checkCheckProvider);

    final combinedIcon = _combinedIcons[(box ? 1 : 0) + (text ? 2 : 0) + (check ? 4 : 0)];

    void setTally(bool value) {
      ref.read(_boxCheckProvider.state).state = value;
      ref.read(_textCheckProvider.state).state = value;
      ref.read(_checkCheckProvider.state).state = value;
    }

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
              MiExpansionTile(
                enabled: enableActions,
                initiallyExpanded: true,
                // ExpansionTileに他のウィジェットを入れるケースは稀だろうからカスタムウィジェットはまだ作らない
                leading: Checkbox(
                  value: (box && text && check)
                      ? true
                      : (box || text || check)
                          ? null
                          : false,
                  tristate: true,
                  onChanged: enableActions
                      ? (value) {
                          setTally(value != null);
                        }
                      : null,
                ),
                title: MiIcon(
                  icon: Icon(combinedIcon),
                  text: const Text('Tally'),
                ),
                children: _checkItems.map(
                  (item) {
                    return CheckboxListTile(
                      enabled: enableActions,
                      value: ref.read(item.provider),
                      contentPadding: const EdgeInsets.only(left: 28),
                      title: item.title,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) {
                        ref.read(item.provider.state).state = value!;
                      },
                    );
                  },
                ).toList(),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  combinedIcon,
                  size: 60,
                  color: Theme.of(context).unselectedIconColor,
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ExBottomNavigationBar(),
    );
  }
}
