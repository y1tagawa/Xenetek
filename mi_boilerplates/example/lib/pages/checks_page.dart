// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import 'ex_app_bar.dart';
import 'knight_indicator.dart';

//
// Checkbox examples page.
//

final _random = math.Random();

class ChecksPage extends ConsumerWidget {
  static const icon = Icon(Icons.check_box_outlined);
  static const title = Text('Checks');

  static final _logger = Logger((ChecksPage).toString());

  static const _tabs = <Widget>[
    MiTab(
      tooltip: 'Checkbox',
      icon: icon,
    ),
    MiTab(
      tooltip: 'Check menu',
      icon: Icon(Icons.more_vert),
    ),
    MiTab(
      tooltip: 'Toggle buttons',
      icon: Icon(Icons.more_horiz),
    ),
  ];

  const ChecksPage({super.key});

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
                _CheckboxTab(),
                _CheckMenuTab(),
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
// Checkbox tab
//

// But see also https://pub.dev/packages/flutter_treeview ,
// https://pub.dev/packages/flutter_simple_treeview .

class _CheckItem {
  final StateProvider<bool> provider;
  final Widget icon;
  final Widget text;
  const _CheckItem({
    required this.provider,
    required this.icon,
    required this.text,
  });
}

final _boxCheckProvider = StateProvider((ref) => true);
final _textCheckProvider = StateProvider((ref) => true);
final _checkCheckProvider = StateProvider((ref) => true);

final _checkItems = [
  _CheckItem(
    provider: _boxCheckProvider,
    icon: const Icon(Icons.square_outlined),
    text: const Text('Box'),
  ),
  _CheckItem(
    provider: _textCheckProvider,
    icon: const Icon(Icons.subject),
    text: const Text('Text'),
  ),
  _CheckItem(
    provider: _checkCheckProvider,
    icon: const Icon(Icons.check),
    text: const Text('Check'),
  ),
];

const _tallyIcons = <Icon>[
  Icon(null),
  Icon(Icons.square_outlined), // 1
  Icon(Icons.subject), // 2
  Icon(Icons.article_outlined),
  Icon(Icons.check), // 4
  Icon(Icons.check_box_outlined),
  Icon(Icons.playlist_add_check_outlined),
  Icon(Icons.fact_check_outlined),
];

class _CheckboxTab extends ConsumerWidget {
  const _CheckboxTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final box = ref.watch(_boxCheckProvider);
    final text = ref.watch(_textCheckProvider);
    final check = ref.watch(_checkCheckProvider);

    final tallyIcon = _tallyIcons[(box ? 1 : 0) + (text ? 2 : 0) + (check ? 4 : 0)];

    void setTally(bool value) {
      ref.read(_boxCheckProvider.notifier).state = value;
      ref.read(_textCheckProvider.notifier).state = value;
      ref.read(_checkCheckProvider.notifier).state = value;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          MiExpansionTile(
            enabled: enableActions,
            initiallyExpanded: true,
            // ExpansionTileに他のウィジェットを入れるケースは稀だろうからカスタムウィジェットはまだ作らない
            leading: Checkbox(
              value: (box && text && check)
                  ? true
                  : (box || text || check)
                      ? null
                      : false,
              tristate: true,
              onChanged: enableActions
                  ? (value) {
                      setTally(value != null);
                    }
                  : null,
            ),
            title: MiIcon(
              icon: tallyIcon,
              text: const Text('Tally'),
            ),
            children: _checkItems.map(
              (item) {
                return CheckboxListTile(
                  enabled: enableActions,
                  value: ref.read(item.provider),
                  contentPadding: const EdgeInsets.only(left: 28),
                  title: MiIcon(
                    icon: item.icon,
                    text: item.text,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    ref.read(item.provider.notifier).state = value!;
                  },
                );
              },
            ).toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: IconTheme.merge(
              data: IconThemeData(
                size: 60,
                color: Theme.of(context).disabledColor,
              ),
              child: MiFade(child: tallyIcon),
            ),
          ),
        ],
      ),
    );
  }
}

//
// Check menu tab
//

final _menuItems = <String, Color>{
  "Red": Colors.red.withOpacity(0.5),
  "Blue": Colors.blue.withOpacity(0.5),
};

final _menuCheckListProvider = StateProvider(
  (ref) => List<bool>.filled(_menuItems.length, false),
);

final _snowFlakeX1 = List<double>.filled(_menuItems.length, 0.0);
final _snowFlakeX2 = List<double>.filled(_menuItems.length, 0.0);
final _snowFlakeY = List<double>.filled(_menuItems.length, 0.0);
final _snowFlakeColors = _menuItems.values.toList();

class _SnowFlake {
  final double x;
  final double y;
  final Color color;
  const _SnowFlake({required this.x, required this.y, required this.color});
}

class _SnowPainter extends CustomPainter {
  final List<_SnowFlake> snowFlakes;

  const _SnowPainter({required this.snowFlakes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint_ = Paint();
    paint_.style = PaintingStyle.fill;

    void paintSnowFlake(_SnowFlake snowFlake) {
      final c = Offset(snowFlake.x * size.width, snowFlake.y * size.height);
      paint_.color = snowFlake.color;
      canvas.drawCircle(c, 6, paint_);
    }

    for (final snowFlake in snowFlakes) {
      paintSnowFlake(snowFlake);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _CheckMenuTab extends ConsumerWidget {
  // ignore: unused_field
  static final _logger = Logger((_CheckMenuTab).toString());

  const _CheckMenuTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(enableActionsProvider);
    final menuCheckList = ref.watch(_menuCheckListProvider);

    return Column(
      children: [
        MiRow(
          flexes: const [2, 3],
          children: [
            MiButtonListTile(
              enabled: enabled,
              onPressed: () {
                ref.read(_menuCheckListProvider.notifier).state =
                    List<bool>.filled(_menuItems.length, false);
              },
              icon: const Icon(Icons.refresh),
              text: const Text('Reset'),
            ),
            PopupMenuButton<int>(
              enabled: enabled,
              tooltip: '',
              itemBuilder: (context) {
                return [
                  ..._menuItems.entries.mapIndexed(
                    (index, item) => MiCheckPopupMenuItem<int>(
                      value: index,
                      checked: menuCheckList[index],
                      child: MiIcon(
                        icon: MiColorChip(color: item.value),
                        text: Text(item.key),
                      ),
                    ),
                  ),
                ];
              },
              onSelected: (index) {
                final checked = !menuCheckList[index];
                if (checked) {
                  _snowFlakeX1[index] = _random.nextDouble();
                  _snowFlakeX2[index] = _random.nextDouble();
                }
                ref.read(_menuCheckListProvider.notifier).state =
                    menuCheckList.replaced(index, checked);
              },
              offset: const Offset(1, 0),
              child: ListTile(
                enabled: enabled,
                trailing: const Icon(Icons.more_vert),
              ),
            ),
          ],
        ),
        const Divider(),
        Container(
          width: 120,
          height: 120,
          color: Colors.black,
          padding: const EdgeInsets.all(1),
          child: ClipRect(
            child: MiAnimationController(
              duration: const Duration(seconds: 6),
              builder: (context, controller, _) {
                return AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    final snowFlakes = <_SnowFlake>[];
                    for (int index = 0; index < _menuItems.length; ++index) {
                      if (menuCheckList[index]) {
                        snowFlakes.add(_SnowFlake(
                          x: _snowFlakeX1[index],
                          y: controller.value,
                          color: _snowFlakeColors[index],
                        ));
                        snowFlakes.add(_SnowFlake(
                          x: _snowFlakeX2[index],
                          y: (controller.value + 0.5) % 1.0,
                          color: _snowFlakeColors[index],
                        ));
                      }
                    }
                    return CustomPaint(
                      painter: _SnowPainter(
                        snowFlakes: snowFlakes,
                      ),
                      willChange: true,
                    );
                  },
                );
              },
              onInitialized: (controller) {
                controller.forward();
              },
              onCompleted: (controller) {
                controller.reset();
                controller.forward();
              },
            ),
          ),
        ),
      ],
    );
  }
}

//
// Toggle buttons tab
//

final _toggleProvider =
    StateProvider<List<bool>>((ref) => List.filled(KnightIndicator.items.length, false));

class _ToggleButtonsTab extends ConsumerWidget {
  static final _logger = Logger((_ToggleButtonsTab).toString());

  const _ToggleButtonsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableActions = ref.watch(enableActionsProvider);
    final toggle = ref.watch(_toggleProvider);
    _logger.fine(toggle.length);

    return SingleChildScrollView(
      child: Column(
        children: [
          ToggleButtons(
            isSelected: toggle,
            onPressed: enableActions
                ? (index) {
                    ref.read(_toggleProvider.notifier).state =
                        toggle.replaced(index, !toggle[index]);
                  }
                : null,
            children: KnightIndicator.items.entries
                .map(
                  (entry) => MiIcon(
                    icon: entry.value,
                    tooltip: entry.key,
                  ),
                )
                .toList(),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: IconTheme.merge(
              data: IconThemeData(
                color: Theme.of(context).disabledColor,
              ),
              child: KnightIndicator(equipped: toggle),
            ),
          ),
        ],
      ),
    );
  }
}
