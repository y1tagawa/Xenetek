// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'ex_app_bar.dart' as ex;

//
// Grids example page.
//

// https://commons.wikimedia.org/wiki/Category:Engraved_illustrations_in_Paradise_Lost_(4th_edition,_1688)
const _imageUrls = <String>[
  'https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/MILTON_%281695%29_p016_PL_1.jpg/314px-MILTON_%281695%29_p016_PL_1.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/MILTON_%281695%29_p044_PL_2.jpg/313px-MILTON_%281695%29_p044_PL_2.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/MILTON_%281695%29_p080_PL_3.jpg/300px-MILTON_%281695%29_p080_PL_3.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/MILTON_%281695%29_p106_PL_4.jpg/311px-MILTON_%281695%29_p106_PL_4.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/MILTON_%281695%29_p142_PL_5.jpg/306px-MILTON_%281695%29_p142_PL_5.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/MILTON_%281695%29_p174_PL_6.jpg/309px-MILTON_%281695%29_p174_PL_6.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/MILTON_%281695%29_p206_PL_7.jpg/307px-MILTON_%281695%29_p206_PL_7.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/MILTON_%281695%29_p228_PL_8.jpg/311px-MILTON_%281695%29_p228_PL_8.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/MILTON_%281695%29_p252_PL_9.jpg/305px-MILTON_%281695%29_p252_PL_9.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/MILTON_%281695%29_p292_PL_10.jpg/301px-MILTON_%281695%29_p292_PL_10.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/MILTON_%281695%29_p330_PL_11.jpg/309px-MILTON_%281695%29_p330_PL_11.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/MILTON_%281695%29_p362_PL_12.jpg/296px-MILTON_%281695%29_p362_PL_12.jpg',
];

int _pageIndex = 0;

class GridsPage extends ConsumerWidget {
  static const icon = Icon(Icons.grid_view);
  static const title = Text('Grids');

  const GridsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final enableActions = ref.watch(enableActionsProvider);

    return ex.Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: icon,
        title: title,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 1 / 1.5,
              ),
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                return Tooltip(
                  message: 'PL. ${index + 1}',
                  child: InkWell(
                    onTap: () {
                      _pageIndex = index;
                      context.push('/grids/detail');
                    },
                    child: Hero(
                      tag: 'plate${index + 1}',
                      child: Image.network(
                        _imageUrls[index],
                        fit: BoxFit.fill,
                        frameBuilder: (_, child, frame, __) => frame == null
                            ? const Center(child: CircularProgressIndicator())
                            : child,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const ListTile(
            title: Text('From \'The Poetical Works of John Milton\' (1695).'),
          ),
        ],
      ),
      bottomNavigationBar: const ex.BottomNavigationBar(),
    );
  }
}

//
// Detail page.
//

class GridDetailPage extends ConsumerWidget {
  const GridDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ex.Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: GridsPage.icon,
        title: Text('PL. ${_pageIndex + 1}'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  context.pop();
                },
                child: Hero(
                  tag: 'plate${_pageIndex + 1}',
                  child: Image.network(
                    _imageUrls[_pageIndex],
                    fit: BoxFit.contain,
                    frameBuilder: (_, child, frame, __) =>
                        frame == null ? const Center(child: CircularProgressIndicator()) : child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ex.BottomNavigationBar(),
    );
  }
}
