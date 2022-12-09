// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

//
// Exampleアプリ頻出コード
//

/// クリアボタン
class ExClearButtonListTile extends StatelessWidget {
  final bool enabled;
  final Widget? icon;
  final Widget? text;
  final VoidCallback? onPressed;

  const ExClearButtonListTile({
    super.key,
    this.enabled = true,
    this.onPressed,
    this.icon,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return MiButtonListTile(
      enabled: enabled,
      onPressed: onPressed,
      icon: icon ?? const Icon(Icons.clear),
      text: text ?? const Text('Clear'),
    );
  }
}

/// リセットボタン
class ExResetButtonListTile extends StatelessWidget {
  final bool enabled;
  final Widget? icon;
  final Widget? text;
  final VoidCallback? onPressed;

  const ExResetButtonListTile({
    super.key,
    this.enabled = true,
    this.onPressed,
    this.icon,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return MiButtonListTile(
      enabled: enabled,
      onPressed: onPressed,
      icon: icon ?? const MiScale(scaleX: -1, child: Icon(Icons.refresh)),
      text: text ?? const Text('Reset'),
    );
  }
}
