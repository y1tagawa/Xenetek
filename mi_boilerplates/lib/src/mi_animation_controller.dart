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
    _controller.dispose();
    super.dispose();
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

class MiRingingIcon extends StatelessWidget {
  final bool enabled;
  final bool initiallyRinging;
  final Widget icon;
  final Widget? ringingIcon;
  final VoidCallback? onPressed;
  final double? maxSwing;
  final double? maxSwingDegree;

  const MiRingingIcon({
    super.key,
    this.enabled = true,
    this.initiallyRinging = false,
    this.icon = const Icon(Icons.notifications_outlined),
    this.ringingIcon = const Icon(Icons.notifications_active_outlined),
    this.onPressed,
    this.maxSwing,
    this.maxSwingDegree,
  });

  @override
  Widget build(BuildContext context) {
    final maxSwing_ =
        maxSwing ?? maxSwingDegree?.toRadian() ?? (40.0 * DoubleHelper.degreeToRadian);
    return MiAnimationController(
      builder: (context, controller, _) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            if (controller.isAnimating) {
              return Transform.rotate(
                angle: Curves.easeIn.transform(1.0 - controller.value) *
                    math.sin(controller.value * 10 * 2 * math.pi) *
                    maxSwing_,
                origin: const Offset(0, -8),
                child: ringingIcon ?? icon,
              );
            }
            return icon;
          },
        );
      },
      onInitialized: (controller) {
        if (initiallyRinging) {
          controller.reset();
          controller.forward();
        }
      },
      onTap: (controller) {
        controller.reset();
        controller.forward();
        onPressed?.call();
      },
      onCompleted: (controller) {
        controller.reset();
      },
    );
  }
}
