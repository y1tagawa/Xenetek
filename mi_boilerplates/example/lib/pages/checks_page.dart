// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;

//
// Checkbox examples page.
//

final _random = math.Random();

class ChecksPage extends ConsumerWidget {
  static const icon = Icon(Icons.check_box_outlined);
  static const title = Text('Checks');

  static final _logger = Logger((ChecksPage).toString());

  static const _tabs = <Widget>[
    mi.Tab(
      tooltip: 'Checkbox',
      icon: icon,
    ),
    mi.Tab(
      tooltip: 'Check menu',
      icon: Icon(Icons.more_vert),
    ),
  ];

  const ChecksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);

    return mi.DefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
      builder: (context) {
        return ex.Scaffold(
          appBar: ex.AppBar(
            prominent: ref.watch(ex.prominentProvider),
            icon: icon,
            title: title,
            bottom: ex.TabBar(
              enabled: enabled,
              tabs: _tabs,
            ),
          ),
          body: const TabBarView(
            children: [
              _CheckboxTab(),
              _CheckMenuTab(),
            ],
          ),
          bottomNavigationBar: const ex.BottomNavigationBar(),
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

//<editor-fold>

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
    final enableActions = ref.watch(ex.enableActionsProvider);
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
          mi.ExpansionTile(
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
            title: mi.Label(
              icon: tallyIcon,
              text: const Text('Tally'),
            ),
            children: _checkItems.map(
              (item) {
                return CheckboxListTile(
                  enabled: enableActions,
                  value: ref.read(item.provider),
                  contentPadding: const EdgeInsets.only(left: 28),
                  title: mi.Label(
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
              child: mi.Fade(child: tallyIcon),
            ),
          ),
        ],
      ),
    );
  }
}

//</editor-fold>

//
// Check menu tab
//

//<editor-fold>

final _menuItems = <String, Color>{
  "Blue": Colors.blue[200]!,
  "Cyan": Colors.cyan[200]!,
  "Green": Colors.green[200]!,
  "Yellow": Colors.yellow[200]!,
  "Orange": Colors.orange[200]!,
  "Red": Colors.red[200]!,
  "Purple": Colors.deepPurple[200]!,
};

final _menuItemColors = List.unmodifiable(_menuItems.values);

//<editor-fold>
// 雪の窓

class _SnowFlake {
  double x;
  double y;
  double dx;
  double dy;
  double w;
  Color color;
  double radius;

//<editor-fold desc="Data Methods">

  _SnowFlake({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.w,
    required this.color,
    required this.radius,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _SnowFlake &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          dx == other.dx &&
          dy == other.dy &&
          w == other.w &&
          color == other.color &&
          radius == other.radius);

  @override
  int get hashCode =>
      x.hashCode ^
      y.hashCode ^
      dx.hashCode ^
      dy.hashCode ^
      w.hashCode ^
      color.hashCode ^
      radius.hashCode;

  @override
  String toString() {
    return '_SnowFlake{'
        ' x: $x,'
        ' y: $y,'
        ' dx: $dx,'
        ' dy: $dy,'
        ' w: $w,'
        ' color: $color,'
        ' radius: $radius,'
        '}';
  }

  _SnowFlake copyWith({
    double? x,
    double? y,
    double? dx,
    double? dy,
    double? w,
    Color? color,
    double? radius,
  }) {
    return _SnowFlake(
      x: x ?? this.x,
      y: y ?? this.y,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      w: w ?? this.w,
      color: color ?? this.color,
      radius: radius ?? this.radius,
    );
  }

  //</editor-fold>
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
      canvas.drawCircle(c, snowFlake.radius, paint_);
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

class _SnowyWindow extends StatefulWidget {
  final List<int> keys;
  final double speed; // 窓からの距離の逆数w=1における落下速度(窓の高さ/1s)
  final int intensity; // 雪の強さ
  final double wind; // 風の強さ(w=1)
  final double radius; // 雪片の半径[pix](w=1の時)

  const _SnowyWindow({
    required this.keys,
    required this.speed,
    required this.intensity,
    required this.wind,
    required this.radius,
  }) : assert(intensity > 0);

  @override
  State<StatefulWidget> createState() => _SnowyWindowState();
}

class _SnowyWindowState extends State<_SnowyWindow> {
  static const _dy = 1.0 / 60;

  static final _logger = Logger((_SnowyWindowState).toString());

  final _snowFlakes = <int, List<_SnowFlake>>{};

  List<_SnowFlake> _newSnowFlakes(int key, double y) {
    _logger.fine('[i] _newSnowFlakes $key $y');
    // 指定のキーに対応する雪片を追加。
    final t = <_SnowFlake>[];
    // TODO: key to colorのパラメタ化
    // _randomも
    final color = _menuItemColors[key];
    for (int i = 0; i < widget.intensity; ++i) {
      final w = (i * 0.8) / widget.intensity + 1.0;
      t.add(_SnowFlake(
        x: _random.nextDouble(),
        y: y,
        dx: (_random.nextDouble() - 0.5) * widget.wind,
        dy: widget.speed * _dy * w,
        w: i.toDouble() / widget.intensity,
        color: color.withOpacity(0.5 * w),
        radius: widget.radius * w,
      ));
    }
    return t.also((it) {
      _logger.fine('[o] _newSnowFlakes $it');
    });
  }

  void _updateSnow(_SnowFlake snowFlake) {
    snowFlake.x += snowFlake.dx;
    snowFlake.y += snowFlake.dy;
    // 窓下に出たら再利用
    if (snowFlake.y > 1.0) {
      snowFlake.x = _random.nextDouble();
      snowFlake.dx = (_random.nextDouble() - 0.5) * widget.wind * snowFlake.w;
      snowFlake.y = -0.1;
    }
  }

  void _update() {
    // 現在表示中のキーが削除されたら、表示リストから削除する。
    _snowFlakes.removeWhere((key, value) => !widget.keys.contains(key));
    // 新しいキーが追加されたら、キーに対応するデータを作成、表示リストに追加する。
    var y = -0.1;
    for (final key in widget.keys) {
      if (!_snowFlakes.containsKey(key)) {
        _snowFlakes[key] = _newSnowFlakes(key, y);
        // 複数のキーが同時に追加される場合、重なると変なので、y初期値を散らばす。
        y -= _random.nextDouble() * 0.8;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _update();
  }

  @override
  void dispose() {
    _snowFlakes.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SnowyWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _update();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: mi.AnimationControllerWidget(
        duration: const Duration(seconds: 1),
        onInitialized: (controller) {
          controller.forward();
        },
        onEnd: (controller) {
          controller.reset();
          controller.forward();
        },
        onUpdate: (controller) {
          _snowFlakes.forEach((key, value) {
            for (final snowFlake in value) {
              _updateSnow(snowFlake);
            }
          });
        },
        builder: (context, controller, _) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final snowFlakes = <_SnowFlake>[];
              _snowFlakes.forEach((_, value) => snowFlakes.addAll(value));
              return CustomPaint(
                painter: _SnowPainter(
                  snowFlakes: snowFlakes,
                ),
                willChange: true,
              );
            },
          );
        },
      ),
    );
  }
}

//</editor-fold>

final _menuCheckListProvider =
    StateProvider((ref) => List<bool>.filled(_menuItems.length, false).replacedAt(0, true));

class _CheckMenuTab extends ConsumerWidget {
  // ignore: unused_field
  static final _logger = Logger((_CheckMenuTab).toString());

  const _CheckMenuTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(ex.enableActionsProvider);
    final menuCheckList = ref.watch(_menuCheckListProvider);

    final keys = mi.iota(menuCheckList.length).where((value) => menuCheckList[value]).toList();

    return Column(
      children: [
        mi.Row(
          flexes: const [1, 1],
          children: [
            mi.ButtonListTile(
              enabled: enabled && menuCheckList.any((value) => value),
              onPressed: () {
                ref.read(_menuCheckListProvider.notifier).state =
                    List<bool>.filled(_menuItems.length, false);
              },
              icon: const Icon(Icons.clear),
              text: const Text('Clear'),
            ),
            PopupMenuButton<int>(
              enabled: enabled,
              tooltip: '',
              itemBuilder: (context) {
                return [
                  ..._menuItems.entries.mapIndexed(
                    (index, item) => mi.CheckPopupMenuItem<int>(
                      value: index,
                      checked: menuCheckList[index],
                      child: mi.Label(
                        icon: mi.ColorChip(color: item.value),
                        text: Text(item.key),
                      ),
                    ),
                  ),
                ];
              },
              onSelected: (index) {
                final checked = !menuCheckList[index];
                ref.read(_menuCheckListProvider.notifier).state =
                    menuCheckList.replacedAt(index, checked);
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
          child: _SnowyWindow(
            keys: keys,
            speed: 0.7, // s/cycle
            intensity: 3,
            wind: 0.003,
            radius: 3.0,
          ),
        ),
      ],
    );
  }
}

//</editor-fold>
