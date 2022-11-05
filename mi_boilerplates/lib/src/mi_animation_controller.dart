import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

/// [AnimationController]内蔵ウィジェット
///
/// s.a. https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html
class MiAnimationController extends StatefulWidget {
  final bool enabled;
  final Widget Function(
    BuildContext context,
    AnimationController controller,
    Widget? child,
  ) builder;
  final Duration duration;
  final void Function(AnimationController controller)? onInitialized;
  final void Function()? onDispose;
  final void Function(AnimationController controller)? onCompleted;
  final void Function(AnimationController controller)? onTap;
  final void Function(AnimationController controller, bool enter)? onHover;
  final Widget? child;

  const MiAnimationController({
    super.key,
    this.enabled = true,
    required this.builder,
    this.duration = const Duration(milliseconds: 1000),
    this.onInitialized,
    this.onDispose,
    this.onCompleted,
    this.onTap,
    this.onHover,
    this.child,
  });

  @override
  State<StatefulWidget> createState() => _MiAnimationControllerState();
}

class _MiAnimationControllerState extends State<MiAnimationController>
    with SingleTickerProviderStateMixin {
  static final _logger = Logger((_MiAnimationControllerState).toString());

  late final AnimationController _controller = AnimationController(
    vsync: this, // the SingleTickerProviderStateMixin.
    duration: widget.duration,
  ).also((it) {
    it.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call(_controller);
      }
    });
    widget.onInitialized?.call(it);
  });

  @override
  void dispose() {
    try {
      widget.onDispose?.call();
    } finally {
      _controller.dispose();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    //_logger.fine('[i] build ${_controller.value}');
    Widget child = widget.builder(context, _controller, widget.child);
    if (widget.onTap != null || widget.onHover != null) {
      child = InkWell(
        onTap: widget.enabled ? () => widget.onTap?.call(_controller) : null,
        onHover: widget.enabled ? (enter) => widget.onHover?.call(_controller, enter) : null,
        child: child,
      );
    }
    return child //.also((_) { _logger.fine('[o] build');})
        ;
  }
}

/// [MiAnimationController]の使用例
///
/// [duration]の間、[frequency]回アイコンを振動させる。
/// [onInitialized]から[onDispose]の間、AnimationControllerを外部に提供するので、
/// Animationの制御はそれを使う。
class MiRingingIcon extends StatelessWidget {
  final bool enabled;
  final Duration duration;
  final double frequency;
  final Widget icon;
  final Widget? ringingIcon;
  final void Function(AnimationController controller)? onInitialized;
  final VoidCallback? onDispose;
  final VoidCallback? onPressed;
  final double? angle;
  final double? angleDegree;
  final Offset? origin;

  const MiRingingIcon({
    super.key,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 1000),
    this.frequency = 10,
    this.icon = const Icon(Icons.notifications_outlined),
    this.ringingIcon = const Icon(Icons.notifications_active_outlined),
    this.onInitialized,
    this.onDispose,
    this.onPressed,
    this.angle,
    this.angleDegree,
    this.origin,
  });

  @override
  Widget build(BuildContext context) {
    final angle_ = angle ?? angleDegree?.toRadian() ?? (20.0 * DoubleHelper.degreeToRadian);
    return MiAnimationController(
      duration: duration,
      builder: (context, controller, _) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            if (controller.isAnimating) {
              return Transform.rotate(
                angle: Curves.easeIn.transform(1.0 - controller.value) *
                    math.sin(controller.value * frequency * 2 * math.pi) *
                    angle_,
                origin: origin,
                child: ringingIcon ?? icon,
              );
            }
            return icon;
          },
        );
      },
      onInitialized: (controller) => onInitialized?.call(controller),
      onDispose: () => onDispose?.call(),
      onTap: onPressed != null
          ? (_) {
              onPressed!.call();
            }
          : null,
      onCompleted: (controller) => controller.reset(),
    );
  }
}
