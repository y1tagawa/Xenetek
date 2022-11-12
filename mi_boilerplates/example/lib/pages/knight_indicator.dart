// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

/// 甲冑装備状態表示ウィジェット
///
/// [equipped]の状態に応じて各部位の装備状態を表示する。
class KnightIndicator extends StatelessWidget {
  static const kHelmetIcon = Icon(Icons.balcony_outlined);
  static const kArmourIcon = MiScale(
    scale: 1.2,
    child: MiRotate(
      angleDegree: 90.0,
      child: Icon(Icons.bento_outlined),
    ),
  );
  static const _kLGauntletIcon = Icon(Icons.thumb_up_outlined);
  static const _kRGauntletIcon = MiScale(scaleX: -1, child: _kLGauntletIcon);
  static const kGauntletsIcon = MiRow(spacing: 0, children: [_kRGauntletIcon, _kLGauntletIcon]);
  static const _kLBootIcon = Icon(Icons.roller_skating_outlined);
  static const _kRBootIcon = MiScale(scaleX: -1, child: _kLBootIcon);
  static const kBootsIcon = MiRow(spacing: 0, children: [_kRBootIcon, _kLBootIcon]);
  static const kShieldIcon = Icon(Icons.shield_outlined);

  static const _kFaceIcon = Icon(Icons.child_care_outlined);
  static const _kRHandIcon = MiScale(scale: 0.8, child: Icon(Icons.front_hand_outlined));
  static const _kLHandIcon = MiScale(scaleX: -1, child: _kRHandIcon);
  static const _kBlankIcon = Icon(null);

  static const items = <String, Widget>{
    'Boots': kBootsIcon,
    'Armour': kArmourIcon,
    'Gauntlets': kGauntletsIcon,
    'Helmet': kHelmetIcon,
    'Shield': kShieldIcon,
  };

  final List<bool> equipped;
  final Widget? helmetIcon;
  final Widget? shieldIcon;

  const KnightIndicator({
    super.key,
    required this.equipped,
    this.helmetIcon,
    this.shieldIcon,
  }) : assert(equipped.length == items.length);

  @override
  Widget build(BuildContext context) {
    final helmetIcon_ = helmetIcon ?? kHelmetIcon;
    final shieldIcon_ = shieldIcon ?? kShieldIcon;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (equipped[3]) helmetIcon_ else _kFaceIcon,
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (equipped[2])
              const MiTranslate(offset: Offset(0, -6), child: _kRGauntletIcon)
            else
              const MiTranslate(offset: Offset(2, -6), child: _kRHandIcon),
            if (equipped[1]) kArmourIcon else _kBlankIcon,
            if (equipped[4])
              MiTranslate(offset: const Offset(-4, 0), child: shieldIcon_)
            else if (equipped[2])
              const MiTranslate(offset: Offset(-1, -6), child: _kLGauntletIcon)
            else
              const MiTranslate(offset: Offset(-4, -6), child: _kLHandIcon),
          ],
        ),
        if (equipped[0])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [_kRBootIcon, _kLBootIcon],
          ),
      ],
    );
  }
}
