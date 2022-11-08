// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:lottie/lottie.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';

class RadiosPage extends ConsumerWidget {
  static const icon = Icon(Icons.radio_button_checked_outlined);
  static const title = Text('Radios');

  static final _logger = Logger((RadiosPage).toString());

  static const _tabs = <Widget>[
    MiTab(
      tooltip: 'Radios',
      icon: icon,
    ),
    MiTab(
      tooltip: 'Toggle buttons',
      icon: Icon(Icons.more_horiz),
    ),
  ];

  const RadiosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(enableActionsProvider);

    return MiDefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
      builder: (context) {
        return Scaffold(
          appBar: ExAppBar(
            prominent: ref.watch(prominentProvider),
            icon: icon,
            title: title,
            bottom: ExTabBar(
              enabled: enabled,
              tabs: _tabs,
            ),
          ),
          body: const SafeArea(
            minimum: EdgeInsets.all(8),
            child: TabBarView(
              children: [
                _RadiosTab(),
                _ToggleButtonsTab(),
              ],
            ),
          ),
          bottomNavigationBar: const ExBottomNavigationBar(),
        );
      },
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}

//
// Radios tab
//

enum _Class { fighter, cleric, mage, thief }

class _RadioItem {
  final Widget Function(bool checked) iconBuilder;
  final Widget text;
  const _RadioItem({required this.iconBuilder, required this.text});
}

final _radioItems = <_Class, _RadioItem>{
  _Class.fighter: _RadioItem(
    iconBuilder: (checked) =>
        checked ? const Icon(Icons.gpp_good_outlined) : const Icon(Icons.shield_outlined),
    text: const Text('Fighter'),
  ),
  _Class.cleric: _RadioItem(
    iconBuilder: (_) => const Icon(Icons.emergency_outlined),
    text: const Text('Cleric'),
  ),
  _Class.mage: _RadioItem(
    iconBuilder: (_) => const Icon(Icons.auto_fix_normal_outlined),
    text: const Text('Mage'),
  ),
  _Class.thief: _RadioItem(
    iconBuilder: (checked) =>
        checked ? const Icon(Icons.lock_open) : const Icon(Icons.lock_outlined),
    text: const Text('Thief'),
  ),
};

final _classProvider = StateProvider((ref) => _Class.fighter);

class _RadiosTab extends ConsumerWidget {
  static final _logger = Logger((_RadiosTab).toString());

  const _RadiosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final class_ = ref.watch(_classProvider);

    return Column(
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: _radioItems.keys.map(
              (key) {
                final item = _radioItems[key]!;
                return MiRadioListTile<_Class>(
                  enabled: enableActions,
                  value: key,
                  groupValue: class_,
                  title: MiIcon(
                    icon: item.iconBuilder(key == class_),
                    text: item.text,
                  ),
                  onChanged: (value) {
                    ref.read(_classProvider.notifier).state = value!;
                  },
                );
              },
            ).toList(),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: IconTheme(
            data: IconThemeData(
              color: Theme.of(context).disabledColor,
              size: 60,
            ),
            child: _radioItems[class_]!.iconBuilder(true),
          ),
        ),
      ],
    );
  }
}

//
// Toggle buttons tab
//

// https://lottiefiles.com/301-search-location
const _lottie1 =
    'https://assets7.lottiefiles.com/datafiles/bef3daa39adedbe065d5efad0ae5ccb3/search.json';
// https://lottiefiles.com/94-soda-loader
const _lottie2 = 'https://assets1.lottiefiles.com/datafiles/cFpiJtSizfCSZyW/data.json';

const _toggleItems = <Widget>[
  Text('Soda'),
  Text('Mint'),
  Text('Lemon'),
  Text('Orange'),
  Text('Straw\nberry'),
  Text('Grape'),
  Text('Milk'),
  Text('Cola'),
];

const _toggleItemColors = <Color>[
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.red,
  Colors.purple,
  Color(0xFFEEEEEE),
  Colors.brown,
];

final _selectedProvider = StateProvider((ref) => 0);

class MiToggleButtons extends StatelessWidget {
  final bool enabled;
  final int? split;
  final List<Widget> children;
  final List<bool> isSelected;
  final ValueChanged<int>? onPressed;

  const MiToggleButtons({
    super.key,
    this.enabled = true,
    this.split,
    required this.children,
    required this.isSelected,
    this.onPressed,
  })  : assert(children.length == isSelected.length),
        assert(split == null || split >= 2);

  @override
  Widget build(BuildContext context) {
    if (split == null) {
      return ToggleButtons(
        isSelected: isSelected,
        onPressed: enabled ? onPressed : null,
        children: children,
      );
    }

    final n = split!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i += n)
          ToggleButtons(
            isSelected: isSelected.skip(i).take(n).toList(),
            onPressed: enabled ? (index) => onPressed?.call(index + i) : null,
            children: children.skip(i).take(n).toList(),
          ),
      ],
    );
  }
}

class _ToggleButtonsTab extends ConsumerWidget {
  static final _logger = Logger((_selectedProvider).toString());

  const _ToggleButtonsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final selected = ref.watch(_selectedProvider);
    final flags = _toggleItems.mapIndexed((index, _) => index == selected).toList();

    return MiDefaultTabController(
      length: _toggleItems.length,
      initialIndex: selected,
      builder: (context) {
        return Column(
          children: [
            MiToggleButtons(
              enabled: enableActions,
              split: MediaQuery.of(context).orientation == Orientation.landscape ? null : 3,
              isSelected: flags,
              onPressed: (index) {
                ref.read(_selectedProvider.notifier).state = index;
                DefaultTabController.of(context)?.index = index;
              },
              children: _toggleItems,
            ),
            const Divider(),
            Expanded(
              child: TabBarView(
                children: _toggleItemColors.mapIndexed(
                  (index, color) {
                    final url = index == 6 ? _lottie1 : _lottie2;
                    return ColoredBox(
                      color: color.withAlpha(64),
                      child: MiAnimationController(
                        builder: (_, controller, __) {
                          return Lottie.network(
                            url,
                            controller: controller,
                            repeat: true,
                            onLoaded: (composition) {
                              _logger.fine('onLoaded: ${composition.duration}');
                              controller.duration = composition.duration;
                              controller.reset();
                              controller.forward();
                            },
                          );
                        },
                        onCompleted: (controller) {
                          controller.reset();
                          controller.forward();
                        },
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
