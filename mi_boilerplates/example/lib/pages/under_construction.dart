// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

///
/// Under construction indicator
///

class UnderConstruction extends StatelessWidget {
  static const icon = MiRotate(
    angle: math.pi,
    child: Icon(Icons.filter_list),
  );
  static const text = 'Under construction';

  const UnderConstruction({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight) * 0.5;
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Image.asset(
                'assets/under_construction.png',
                width: size,
                height: size,
                color: theme.disabledColor.withOpacity(0.1),
              ),
              // MiScale(
              //   scaleX: 0.5,
              //   child: MiRotate(
              //     angleDegree: 180,
              //     child: Icon(
              //       Icons.filter_list,
              //       color: theme.isDark ? Colors.deepOrange[900] : Colors.deepOrange,
              //       size: size,
              //     ),
              //   ),
              // ),
              Text(
                text,
                style: TextStyle(color: theme.disabledColor),
              ),
            ],
          ),
        );
      },
    );
  }
}
