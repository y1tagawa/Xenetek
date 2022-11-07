// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

//
// Dialogs example page.
//

final _pingProvider = StateProvider<String?>((ref) => null);

void _ping(WidgetRef ref, String value) async {
  ref.read(_pingProvider.notifier).state = value;
  await Future.delayed(
    const Duration(seconds: 2),
    () {
      ref.read(_pingProvider.notifier).state = null;
    },
  );
}

class DialogsPage extends ConsumerWidget {
  static const icon = Icon(Icons.library_add_check_outlined);
  static const title = Text('Dialogs');

  const DialogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final ping = ref.watch(_pingProvider);

    void showInfoOk(BuildContext context) {
      showInfoOkDialog(
        context: context,
        title: const Text('This is an OK dialog example.'),
        content: const Text('That is not dead which can eternal lie. '
            'And with strange aeons even death may die.'),
      ).then((_) {
        _ping(ref, 'OK');
      });
    }

    void showWarningOkCancel(BuildContext context) {
      showWarningOkCancelDialog(
        context: context,
        title: const Text('This is an OK/Cancel dialog example.'),
        content: const Text('One short sleepe past, wee wake eternally, '
            'And death shall be no more; death, thou shalt die.'),
      ).then((value) {
        _ping(ref, value ? 'OK' : 'CANCEL');
      });
    }

    return Scaffold(
      appBar: ExAppBar(
        prominent: ref.watch(prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: MiTextButton(
                  enabled: enableActions,
                  onPressed: () {
                    showInfoOk(context);
                  },
                  child: const Text('Show OK dialog'),
                ),
              ),
              ListTile(
                leading: MiTextButton(
                  enabled: enableActions,
                  onPressed: () {
                    showWarningOkCancel(context);
                  },
                  child: const Text('Show OK/Cancel dialog'),
                ),
              ),
              const Divider(),
              if (ping != null)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Center(
                    child: Text(ping, style: const TextStyle(fontSize: 24)),
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
