// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Row;
import 'package:flutter/material.dart' as material show Row;
import 'package:logging/logging.dart';

Iterable<int> iota(int n, {int start = 0}) => Iterable<int>.generate(n, (i) => i + start);

T run<T>(T Function() fun) => fun();

extension ScopeFunctions<T> on T {
  T also(void Function(T it) fun) {
    fun(this);
    return this;
  }

  U let<U>(U Function(T it) fun) => fun(this);
}

extension DoubleHelper on double {
  static const degreeToRadian = math.pi / 180.0;
  static const radianToDegree = 180.0 / math.pi;

  double toRadian() => this * degreeToRadian;
  double toDegree() => this * radianToDegree;
}

extension ListHelper<T> on List<T> {
  List<T> added(T value) {
    final t = toList();
    t.add(value);
    return t;
  }

  List<T> moved(int oldIndex, int newIndex) {
    final t = toList();
    t.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, t.removeAt(oldIndex));
    return t;
  }

  List<T> removed(T value) {
    final t = toList();
    t.remove(value);
    return t;
  }

  List<T> removedAt(int index) {
    final t = toList();
    t.removeAt(index);
    return t;
  }

  List<T> replacedAt(int index, T value) {
    final t = toList();
    t[index] = value;
    return t;
  }
}

extension SetHelper<T> on Set<T> {
  Set<T> added(T value) {
    final t = toSet();
    t.add(value);
    return t;
  }

  Set<T> removed(T value) {
    final t = toSet();
    t.remove(value);
    return t;
  }
}

extension IterableHelper<T> on Iterable<T> {
  List<T> sorted({int Function<T>(T a, T b)? compare}) {
    final t = toList();
    t.sort(compare);
    return t;
  }
}

/// [DefaultTextStyle]+[IconTheme]
///
/// 頻出コード。末端でスタイル変更することになるのであまり公開したくないのだが……

class DefaultTextColor extends StatelessWidget {
  final Color? color;
  final Widget child;

  const DefaultTextColor({
    super.key,
    this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(color: color),
      child: IconTheme.merge(
        data: IconThemeData(color: color),
        child: child,
      ),
    );
  }
}

/// ラベル
///
/// * [icon]がnullの場合、アイコン部分は空白となる。

class Label extends StatelessWidget {
  final bool enabled;
  final Widget? icon;
  final TextDirection iconPosition;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHover;
  final double? spacing;
  final Widget? text;
  final String? tooltip;

  const Label({
    super.key,
    this.enabled = true,
    this.icon,
    this.iconPosition = TextDirection.ltr,
    this.onTap,
    this.onHover,
    this.spacing,
    this.text,
    this.tooltip,
  }) : assert(icon != null || text != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = enabled ? null : theme.disabledColor;

    Widget icon_ = icon ?? SizedBox.square(dimension: IconTheme.of(context).size ?? 24);

    if (text != null) {
      final spacing_ = spacing ?? 8.0;
      final spacer = spacing_ > 0.0 ? SizedBox(width: spacing_) : null;
      icon_ = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: iconPosition == TextDirection.rtl
            ? [
                if (spacer != null) spacer,
                text!,
                if (spacer != null) spacer,
                icon_,
              ]
            : [
                icon_,
                if (spacer != null) spacer,
                text!,
                if (spacer != null) spacer,
              ],
      );
    }

    icon_ = DefaultTextColor(
      color: textColor,
      child: icon_,
    );

    if (onTap != null || onHover != null) {
      icon_ = InkWell(
        onTap: enabled ? onTap : null,
        onHover: onHover,
        child: IgnorePointer(child: icon_),
      );
    }

    if (tooltip != null) {
      icon_ = Tooltip(
        message: tooltip ?? '',
        child: icon_,
      );
    }

    return icon_;
  }
}

/// カラーチップ
///
/// アイコンと同じ大きさのカラーチップ。[Color]がnullの場合、[Icons.block]を表示する。

class ColorChip extends StatelessWidget {
  final bool enabled;
  final Color? color;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHover;
  final double? size;
  final double margin;
  final double? spacing;
  final Widget? text;
  final String? tooltip;

  const ColorChip({
    super.key,
    this.enabled = true,
    required this.color,
    this.onTap,
    this.onHover,
    this.size,
    this.margin = 2,
    this.spacing,
    this.tooltip,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size_ = size ?? IconTheme.of(context).size ?? 24;

    return Label(
      enabled: enabled,
      icon: color == null
          ? Icon(
              Icons.block,
              size: size_,
            )
          : Container(
              padding: EdgeInsets.all(margin),
              width: size_,
              height: size_,
              child: ColoredBox(color: enabled ? color! : theme.disabledColor),
            ),
      onTap: onTap,
      onHover: onHover,
      spacing: spacing,
      text: text,
      tooltip: tooltip,
    );
  }
}

/// トグルアイコン

class ToggleIcon extends StatelessWidget {
  final bool checked;
  final Widget checkIcon;
  final Widget uncheckIcon;
  final Duration duration;

  const ToggleIcon({
    super.key,
    required this.checked,
    required this.checkIcon,
    required this.uncheckIcon,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: duration,
      crossFadeState: checked ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: checkIcon,
      secondChild: uncheckIcon,
    );
  }
}

/// [Image] (PNGとか)をアイコンにする
///
/// [SvgPicture]対応はflutter_svgに依存することになるので考え中。

class ImageIcon extends StatelessWidget {
  final Image image;
  final double? size;
  final Color? color;

  const ImageIcon({
    super.key,
    required this.image,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    return SizedBox.square(
      dimension: size ?? theme.size,
      child: Align(
        alignment: Alignment.center,
        child: Image(
          image: image.image,
          color: color ?? theme.color,
        ),
      ),
    );
  }
}

/// トグルアイコンボタン

class CheckIconButton extends StatelessWidget {
  final bool enabled;
  final bool checked;
  final double? iconSize;
  final ValueChanged<bool>? onChanged;
  final Widget? checkIcon;
  final Widget? uncheckIcon;
  final Duration? duration;

  const CheckIconButton({
    super.key,
    this.enabled = true,
    required this.checked,
    this.iconSize,
    this.onChanged,
    this.checkIcon,
    this.uncheckIcon,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled
          ? () {
              onChanged?.call(!checked);
            }
          : null,
      iconSize: iconSize,
      icon: AnimatedCrossFade(
        duration: duration ?? const Duration(milliseconds: 300),
        crossFadeState: checked ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: checkIcon ?? const Icon(Icons.check_box_outlined),
        secondChild: uncheckIcon ?? const Icon(Icons.check_box_outline_blank),
      ),
    );
  }
}

/// 直前の[child]と最新の[child]をクロスフェードする

class Fade extends StatefulWidget {
  final Duration duration;
  final Widget? placeHolder;
  final Widget? child;
  const Fade({
    // ignore: unused_element
    super.key,
    // ignore: unused_element
    this.duration = const Duration(milliseconds: 250),
    this.placeHolder,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _FadeState();
}

class _FadeState extends State<Fade> {
  // ignore: unused_field
  static final _logger = Logger((_FadeState).toString());

  late Widget? _firstChild;
  late Widget? _secondChild;
  late CrossFadeState _state;

  void _update() {
    if (_state == CrossFadeState.showFirst) {
      _secondChild = widget.child;
      _state = CrossFadeState.showSecond;
    } else {
      _firstChild = widget.child;
      _state = CrossFadeState.showFirst;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _firstChild = null;
    _secondChild = null;
    _state = CrossFadeState.showFirst;
    if (widget.child != null) {
      _update();
    }
  }

  @override
  void dispose() {
    _firstChild = null;
    _secondChild = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Fade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != (_state == CrossFadeState.showFirst ? _firstChild : _secondChild)) {
      _update();
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeHolder =
        widget.placeHolder ?? SizedBox.square(dimension: IconTheme.of(context).size ?? 24);
    return AnimatedCrossFade(
      firstChild: _firstChild ?? placeHolder,
      secondChild: _secondChild ?? placeHolder,
      crossFadeState: _state,
      duration: widget.duration,
    );
  }
}

/// 明示的にintの値をとる[Slider]

class IntSlider extends StatelessWidget {
  // ignore: unused_field
  static final _logger = Logger((IntSlider).toString());

  final bool enabled;
  final int value;
  final int min;
  final int max;
  final int? divisions;
  final String? label;
  final ValueChanged<int>? onChanged;
  // TODO: 必要になったら他のプロパティも

  const IntSlider({
    super.key,
    this.enabled = true,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.label,
    this.onChanged,
  }) : assert(divisions == null || (max > min && divisions % (max - min) == 0));

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value.toDouble(),
      min: min.toDouble(),
      max: max.toDouble(),
      divisions: divisions ?? (max - min),
      label: label,
      onChanged: enabled && onChanged != null
          ? (data) {
              final value_ = data.round();
              if (value_ != value) {
                onChanged!.call(value_);
              }
            }
          : null,
    );
  }
}

/// カスタム[Row]。
///
/// * [crossAxisAlignment]のデフォルト値を[WrapCrossAlignment.center]に変更。
/// * [flexes]を指定した場合、[children]の個々を[Flexible]でラップする。
/// * [spacing]を指定した場合、[children]の間に空間を空ける。

class Row extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final List<Widget> children;
  final List<int>? flexes;
  final FlexFit fit;
  final double spacing;

  const Row({
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    required this.children,
    this.flexes,
    this.fit = FlexFit.tight,
    this.spacing = 8,
  })  : assert(flexes == null || flexes.length == children.length),
        assert(spacing >= 0);

  Widget _flexChild(Widget child, int flex) {
    if (flex >= 0) {
      return Flexible(
        flex: flex,
        fit: fit,
        child: child,
      );
    } else {
      final width = -flex.toDouble();
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, minWidth: width),
        child: child,
      );
    }
  }

  List<Widget> _flexChildren() {
    final children_ = <Widget>[];
    children.forEachIndexed((index, child) {
      children_.add(_flexChild(child, flexes![index]));
    });
    return children_;
  }

  List<Widget> _spaceChildren() {
    final children_ = <Widget>[];
    final spacer = SizedBox(width: spacing);
    children.forEachIndexed((index, child) {
      if (index > 0) {
        children_.add(spacer);
      }
      children_.add(child);
    });
    return children_;
  }

  List<Widget> _flexSpaceChildren() {
    final children_ = <Widget>[];
    final spacer = SizedBox(width: spacing);
    children.forEachIndexed((index, child) {
      if (index > 0) {
        children_.add(spacer);
      }
      children_.add(_flexChild(child, flexes![index]));
    });
    return children_;
  }

  @override
  Widget build(BuildContext context) {
    return material.Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: run(() {
        if (spacing > 0) {
          if (flexes != null) {
            return _flexSpaceChildren();
          } else {
            return _spaceChildren();
          }
        } else {
          if (flexes != null) {
            return _flexChildren();
          } else {
            return children;
          }
        }
      }),
    );
  }
}

/// タブまたは[Scaffold.body]中の頻出コード
///
/// [Column]で‘Vertical viewport was given unbounded height’エラーを避けるため。
/// https://docs.flutter.dev/testing/common-errors#vertical-viewport-was-given-unbounded-height
/// [child] - [ListView]など[height]が不定のウィジェット。
/// [top]/[tops], [bottom]/[bottoms] - [child]の上下に積まれる。

class ExpandedColumn extends StatelessWidget {
  final Widget child;
  final Widget? top;
  final List<Widget>? tops;
  final Widget? bottom;
  final List<Widget>? bottoms;

  const ExpandedColumn({
    super.key,
    required this.child,
    this.top,
    this.tops,
    this.bottom,
    this.bottoms,
  })  : assert(top == null || tops == null),
        assert(bottom == null || bottoms == null);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (top != null) top!,
        if (tops != null) ...tops!,
        Expanded(child: child),
        if (bottom != null) bottom!,
        if (bottoms != null) ...bottoms!,
      ],
    );
  }
}
