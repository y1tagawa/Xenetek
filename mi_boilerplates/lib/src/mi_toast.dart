// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

/// 指定時間でフェードイン・アウト
///
/// [visibleNotifier]をtrueに設定するとF.I.開始

class MiToaster extends StatefulWidget {
  final Duration duration;
  final Duration transitionDuration;
  final ValueNotifier<bool> visibleNotifier;
  final double opacity;
  final VoidCallback? onDismissed;
  final Widget child;

  const MiToaster({
    super.key,
    this.duration = const Duration(milliseconds: 4000),
    this.transitionDuration = const Duration(milliseconds: 250),
    required this.visibleNotifier,
    this.opacity = 1.0,
    this.onDismissed,
    required this.child,
  }) : assert(opacity > 0.0 && opacity <= 1.0);

  @override
  State<StatefulWidget> createState() => _MiToasterState();
}

class _MiToasterState extends State<MiToaster> {
  static final _logger = Logger((_MiToasterState).toString());

  double _opacity = 0.0;
  CancelableOperation<void>? _dismiss;

  void _update() {
    _logger.fine('update visible=${widget.visibleNotifier.value}');
    setState(() {
      _opacity = widget.visibleNotifier.value ? widget.opacity : 0.0;
    });
  }

  @override
  void initState() {
    _logger.fine('initState');
    super.initState();
    widget.visibleNotifier.addListener(_update);
  }

  @override
  void dispose() {
    _logger.fine('dispose');
    widget.visibleNotifier.removeListener(_update);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MiToaster oldWidget) {
    _logger.fine('didUpdateWidget');
    super.didUpdateWidget(oldWidget);
    oldWidget.visibleNotifier.removeListener(_update);
    widget.visibleNotifier.addListener(_update);
  }

  @override
  Widget build(BuildContext context) {
    _logger.fine('[i] build _opacity=$_opacity');

    if (widget.visibleNotifier.value) {
      if (_dismiss != null) {
        _logger.fine('cancel dismiss');
        _dismiss!.cancel();
      }
      _dismiss = CancelableOperation.fromFuture(
        Future.delayed(widget.duration, () {
          _logger.fine('dismissing');
          _dismiss = null;
          setState(() {
            widget.visibleNotifier.value = false;
          });
        }),
      );
    }

    return AnimatedOpacity(
      opacity: _opacity,
      duration: widget.transitionDuration,
      onEnd: () {
        if (_opacity == 0.0) {
          _logger.fine('dismissed');
          widget.onDismissed?.call();
        }
      },
      child: widget.child,
    ).also((it) {
      _logger.fine('[o] build');
    });
  }
}

///

class _Toast extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const _Toast({
    this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget widget = Container(
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
          child: child,
        ),
      ),
    );
    if (onPressed != null) {
      widget = InkWell(
        onTap: onPressed,
        child: widget,
      );
    }
    return widget;
  }
}

class MiToastHelper {
  /// Toast表示
  /// TODO: 連打対策
  static Future<void> showToast({
    required BuildContext context,
    Duration duration = const Duration(milliseconds: 4000),
    Duration transitionDuration = const Duration(milliseconds: 250),
    double opacity = 1.0,
    VoidCallback? onDismissed,
    required Widget child,
  }) async {
    final logger = Logger('showToast');
    logger.fine('[i] showToast');

    final visibleNotifier = ValueNotifier(false);
    final overlay = Overlay.of(context);
    final completer = Completer();

    late OverlayEntry toast;

    void dismiss_() {
      logger.fine('remove entry');
      toast.remove();
      completer.complete();
    }

    toast = OverlayEntry(
      builder: (context) {
        return Align(
          alignment: const Alignment(0, 0.75),
          child: MiToaster(
            duration: duration,
            transitionDuration: transitionDuration,
            visibleNotifier: visibleNotifier,
            opacity: opacity,
            onDismissed: () {
              logger.fine('onDismissed');
              dismiss_();
              onDismissed?.call();
            },
            child: _Toast(
              onPressed: () {
                visibleNotifier.value = false;
              },
              child: child,
            ),
          ),
        );
      },
    );
    logger.fine('insert entry');
    overlay!.insert(toast);
    await Future.delayed(
      const Duration(milliseconds: 100),
      () {
        visibleNotifier.value = true;
        return completer.future;
      },
    ).then((value) {
      logger.fine('[o] showToast');
    });
  }
}
