// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';
import 'ex_bottom_navigation_bar.dart';

const _imageUrls = <String>[
  // ゴッホ 星月夜
  'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg/970px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg',
  // レイトン フレイミング・ジューン
  'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Flaming_June%2C_by_Frederic_Lord_Leighton_%281830-1896%29.jpg/767px-Flaming_June%2C_by_Frederic_Lord_Leighton_%281830-1896%29.jpg',
];

final _images = <Widget?>[
  null,
  ..._imageUrls.map(
    (imageUrl) => Image.network(imageUrl),
  ),
];

final _tabbedProvider = StateProvider((ref) => false);
final _centerTitleProvider = StateProvider((ref) => false);
final _imageProvider = StateProvider<Widget?>((ref) => null);

int _tabIndex = 0;

class ProminentTopBarPage extends ConsumerWidget {
  static const icon = Icon(Icons.inbox_outlined);
  static const title = Text('Prominent top bar');

  static final _logger = Logger((ProminentTopBarPage).toString());

  static const _tabs = <Widget>[
    MiTab(icon: Text('Dummy')),
    MiTab(icon: Text('Dummy')),
  ];

  const ProminentTopBarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final prominent = ref.watch(prominentProvider);
    final tabbed = ref.watch(_tabbedProvider);
    final centerTitle = ref.watch(_centerTitleProvider);
    final image = ref.watch(_imageProvider);

    final Widget? flexibleSpace = image != null
        ? FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: image,
          )
        : null;

    // https://commons.wikimedia.org/wiki/Category:Google_Art_Project
    // https://commons.wikimedia.org/wiki/File:Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg
    // https://en.wikipedia.org/wiki/Flaming_June
    // https://en.wikipedia.org/wiki/100_Great_Paintings
    // 白は鳥獣戯画で

    final body = SafeArea(
      minimum: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CheckboxListTile(
              value: prominent,
              onChanged: (value) {
                ref.read(prominentProvider.state).state = value!;
              },
              title: const Text('Prominent'),
            ),
            CheckboxListTile(
              value: tabbed,
              onChanged: (value) {
                ref.read(_tabbedProvider.state).state = value!;
              },
              title: const Text('Tabbed'),
            ),
            CheckboxListTile(
              value: centerTitle,
              onChanged: (value) {
                ref.read(_centerTitleProvider.state).state = value!;
              },
              title: const Text('Center title'),
            ),
            const Divider(),
            const Text('flexibleSpace'),
            ..._images.map(
              (image_) => RadioListTile<Widget?>(
                  value: image_,
                  groupValue: image,
                  title: image_ != null
                      ? SizedBox(
                          //https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/list_tile.dart#L1094
                          height: 48,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            clipBehavior: Clip.hardEdge,
                            child: image_,
                          ),
                        )
                      : const Icon(Icons.block_outlined),
                  onChanged: (value) {
                    ref.read(_imageProvider.state).state = image_;
                  }),
            ),
          ],
        ),
      ),
    );

    if (tabbed) {
      return MiDefaultTabController(
        length: _tabs.length,
        initialIndex: _tabIndex,
        builder: (context) {
          return Scaffold(
            appBar: ExAppBar(
              prominent: prominent,
              leading: icon,
              title: title,
              centerTitle: centerTitle,
              bottom: MiTabBar(tabs: _tabs),
              flexibleSpace: flexibleSpace,
            ),
            body: body,
            bottomNavigationBar: const ExBottomNavigationBar(),
          );
        },
      );
    } else {
      return Scaffold(
        appBar: ExAppBar(
          prominent: ref.watch(prominentProvider),
          leading: icon,
          title: title,
          centerTitle: centerTitle,
          flexibleSpace: flexibleSpace,
        ),
        body: body,
        bottomNavigationBar: const ExBottomNavigationBar(),
      );
    }
  }
}
