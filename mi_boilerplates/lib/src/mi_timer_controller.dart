// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// [Timer]のウィジェット化
///
/// State存在期間、タイマイベントをコールバックする。
///
class MiTimerController extends StatefulWidget {
  // ignore: unused_field
  static final _logger = Logger((MiTimerController).toString());

  final Duration duration;
  final VoidCallback? onTimer;
  final ValueChanged<Timer>? onPeriodic;
  final Widget child;

  const MiTimerController({
    super.key,
    required this.duration,
    required this.onTimer,
    required this.child,
  }) : onPeriodic = null;

  const MiTimerController.periodic({
    super.key,
    required this.duration,
    required this.onPeriodic,
    required this.child,
  }) : onTimer = null;

  @override
  State<MiTimerController> createState() => _MiTimerControllerState();
}

class _MiTimerControllerState extends State<MiTimerController> {
  late Timer _timer;

  @override
  void initState() {
    assert(widget.onTimer != null || widget.onPeriodic != null);
    super.initState();
    if (widget.onTimer != null) {
      _timer = Timer(widget.duration, () {
        widget.onTimer!.call();
      });
    } else {
      _timer = Timer.periodic(widget.duration, (timer) {
        widget.onPeriodic!.call(_timer);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
