// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

//
// Audio player example page.
//

final _audioItems = <String, String>{
  'Chopin - Etude Op.10,No.1':
      'https://upload.wikimedia.org/wikipedia/commons/9/96/Chopin_-_Etude_Op._10%2C_No._1.mid',
  'Bach - Well Tempered Clavier':
      'https://upload.wikimedia.org/wikipedia/commons/7/7f/Bach_-_Well-Tempered_Clavier%2C_Book_I%2C_Prelude_I%2C_opening.mid',
  'Dawn Chorus in Africa':
      'https://upload.wikimedia.org/wikipedia/commons/e/ea/Rapid-Acoustic-Survey-for-Biodiversity-Appraisal-pone.0004065.s017.ogg'
};

// final _players = List<AudioPlayer>.generate(
//   4,
//   (index) => AudioPlayer()..setReleaseMode(ReleaseMode.stop),
// );

class AudioPlayerPage extends ConsumerWidget {
  static const icon = Icon(Icons.volume_up_outlined);
  static const title = Text('Audio player');

  static const methodChannel = MethodChannel('com.xenetek.mi_boilerplates/examples');
  static final _logger = Logger((AudioPlayerPage).toString());

  const AudioPlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);

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
              ..._audioItems.entries.map((item) {
                return ListTile(
                  title: Text(item.key),
                  onTap: () {
                    AudioPlayer().play(UrlSource(item.value));
                  },
                );
              }).toList(),
              MiButtonListTile(
                enabled: enableActions,
                alignment: MainAxisAlignment.start,
                icon: const Icon(Icons.volume_up_outlined),
                text: const Text('Notification sound Icon'),
                onPressed: () async {
                  try {
                    await methodChannel.invokeMethod('playSoundAsync', 0);
                  } on PlatformException catch (e) {
                    _logger.fine(e.message);
                  }
                },
              ),
              const Divider(),
              // if (ping != null)
              //   Padding(
              //     padding: const EdgeInsets.all(4),
              //     child: Center(
              //       child: Text(ping, style: const TextStyle(fontSize: 24)),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ExBottomNavigationBar(),
    );
  }
}
