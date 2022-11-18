// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

final _pageItems = <String, String>{
  'Aamon': 'https://upload.wikimedia.org/wikipedia/commons/e/e4/Aamon.jpg',
  'Abigor': 'https://upload.wikimedia.org/wikipedia/commons/4/43/Abigor.jpg',
  'Abraxas':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/ABRAXAS_INFERNAL_DICTIONARY.jpg/575px-ABRAXAS_INFERNAL_DICTIONARY.jpg',
  'Adramelech':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Adramelech.jpg/531px-Adramelech.jpg',
}.entries.toList();

// TODO: Lock into stateful widget.
final _pageController = PageController();

final _pageIndexProvider = StateProvider((ref) => 0);

class PageViewPage extends ConsumerWidget {
  static const icon = Icon(Icons.auto_stories_outlined);
  static const title = Text('Page view');

  static final _logger = Logger((PageViewPage).toString());

  const PageViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);
    final pageIndex = ref.watch(_pageIndexProvider);

    Future<void> animateToPage(int index) async {
      return _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    return Scaffold(
      appBar: ExAppBar(
        prominent: ref.watch(prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 8),
        child: MiVerticalFrame(
          bottom: ListTile(
            leading: MiIconButton(
              enabled: enabled && pageIndex > 0,
              onPressed: () async {
                await animateToPage(pageIndex - 1);
              },
              icon: const Icon(Icons.arrow_back),
            ),
            trailing: MiIconButton(
              enabled: enabled && pageIndex < _pageItems.length - 1,
              onPressed: () async {
                await animateToPage(pageIndex + 1);
              },
              icon: const Icon(Icons.arrow_forward),
            ),
            title: const Text('TBD'),
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pageItems.length,
            onPageChanged: (index) {
              ref.read(_pageIndexProvider.notifier).state = index;
            },
            itemBuilder: (context, index) {
              final item = _pageItems[index];
              return MiVerticalFrame(
                top: ListTile(
                  title: Text(item.key),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      return Image.network(
                        item.value,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.contain,
                        frameBuilder: (_, child, frame, __) => frame == null
                            ? const Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              )
                            : child,
                      );
                    },
                  ),
                ),
              );
            },
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

    return MiVerticalFrame(
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
