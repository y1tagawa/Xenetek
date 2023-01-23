// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gradients/gradients.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

//
// Exampleアプリ頻出コード
//

/// クリアボタン

class ClearButtonListTile extends StatelessWidget {
  final bool enabled;
  final Widget? icon;
  final Widget? text;
  final VoidCallback? onPressed;

  const ClearButtonListTile({
    super.key,
    this.enabled = true,
    this.onPressed,
    this.icon,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return mi.ButtonListTile(
      enabled: enabled,
      onPressed: onPressed,
      icon: icon ?? const Icon(Icons.clear),
      text: text ?? const Text('Clear'),
    );
  }
}

/// リセットボタン

class ResetButtonListTile extends StatelessWidget {
  final bool enabled;
  final Widget? icon;
  final Widget? text;
  final VoidCallback? onPressed;

  const ResetButtonListTile({
    super.key,
    this.enabled = true,
    this.onPressed,
    this.icon,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return mi.ButtonListTile(
      enabled: enabled,
      onPressed: onPressed,
      icon: icon ?? const mi.Scale(scaleX: -1, child: Icon(Icons.refresh)),
      text: text ?? const Text('Reset'),
    );
  }
}

/// [StreamController]と[StreamProvider]の組み合わせ
///
/// 非同期に更新される状態変数をプロバイダ化するための頻出コード

class StreamProviderCoordinator<T> {
  final StreamController<FutureOr<T>> controller;
  final StreamProvider<T> provider;

  factory StreamProviderCoordinator.fromFuture(Future<T> future) {
    final controller = StreamController<FutureOr<T>>()..sink.add(future);
    final provider = StreamProvider<T>((ref) async* {
      await for (final value in controller.stream) {
        yield await value;
      }
    });
    return StreamProviderCoordinator._(
      controller: controller,
      provider: provider,
    );
  }

  StreamProviderCoordinator._({
    required this.controller,
    required this.provider,
  });
}

/// Color slider

class ColorSlider extends mi.ColorSlider {
  static const _hsbColors = <Color>[
    HsbColor(0.0, 100.0, 100.0),
    HsbColor(120.0, 100.0, 100.0),
    HsbColor(240.0, 100.0, 100.0),
    HsbColor(360.0, 100.0, 100.0),
    HsbColor(0.0, 0.0, 0.0),
    HsbColor(0.0, 0.0, 100.0),
  ];

  static const _gradient = LinearGradientPainter(colors: _hsbColors, colorSpace: ColorSpace.hsb);

  static StreamProviderCoordinator<mi.ColorSliderValue> coordinatorFromPosition(double position) {
    return StreamProviderCoordinator.fromFuture(
        mi.ColorSliderValue.fromGradient(gradient: _gradient, position: position));
  }

  const ColorSlider({
    super.key,
    required super.value,
    super.onChanged,
    super.trackHeight = 8.0,
  });
}

/// Under construction

class UnderConstruction extends StatelessWidget {
  static const icon = mi.Rotate(
    angle: math.pi,
    child: Icon(Icons.filter_list),
  );
  static const title = 'Under construction';

  final String? text;

  const UnderConstruction({
    super.key,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight) * 0.5;
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Image.asset(
                'assets/worker_cat2.png',
                width: size,
                height: size,
                color: theme.disabledColor.withOpacity(0.1),
              ),
              Text(
                title,
                style: theme.textTheme.headline6?.merge(
                  TextStyle(color: theme.disabledColor),
                ),
              ),
              if (text != null) ...[
                const SizedBox(height: 8),
                Text(text!),
              ],
            ],
          ),
        );
      },
    );
  }
}
