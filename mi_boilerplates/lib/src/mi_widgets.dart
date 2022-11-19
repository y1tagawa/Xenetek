// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

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

  List<T> removedAt(int index) {
    final t = toList();
    t.removeAt(index);
    return t;
  }

  List<T> replaced(int index, T value) {
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

/// ラベル
///
/// [icon]がnullの場合、その部分は空白となる。
class MiIcon extends StatelessWidget {
  final bool enabled;
  final Widget? icon;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHover;
  final double? spacing;
  final Widget? text;
  final String? tooltip;

  const MiIcon({
    super.key,
    this.enabled = true,
    this.icon,
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

    Widget icon_ = icon?.let(
          (it) => DefaultTextStyle.merge(
            style: TextStyle(color: textColor),
            child: IconTheme.merge(
              data: IconThemeData(color: textColor),
              child: it,
            ),
          ),
        ) ??
        SizedBox.square(dimension: IconTheme.of(context).size ?? 24);

    if (text != null) {
      final spacing_ = spacing ?? 8.0;
      icon_ = DefaultTextStyle.merge(
        style: TextStyle(color: textColor),
        child: IconTheme.merge(
          data: IconThemeData(color: textColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon_,
              if (spacing_ > 0.0) SizedBox(width: spacing_),
              text!,
              if (spacing_ > 0.0) SizedBox(width: spacing_),
            ],
          ),
        ),
      );
    }

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
///
class MiColorChip extends StatelessWidget {
  final bool enabled;
  final Color? color;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHover;
  final double? size;
  final double margin;
  final double? spacing;
  final Widget? text;
  final String? tooltip;

  const MiColorChip({
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

    return MiIcon(
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
///
class MiToggleIcon extends StatelessWidget {
  final bool checked;
  final Widget checkIcon;
  final Widget uncheckIcon;
  final Duration duration;

  const MiToggleIcon({
    super.key,
    required this.checked,
    required this.checkIcon,
    required this.uncheckIcon,
    this.duration = const Duration(milliseconds: 300),
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
class MiImageIcon extends StatelessWidget {
  final Image image;
  final double? size;

  const MiImageIcon({
    super.key,
    required this.image,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    return SizedBox.square(
      dimension: size ?? theme.size,
      child: Image(
        image: image.image,
        color: theme.color,
      ),
    );
  }
}

/// カスタム[TextButton]
///
/// [enabled]を追加しただけ。
///
class MiTextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final MaterialStatesController? statesController;
  final Widget child;

  const MiTextButton({
    super.key,
    this.enabled = true,
    this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      onLongPress: enabled ? onLongPress : null,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: style,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      statesController: statesController,
      child: child,
    );
  }
}

/// カスタム[IconButton]
///
/// [enabled]を追加しただけ。
/// TODO: StatelessWidgetから派生。
///
class MiIconButton extends IconButton {
  const MiIconButton({
    super.key,
    bool enabled = true,
    super.iconSize,
    super.visualDensity,
    super.padding = const EdgeInsets.all(8.0),
    super.alignment = Alignment.center,
    super.splashRadius,
    super.color,
    super.focusColor,
    super.hoverColor,
    super.highlightColor,
    super.splashColor,
    super.disabledColor,
    required VoidCallback? onPressed,
    super.mouseCursor,
    super.focusNode,
    super.autofocus = false,
    super.tooltip,
    super.enableFeedback = true,
    super.constraints,
    super.style,
    super.isSelected,
    super.selectedIcon,
    required super.icon,
  }) : super(
          onPressed: enabled ? onPressed : null,
        );
}

/// トグルアイコンボタン
class MiCheckIconButton extends StatelessWidget {
  final bool enabled;
  final bool checked;
  final double? iconSize;
  final ValueChanged<bool>? onChanged;
  final Widget? checkIcon;
  final Widget? uncheckIcon;
  final Duration? duration;

  const MiCheckIconButton({
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

/// 明示的にintの値をとる[Slider]
class MiIntSlider extends StatelessWidget {
  final bool enabled;
  final int value;
  final int min;
  final int max;
  final int? divisions;
  final String? label;
  final ValueChanged<int> onChanged;
  // TODO: 必要になったら他のプロパティも

  const MiIntSlider({
    super.key,
    this.enabled = true,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.label,
    required this.onChanged,
  }) : assert(divisions == null || (max > min && divisions % (max - min) == 0));

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value.toDouble(),
      min: min.toDouble(),
      max: max.toDouble(),
      divisions: divisions ?? (max - min),
      label: label,
      onChanged: enabled ? (value) => onChanged(value.round()) : null,
    );
  }
}

/// カスタム[Row]。
///
/// * [crossAxisAlignment]のデフォルト値を[WrapCrossAlignment.center]に変更。
/// * [flexes]を指定した場合、[children]の個々を[Flexible]でラップする。
/// * [spacing]を指定した場合、[children]の間に空間を空ける。
///
class MiRow extends StatelessWidget {
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

  const MiRow({
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
    return Flexible(
      flex: flex,
      fit: fit,
      child: child,
    );
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
    return Row(
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
///
class MiExpandedColumn extends StatelessWidget {
  final Widget child;
  final Widget? top;
  final List<Widget>? tops;
  final Widget? bottom;
  final List<Widget>? bottoms;

  const MiExpandedColumn({
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
