// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;

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

  static const methodChannel = MethodChannel('com.xenetek.mi_boilerplates/examples');
  // ignore: unused_field
  static final _logger = Logger((DialogsPage).toString());

  const DialogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(ex.enableActionsProvider);
    final ping = ref.watch(_pingProvider);

    void showInfoOk(BuildContext context) {
      mi
          .showInfoOkDialog(
        context: context,
        title: const Text('This is an OK dialog example.'),
        content: const Text('That is not dead which can eternal lie. '
            'And with strange aeons even death may die.'),
      )
          .then((_) {
        _ping(ref, 'OK');
      });
    }

    void showWarningOkCancel(BuildContext context) {
      mi
          .showWarningOkCancelDialog(
        context: context,
        title: const Text('This is an OK/Cancel dialog example.'),
        content: const Text('One short sleepe past, wee wake eternally, '
            'And death shall be no more; death, thou shalt die.'),
      )
          .then((value) {
        _ping(ref, value ? 'OK' : 'CANCEL');
      });
    }

    return ex.Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            mi.ButtonListTile(
              enabled: enableActions,
              alignment: MainAxisAlignment.start,
              text: const Text('Show OK dialog'),
              onPressed: () {
                showInfoOk(context);
              },
            ),
            mi.ButtonListTile(
              enabled: enableActions,
              alignment: MainAxisAlignment.start,
              text: const Text('Show OK/Cancel dialog'),
              onPressed: () {
                showWarningOkCancel(context);
              },
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
      bottomNavigationBar: const ex.BottomNavigationBar(),
    );
  }
}
