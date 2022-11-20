// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

const _noImageAvailableUrl =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/240px-No_image_available.svg.png';

class _PageItem {
  final String name;
  final String? imageUrl;
  final String? referenceUrl;
  final String? note;

  const _PageItem({
    required this.name,
    this.imageUrl,
    this.referenceUrl,
    this.note,
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
          note: value['note'] as String?,
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
                title: MiPageIndicator(
                  length: items.length,
                  index: pageIndex,
                  onSelected: (index) {
                    _pageIndexNotifier.value = index;
                  },
                ),
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
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      offset: const Offset(1, 0),
                      onSelected: (index) {
                        ref.read(_pageIndexProvider.notifier).value = index;
                      },
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: item.note?.let((it) => Text(it)),
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
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: ColoredBox(
                                color: Colors.white,
                                child: Image.network(
                                  item.imageUrl!,
                                  frameBuilder: (_, child, frame, __) => frame == null
                                      ? const Align(
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(),
                                        )
                                      : child,
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
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      bottomNavigationBar: const ExBottomNavigationBar(),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Framed scroll view tab
//

final _lengthProvider = StateProvider((ref) => 1);

const _length = [1, 20];

class _FramedScrollViewTab extends ConsumerWidget {
  static final _logger = Logger((_FramedScrollViewTab).toString());

  final Type content;

  const _FramedScrollViewTab({required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final lengthIndex = ref.watch(_lengthProvider);
    final length = _length[lengthIndex];

    final theme = Theme.of(context);

    final content_ = run(() {
      switch (content) {
        case (SingleChildScrollView):
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, top: 4, right: 24, bottom: 4),
              child: Container(
                width: double.infinity,
                height: kToolbarHeight * length,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text('Single child scroll view'),
              ),
            ),
          );

        default:
          return ListView.builder(
            itemCount: length,
            itemBuilder: (_, index) => ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text('List item #${index + 1}'),
            ),
          );
      }
    });

    return MiExpandedColumn(
      tops: [
        ListTile(
          title: const Text('Top'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<int>(
                value: 0,
                groupValue: lengthIndex,
                onChanged: (value) => ref.read(_lengthProvider.notifier).state = value!,
              ),
              const Text('1'),
              Radio<int>(
                value: 1,
                groupValue: lengthIndex,
                onChanged: (value) => ref.read(_lengthProvider.notifier).state = value!,
              ),
              const Text('20'),
            ],
          ),
        ),
        const Divider(),
      ],
      bottoms: const [
        Divider(),
        ListTile(
          title: Text('Bottom'),
        ),
      ],
      child: content_,
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
