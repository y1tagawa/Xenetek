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
  static const title = 'Under construction';

  final String? text;

  const UnderConstruction({
    super.key,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
