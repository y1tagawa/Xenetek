// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;
import 'package:path/path.dart' as p;

import 'ex_app_bar.dart' as ex;

//
// Audio player example page.
//

const _audioItems = <String, String>{
  'Chopin - Etude Op.10,No.1':
      'https://upload.wikimedia.org/wikipedia/commons/9/96/Chopin_-_Etude_Op._10%2C_No._1.mid',
  'Bach - Well Tempered Clavier':
      'https://upload.wikimedia.org/wikipedia/commons/7/7f/Bach_-_Well-Tempered_Clavier%2C_Book_I%2C_Prelude_I%2C_opening.mid',
  'Dawn Chorus in Africa':
      'https://upload.wikimedia.org/wikipedia/commons/e/ea/Rapid-Acoustic-Survey-for-Biodiversity-Appraisal-pone.0004065.s017.ogg',
  'Gospel Train': 'https://upload.wikimedia.org/wikipedia/commons/9/92/Gospel_Train.mp3',
  'Sample - Start': 'https://upload.wikimedia.org/wikipedia/commons/9/93/Start.wav',
//  '':'',
};

const _audioFileTypes = <String, Widget>{
  '.mid': Text('MIDI'),
  '.ogg': Text('Ogg'),
  '.mp3': Text('MP3'),
  '.wav': Text('WAVE'),
};

// final _players = List<AudioPlayer>.generate(
//   4,
//   (index) => AudioPlayer()..setReleaseMode(ReleaseMode.stop),
// );

final _player = AudioPlayer()..setReleaseMode(ReleaseMode.release);

class AudioPlayerPage extends ConsumerWidget {
  static const icon = Icon(Icons.volume_up_outlined);
  static const title = Text('Audio player');

  static const methodChannel = MethodChannel('com.xenetek.mi_boilerplates/examples');
  static final _logger = Logger((AudioPlayerPage).toString());

  const AudioPlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(ex.enableActionsProvider);

    return ex.Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ..._audioItems.entries.map((item) {
              final fileType = p.extension(item.value);
              bool playable = true;
              // switch (theme.platform) {
              //   case TargetPlatform.windows:
              //     if (fileType == '.mid' || fileType == '.ogg') {
              //       playable = false;
              //     }
              //     break;
              //   case TargetPlatform.android:
              //     break;
              //   default:
              //     playable = false;
              // }

              return ListTile(
                enabled: enableActions && playable,
                leading: _audioFileTypes[fileType] ?? Text(fileType),
                title: Text(item.key),
                onTap: () async {
                  if (_player.state == PlayerState.playing) {
                    await _player.stop();
                    await _player.release();
                  }
                  try {
                    await _player.play(UrlSource(item.value));
                  } catch (e) {
                    _logger.info('caught exception: $e');
                    rethrow;
                  }
                },
              );
            }).toList(),
            ListTile(
              leading: const Icon(Icons.stop),
              onTap: () async {
                await _player.stop();
                await _player.release();
              },
            ),
            mi.ButtonListTile(
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
          ],
        ),
      ),
      bottomNavigationBar: const ex.BottomNavigationBar(),
    );
  }
}
