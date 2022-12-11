import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

/// Synchronous sink-like value notifier

class MiSinkNotifier<T> extends ChangeNotifier {
  T? _value;

  MiSinkNotifier();

  T get value {
    assert(_value != null);
    return _value!;
  }

  void add(T value) {
    if (hasListeners) {
      _value = value;
      notifyListeners();
      _value = null;
    }
  }

  void addAll(Iterable<T> values) {
    if (hasListeners) {
      for (final value in values) {
        _value = value;
        notifyListeners();
      }
      _value = null;
    }
  }
}

/// [MiAnimationController]に外部から供給するコマンド
enum MiAnimationControllerCommand { reset, forward }

/// [SingleTickerProviderStateMixin], [AnimationController]内蔵ウィジェット
///
/// s.a. https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html

class MiAnimationController extends StatefulWidget {
  final bool enabled;
  final Widget Function(
    BuildContext context,
    AnimationController controller,
    Widget? child,
  ) builder;
  final MiSinkNotifier<MiAnimationControllerCommand>? commandNotifier;
  final Duration duration;
  final void Function(AnimationController controller)? onInitialized;
  final void Function()? onDispose;
  final void Function(AnimationController controller)? onCompleted;
  final void Function(AnimationController controller)? onTap;
  final void Function(AnimationController controller, bool enter)? onHover;
  final void Function(AnimationController controller)? onUpdate;
  final Widget? child;

  const MiAnimationController({
    super.key,
    this.enabled = true,
    required this.builder,
    this.commandNotifier,
    this.duration = const Duration(milliseconds: 1000),
    this.onInitialized,
    this.onDispose,
    this.onCompleted,
    this.onTap,
    this.onHover,
    this.onUpdate,
    this.child,
  });

  @override
  State<StatefulWidget> createState() => _MiAnimationControllerState();
}

class _MiAnimationControllerState extends State<MiAnimationController>
    with SingleTickerProviderStateMixin {
  // ignore: unused_field
  static final _logger = Logger((_MiAnimationControllerState).toString());

  late final AnimationController _controller;

  void _listener() {
    widget.onUpdate?.call(_controller);
  }

  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onCompleted?.call(_controller);
    }
  }

  void _commandListener() {
    assert(widget.commandNotifier != null);
    switch (widget.commandNotifier!.value) {
      case MiAnimationControllerCommand.reset:
        _controller.reset();
        break;
      case MiAnimationControllerCommand.forward:
        _controller.forward();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin.
      duration: widget.duration,
    )
      ..addListener(_listener)
      ..addStatusListener(_statusListener);
    widget.commandNotifier?.addListener(_commandListener);
    widget.onInitialized?.call(_controller);
  }

  @override
  void dispose() {
    try {
      widget.onDispose?.call();
    } finally {
      widget.commandNotifier?.removeListener(_commandListener);
      _controller
        ..removeStatusListener(_statusListener)
        ..removeListener(_listener);
      _controller.dispose();
      super.dispose();
    }
  }

  @override
  void didUpdateWidget(covariant MiAnimationController oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.commandNotifier?.removeListener(_commandListener);
    widget.commandNotifier?.addListener(_commandListener);
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
/// アニメーションの制御は[commandNotifier]またはコールバック引数の[AnimationController]によって行う。

class MiRingingIcon extends StatelessWidget {
  final bool enabled;
  final Duration duration;
  final double frequency;
  final Widget icon;
  final Widget? ringingIcon;
  final MiSinkNotifier<MiAnimationControllerCommand>? commandNotifier;
  final void Function(AnimationController controller)? onInitialized;
  final VoidCallback? onDispose;
  final VoidCallback? onPressed;
  final double? angle;
  final double? angleDegree;
  final Offset? origin;

  const MiRingingIcon({
    super.key,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 2000),
    this.frequency = 10,
    this.icon = const Icon(Icons.notifications_outlined),
    this.ringingIcon = const Icon(Icons.notifications_active_outlined),
    this.commandNotifier,
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
      commandNotifier: commandNotifier,
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
