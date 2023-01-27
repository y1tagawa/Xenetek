import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

/// Synchronous sink-like value notifier

class SinkNotifier<T> extends ChangeNotifier {
  T? _value;

  SinkNotifier();

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
}

/// [AnimationControllerWidget]に要求するコールバック

typedef AnimationControllerCallback = void Function(AnimationController controller);

/// [SingleTickerProviderStateMixin], [AnimationController]内蔵ウィジェット
///
/// s.a. https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html
/// Stateに[AnimationController]のライフサイクルをカプセル化する。
/// ライフサイクルに伴うイベントは、[onInitialized]などのコールバックによって外部に通知される。
/// また外部からは[callbackNotifier]を使用してアニメーションを制御することができる。

class AnimationControllerWidget extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    AnimationController controller,
    Widget? child,
  ) builder;
  final SinkNotifier<AnimationControllerCallback>? callbackNotifier;
  final Duration duration;
  final void Function(AnimationController controller)? onInitialized;
  final void Function()? onDispose;
  final void Function(AnimationController controller)? onEnd;
  final void Function(AnimationController controller)? onUpdate;
  final Widget? child;

  const AnimationControllerWidget({
    super.key,
    required this.builder,
    this.callbackNotifier,
    this.duration = const Duration(milliseconds: 1000),
    this.onInitialized,
    this.onDispose,
    this.onEnd,
    this.onUpdate,
    this.child,
  });

  @override
  State<StatefulWidget> createState() => _AnimationControllerWidgetState();
}

class _AnimationControllerWidgetState extends State<AnimationControllerWidget>
    with SingleTickerProviderStateMixin {
  // ignore: unused_field
  static final _logger = Logger((_AnimationControllerWidgetState).toString());

  late final AnimationController _controller;

  void _listener() {
    widget.onUpdate?.call(_controller);
  }

  void _statusListener(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        widget.onEnd?.call(_controller);
        break;
      default:
    }
  }

  void _callbackListener() {
    assert(widget.callbackNotifier != null);
    widget.callbackNotifier!.value(_controller);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )
      ..addListener(_listener)
      ..addStatusListener(_statusListener);
    widget.callbackNotifier?.addListener(_callbackListener);
    widget.onInitialized?.call(_controller);
  }

  @override
  void dispose() {
    try {
      widget.onDispose?.call();
    } finally {
      widget.callbackNotifier?.removeListener(_callbackListener);
      _controller
        ..removeStatusListener(_statusListener)
        ..removeListener(_listener);
      _controller.dispose();
      super.dispose();
    }
  }

  @override
  void didUpdateWidget(covariant AnimationControllerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.callbackNotifier?.removeListener(_callbackListener);
    widget.callbackNotifier?.addListener(_callbackListener);
  }

  @override
  Widget build(BuildContext context) {
    //_logger.fine('[i] build ${_controller.value}');
    return widget.builder(context, _controller, widget.child)
        //.also((_) { _logger.fine('[o] build');})
        ;
  }
}

/// [AnimationControllerWidget]の使用例
///
/// [duration]の間、[frequency]回アイコンを振動させる。

class RingBell extends StatelessWidget {
  final Duration duration;
  final double frequency;
  final Widget icon;
  final Widget? ringingIcon;
  final SinkNotifier<AnimationControllerCallback>? callbackNotifier;
  final void Function(AnimationController controller)? onInitialized;
  final VoidCallback? onPressed;
  final double? angle;
  final double? angleDegree;
  final Offset? origin;

  const RingBell({
    super.key,
    this.duration = const Duration(milliseconds: 2000),
    this.frequency = 10,
    this.icon = const Icon(Icons.notifications_outlined),
    this.ringingIcon = const Icon(Icons.notifications_active_outlined),
    this.callbackNotifier,
    this.onInitialized,
    this.onPressed,
    this.angle,
    this.angleDegree,
    this.origin,
  }) : assert(angle == null || angleDegree == null);

  @override
  Widget build(BuildContext context) {
    final angle_ = angle ?? angleDegree?.toRadian() ?? 20.0.toRadian();
    return AnimationControllerWidget(
      duration: duration,
      callbackNotifier: callbackNotifier,
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
      onEnd: (controller) => controller.reset(),
    );
  }
}

/// [AnimationControllerWidget]の使用例
///
/// マジックワンドを振る動作

class FlickWand extends StatelessWidget {
  final bool enabled;
  final Duration duration;
  final Widget icon;
  final Widget? ringingIcon;
  final SinkNotifier<AnimationControllerCallback>? callbackNotifier;
  final void Function(AnimationController controller)? onInitialized;
  final VoidCallback? onPressed;
  final double? angle;
  final double? angleDegree;
  final Offset? origin;

  const FlickWand({
    super.key,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 800),
    this.icon = const Icon(Icons.auto_fix_normal_outlined),
    this.ringingIcon = const Icon(Icons.auto_fix_high_outlined),
    this.callbackNotifier,
    this.onInitialized,
    this.onPressed,
    this.angle,
    this.angleDegree,
    this.origin,
  }) : assert(angle == null || angleDegree == null);

  @override
  Widget build(BuildContext context) {
    final angle_ = angle ?? angleDegree?.toRadian() ?? 60.0.toRadian();
    return AnimationControllerWidget(
      duration: duration,
      callbackNotifier: callbackNotifier,
      builder: (context, controller, _) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            if (controller.isAnimating) {
              return Transform.rotate(
                angle:
                    (Curves.easeInOutBack.transform(controller.value) - controller.value) * angle_,
                origin: origin,
                child: ringingIcon ?? icon,
              );
            }
            return icon;
          },
        );
      },
      onInitialized: (controller) => onInitialized?.call(controller),
      onEnd: (controller) => controller.reset(),
    );
  }
}
