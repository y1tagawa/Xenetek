// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Tab, TabBar, TabBarView example page.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

const _imageWidth = 138.0;
const _imageHeight = 240.0;
// Public domain images.
const _imageUrls = [
  'https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/RWS_Tarot_00_Fool.jpg/137px-RWS_Tarot_00_Fool.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/RWS_Tarot_01_Magician.jpg/136px-RWS_Tarot_01_Magician.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/RWS_Tarot_02_High_Priestess.jpg/138px-RWS_Tarot_02_High_Priestess.jpg',
];

var _tabIndex = 0;

class TabViewPage extends ConsumerWidget {
  static const icon = Icon(Icons.folder_outlined);
  static const title = Text('Tab view');

  static const _tabs = [
    Tab(text: 'Zeroth'),
    Tab(text: 'First'),
    Tab(text: 'Second'),
  ];

  const TabViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('TabViewPage: build: $_tabIndex');

    // s.a. https://api.flutter.dev/flutter/material/TabController-class.html ,
    // https://api.flutter.dev/flutter/material/DefaultTabController-class.html .
    return DefaultTabController(
      length: _tabs.length,
      initialIndex: _tabIndex,
      child: Builder(builder: (BuildContext context) {
        final tabController = DefaultTabController.of(context)!;
        tabController.addListener(() {
          // save tab index to prepare rebuilding.
          if (!tabController.indexIsChanging) {
            debugPrint('TabViewPage: saving tab index ${tabController.index}');
            _tabIndex = tabController.index;
          }
        });
        return Scaffold(
          appBar: ExAppBar(
            prominent: ref.watch(prominentProvider),
            icon: icon,
            title: title,
            bottom: const TabBar(tabs: _tabs),
          ),
          body: TabBarView(
            children: _tabs.mapIndexed(
              (index, tab) {
                return MiExpandedColumn(
                  top: Text(
                    '${tab.text!} Tab',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ..._tabs.mapIndexed(
                          (i, tab) {
                            return MiTextButton(
                              enabled: i != index,
                              onPressed: () {
                                debugPrint('TabViewPage: setting tab index to $i');
                                tabController.index = i;
                              },
                              child: Text(tab.text!),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.network(
                            _imageUrls[index],
                            width: _imageWidth,
                            height: _imageHeight,
                            frameBuilder: (_, child, frame, __) =>
                                frame == null ? const CircularProgressIndicator() : child,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          bottomNavigationBar: const ExBottomNavigationBar(),
        );
      }),
    );
  }
}
