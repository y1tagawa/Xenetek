import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

/// [AnimationController]内蔵[AnimatedBuilder]
///
/// s.a. https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html
class MiAnimatedBuilder extends StatefulWidget {
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

  const MiAnimatedBuilder({
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
  State<StatefulWidget> createState() => _MiAnimatedBuilderState();
}

class _MiAnimatedBuilderState extends State<MiAnimatedBuilder> with SingleTickerProviderStateMixin {
  static final _logger = Logger((_MiAnimatedBuilderState).toString());

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
    _logger.fine('[i] build ${_controller.value}');
    Widget child = widget.builder(context, _controller, widget.child);
    if (widget.onTap != null || widget.onHover != null) {
      child = InkWell(
        onTap: widget.enabled ? () => widget.onTap?.call(_controller) : null,
        onHover: widget.enabled ? (enter) => widget.onHover?.call(_controller, enter) : null,
        child: child,
      );
    }
    return child.also((_) {
      _logger.fine('[o] build');
    });
  }
}
