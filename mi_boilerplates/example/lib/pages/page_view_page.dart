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

/// TODO: tooltip
class _DotIndicator extends StatelessWidget {
  final int length;
  final int index;
  final ValueChanged<int>? onSelected;
  final Widget? icon;
  final Color? iconColor;
  final double? iconSize;
  final Color? selectedIconColor;
  final double? selectedIconSize;
  final double? spacing;
  final double? runSpacing;
  final String? tooltip;

  const _DotIndicator({
    super.key,
    required this.length,
    required this.index,
    this.onSelected,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.selectedIconColor,
    this.selectedIconSize,
    this.spacing,
    this.runSpacing,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon_ = icon ?? const Icon(Icons.circle);
    final iconColor_ = iconColor ?? theme.unselectedIconColor;
    final iconSize_ = iconSize ?? 8;
    final selectedIconColor_ = selectedIconColor ?? theme.foregroundColor;
    final selectedIconSize_ = selectedIconSize ?? 12;

    return IconTheme.merge(
      data: IconThemeData(
        color: iconColor_,
        size: iconSize_,
      ),
      child: Tooltip(
        message: tooltip ?? 'Page ${index + 1}',
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: spacing ?? 2.0,
          runSpacing: runSpacing ?? 2.0,
          children: iota(length).map(
            (i) {
              Widget widget = i == index
                  ? IconTheme.merge(
                      data: IconThemeData(
                        color: selectedIconColor_,
                        size: selectedIconSize_,
                      ),
                      child: icon_,
                    )
                  : icon_;
              if (onSelected != null) {
                widget = InkWell(
                  onTap: () => onSelected?.call(i),
                  child: widget,
                );
              }
              return widget;
            },
          ).toList(),
        ),
      ),
    );
  }
}

final _pageNotifier = ValueNotifier(0);
final _pageProvider = ChangeNotifierProvider((ref) => _pageNotifier);

class PageViewPage extends ConsumerWidget {
  static const icon = Icon(Icons.auto_stories_outlined);
  static const title = Text('Page view');

  static final _logger = Logger((PageViewPage).toString());

  const PageViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);

    final pageIndex = ref.watch(_pageProvider).value;

    return Scaffold(
      appBar: ExAppBar(
        prominent: ref.watch(prominentProvider),
        icon: icon,
        title: title,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 8),
        child: MiExpandedColumn(
          bottom: ListTile(
            leading: MiIconButton(
              enabled: enabled && pageIndex > 0,
              onPressed: () {
                _pageNotifier.value = pageIndex - 1;
              },
              icon: const Icon(Icons.arrow_back),
            ),
            trailing: MiIconButton(
              enabled: enabled && pageIndex < _pageItems.length - 1,
              onPressed: () {
                _pageNotifier.value = pageIndex + 1;
              },
              icon: const Icon(Icons.arrow_forward),
            ),
            title: _DotIndicator(
              length: _pageItems.length,
              index: pageIndex,
              onSelected: (index) {
                _pageNotifier.value = index;
              },
            ),
          ),
          child: MiPageView.builder(
            initialPage: _pageNotifier.value,
            pageNotifier: _pageNotifier,
            viewportFraction: 0.8,
            itemCount: _pageItems.length,
            itemBuilder: (context, index) {
              final item = _pageItems[index];
              return MiExpandedColumn(
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
