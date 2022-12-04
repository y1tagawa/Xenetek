// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

/// 指定時間でF.I./F.O.するウィジェット

class MiToast extends StatefulWidget {
  final Duration duration;
  final Duration transitionDuration;
  final ValueNotifier<bool> visibleNotifier;
  final double opacity;
  final VoidCallback? onDismissed;
  final Widget child;

  const MiToast({
    super.key,
    this.duration = const Duration(milliseconds: 4000),
    this.transitionDuration = const Duration(milliseconds: 250),
    required this.visibleNotifier,
    this.opacity = 1.0,
    this.onDismissed,
    required this.child,
  }) : assert(opacity > 0.0 && opacity <= 1.0);

  @override
  State<StatefulWidget> createState() => _MiToastState();
}

class _MiToastState extends State<MiToast> {
  static final _logger = Logger((_MiToastState).toString());

  double _opacity = 0.0;
  CancelableOperation<void>? _dismiss;

  void _update() {
    setState(() {
      _opacity = widget.visibleNotifier.value ? widget.opacity : 0.0;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.visibleNotifier.addListener(_update);
  }

  @override
  void dispose() {
    widget.visibleNotifier.removeListener(_update);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MiToast oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.visibleNotifier.removeListener(_update);
    widget.visibleNotifier.addListener(_update);
  }

  @override
  Widget build(BuildContext context) {
    _logger.fine('[i] build _opacity=$_opacity');

    if (widget.visibleNotifier.value) {
      _dismiss?.cancel();
      _dismiss = CancelableOperation.fromFuture(
        Future.delayed(widget.duration, () {
          setState(() {
            widget.visibleNotifier.value = false;
          });
        }),
      );
    }

    final theme = Theme.of(context);

    return AnimatedOpacity(
      opacity: _opacity,
      duration: widget.transitionDuration,
      onEnd: () {
        if (_opacity == 0.0) {
          widget.onDismissed?.call();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.circular(4),
          color: theme.colorScheme.onSurface,
        ),
        child: DefaultTextStyle(
          style: theme.textTheme.titleMedium!.merge(
            TextStyle(color: theme.colorScheme.surface),
          ),
          child: IconTheme.merge(
            data: IconThemeData(
              color: theme.colorScheme.surface,
            ),
            child: widget.child,
          ),
        ),
      ),
    ).also((it) {
      _logger.fine('[o] build');
    });
  }
}
