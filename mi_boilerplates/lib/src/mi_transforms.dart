// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../mi_boilerplates.dart' as mi;

/// const版 Transform.rotate
class Rotate extends StatelessWidget {
  final double? angle;
  // toRadian()はconstにならないので度でも受けられるようにしておく。
  final double? angleDegree;
  final Offset? origin;
  final AlignmentGeometry? alignment;
  final bool transformHitTests;
  final FilterQuality? filterQuality;
  final Widget? child;

  const Rotate({
    super.key,
    this.angle,
    this.angleDegree,
    this.alignment = Alignment.center,
    this.origin,
    this.transformHitTests = true,
    this.filterQuality,
    this.child,
  }) : assert(angle != null || angleDegree != null);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle ?? angleDegree!.toRadian(),
      alignment: alignment,
      origin: origin,
      transformHitTests: transformHitTests,
      filterQuality: filterQuality,
      child: child,
    );
  }
}

/// const版 Transform.scale
class Scale extends StatelessWidget {
  final double? scale;
  final double? scaleX;
  final double? scaleY;
  final Offset? origin;
  final AlignmentGeometry? alignment;
  final bool transformHitTests;
  final FilterQuality? filterQuality;
  final Widget? child;

  const Scale({
    super.key,
    this.scale,
    this.scaleX,
    this.scaleY,
    this.alignment = Alignment.center,
    this.origin,
    this.transformHitTests = true,
    this.filterQuality,
    this.child,
  }) : assert(scale != null || scaleX != null || scaleY != null);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      scaleX: scaleX,
      scaleY: scaleY,
      alignment: alignment,
      origin: origin,
      transformHitTests: transformHitTests,
      filterQuality: filterQuality,
      child: child,
    );
  }
}

/// const版 Transform.translate
class Translate extends StatelessWidget {
  final Offset offset;
  final bool transformHitTests;
  final FilterQuality? filterQuality;
  final Widget? child;

  const Translate({
    super.key,
    required this.offset,
    this.transformHitTests = true,
    this.filterQuality,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      transformHitTests: transformHitTests,
      filterQuality: filterQuality,
      child: child,
    );
  }
}
