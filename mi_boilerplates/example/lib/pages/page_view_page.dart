// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import 'ex_app_bar.dart' as ex;

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

    final enabled = ref.watch(ex.enableActionsProvider);
    final pageItems = ref.watch(_pageItemsProvider);
    final pageIndex = ref.watch(_pageIndexProvider).value;

    return ex.Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: icon,
        title: title,
      ),
      body: pageItems.when(
        data: (items) {
          return mi.ExpandedColumn(
            bottom: ListTile(
              leading: IconButton(
                onPressed: enabled && pageIndex > 0
                    ? () {
                        _pageIndexNotifier.value = pageIndex - 1;
                      }
                    : null,
                icon: const Icon(Icons.arrow_back),
              ),
              trailing: IconButton(
                onPressed: enabled && pageIndex < items.length - 1
                    ? () {
                        _pageIndexNotifier.value = pageIndex + 1;
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward),
              ),
              title: Center(child: Text('${pageIndex + 1} / ${items.length}')),
              // title: mi.MiPageIndicator(
              //   length: items.length,
              //   index: pageIndex,
              //   onSelected: (index) {
              //     _pageIndexNotifier.value = index;
              //   },
              // ),
            ),
            child: mi.PageView.builder(
              enabled: enabled,
              initialPage: pageIndex,
              pageNotifier: _pageIndexNotifier,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final uri = item.referenceUrl?.let((it) => Uri.tryParse(it));
                return mi.ExpandedColumn(
                  top: mi.Row(
                    flexes: const [1, 0],
                    children: [
                      ListTile(
                        title: Tooltip(
                          message: item.referenceUrl ?? '',
                          child: Text(item.name),
                        ),
                        subtitle: (item.description ?? '').let(
                          (it) => Tooltip(
                            message: it,
                            child: Text(
                              it,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        onTap: enabled && uri != null
                            ? () {
                                _logger.fine('uri=$uri');
                                launchUrl(uri);
                              }
                            : null,
                      ),
                      mi.GridPopupMenuButton(
                        tooltip: '',
                        items: items
                            .map(
                              (item) => mi.GridItem(
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                        offset: const Offset(1, kToolbarHeight),
                        onSelected: (index) {
                          ref.read(_pageIndexProvider.notifier).value = index;
                        },
                      ),
                    ],
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
                                : InteractiveViewer(
                                    child: p
                                            .extension(item.imageUrl)
                                            .let((it) => it == '.jpg' || it == '.jpeg')
                                        ? child
                                        : ColoredBox(
                                            color: Colors.white,
                                            child: child,
                                          ),
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
      bottomNavigationBar: const ex.BottomNavigationBar(),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
