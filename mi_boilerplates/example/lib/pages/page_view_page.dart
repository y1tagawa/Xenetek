// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';
import 'package:path/path.dart' as p;

import 'ex_app_bar.dart';

const _noImageAvailableUrl =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/240px-No_image_available.svg.png';

class _PageItem {
  final String name;
  final String imageUrl;
  final String? referenceUrl;
  final String? description;

  const _PageItem({
    required this.name,
    required this.imageUrl,
    this.referenceUrl,
    this.description,
  });
}

final _pageItemsProvider = FutureProvider((ref) async {
  // ignore: unused_local_variable
  final logger = Logger('_pageItemsProvider');

  final data = json.decode(
    await rootBundle.loadString('assets/pandemonium.json'),
  ) as Map<String, Object?>;

  final list = <_PageItem>[];
  for (final item in data.entries) {
    final name = item.key;
    if (name.isNotEmpty) {
      final value = item.value as Map<String, Object?>;
      list.add(
        _PageItem(
          name: name,
          imageUrl: value['imageUrl'] as String? ?? _noImageAvailableUrl,
          referenceUrl: value['referenceUrl'] as String?,
          description: value['description'] as String?,
        ),
      );
    }
  }
  list.sort((a, b) => a.name.compareTo(b.name));
  return list;
});

final _pageIndexNotifier = ValueNotifier(0);
final _pageIndexProvider = ChangeNotifierProvider((ref) => _pageIndexNotifier);

class PageViewPage extends ConsumerWidget {
  static const icon = Icon(Icons.auto_stories_outlined);
  static const title = Text('Page view');

  static final _logger = Logger((PageViewPage).toString());

  const PageViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);
    final pageItems = ref.watch(_pageItemsProvider);
    final pageIndex = ref.watch(_pageIndexProvider).value;

    return Scaffold(
      appBar: ExAppBar(
        prominent: ref.watch(prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 8),
        child: pageItems.when(
          data: (items) {
            return MiExpandedColumn(
              bottom: ListTile(
                leading: MiIconButton(
                  enabled: enabled && pageIndex > 0,
                  onPressed: () {
                    _pageIndexNotifier.value = pageIndex - 1;
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                trailing: MiIconButton(
                  enabled: enabled && pageIndex < items.length - 1,
                  onPressed: () {
                    _pageIndexNotifier.value = pageIndex + 1;
                  },
                  icon: const Icon(Icons.arrow_forward),
                ),
                title: Center(child: Text('${pageIndex + 1} / ${items.length}')),
                // title: MiPageIndicator(
                //   length: items.length,
                //   index: pageIndex,
                //   onSelected: (index) {
                //     _pageIndexNotifier.value = index;
                //   },
                // ),
              ),
              child: MiPageView.builder(
                enabled: enabled,
                initialPage: pageIndex,
                pageNotifier: _pageIndexNotifier,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return MiExpandedColumn(
                    top: MiGridPopupMenuButton(
                      items: items
                          .map(
                            (item) => MiGridItem(
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      offset: const Offset(1, kToolbarHeight),
                      onSelected: (index) {
                        ref.read(_pageIndexProvider.notifier).value = index;
                      },
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: item.description?.let((it) => Text(it)),
                        trailing: const Icon(Icons.more_vert),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: LayoutBuilder(
                        builder: (_, constraints) {
                          return SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.contain,
                              frameBuilder: (_, child, frame, __) => frame == null
                                  ? const Align(
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(),
                                    )
                                  : p
                                          .extension(item.imageUrl)
                                          .let((it) => it == '.jpg' || it == '.jpeg')
                                      ? child
                                      : ColoredBox(
                                          color: Colors.white,
                                          child: child,
                                        ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
          error: (message, stackTrace) => Text(message.toString()),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
      bottomNavigationBar: const ExBottomNavigationBar(),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
