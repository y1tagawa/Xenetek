// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

/// 甲冑装備状態表示ウィジェット
///
/// [equipped]の状態に応じて各部位の装備状態を表示する。

class KnightIndicator extends StatelessWidget {
  static const kHelmetIcon = Icon(Icons.balcony_outlined);
  static const kArmourIcon = mi.Scale(
    scale: 1.2,
    child: mi.Rotate(
      angleDegree: 90.0,
      child: Icon(Icons.bento_outlined),
    ),
  );
  static const _kLGauntletIcon = Icon(Icons.thumb_up_outlined);
  static const _kRGauntletIcon = mi.Scale(scaleX: -1, child: _kLGauntletIcon);
  static const kGauntletsIcon = mi.Row(spacing: 0, children: [_kRGauntletIcon, _kLGauntletIcon]);
  static const _kLBootIcon = Icon(Icons.roller_skating_outlined);
  static const _kRBootIcon = mi.Scale(scaleX: -1, child: _kLBootIcon);
  static const kBootsIcon = mi.Row(spacing: 0, children: [_kRBootIcon, _kLBootIcon]);
  static const kShieldIcon = Icon(Icons.shield_outlined);
  static const kWeaponIcon = Icon(Icons.colorize);

  static const _kFaceIcon = Icon(Icons.child_care_outlined);
  static const _kRHandIcon = mi.Scale(scale: 0.8, child: Icon(Icons.front_hand_outlined));
  static const _kLHandIcon = mi.Scale(scaleX: -1, child: _kRHandIcon);
  static const _kBlankIcon = Icon(null);

  static const items = <String, Widget>{
    'Boots': kBootsIcon,
    'Armour': kArmourIcon,
    'Gauntlets': kGauntletsIcon,
    'Helmet': kHelmetIcon,
    'Weapon': kWeaponIcon,
    'Shield': kShieldIcon,
  };

  final List<bool> equipped;
  final Widget? helmetIcon;
  final Widget? shieldIcon;
  final Color? color;

  const KnightIndicator({
    super.key,
    required this.equipped,
    this.helmetIcon,
    this.shieldIcon,
    this.color,
  }) : assert(equipped.length == items.length);

  @override
  Widget build(BuildContext context) {
    final helmetIcon_ = helmetIcon ?? kHelmetIcon;
    final shieldIcon_ = shieldIcon ?? kShieldIcon;
    return IconTheme.merge(
      data: IconThemeData(color: color),
      child: Column(
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
                const mi.Translate(offset: Offset(0, -6), child: _kRGauntletIcon)
              else
                const mi.Translate(offset: Offset(2, -6), child: _kRHandIcon),
              Stack(
                children: [
                  _kBlankIcon,
                  if (equipped[1]) kArmourIcon,
                  if (equipped[4])
                    const mi.Translate(
                      offset: Offset(-12, 6),
                      child: mi.Rotate(
                        angleDegree: -30,
                        child: kWeaponIcon,
                      ),
                    ),
                ],
              ),
              if (equipped[5])
                mi.Translate(offset: const Offset(-4, 0), child: shieldIcon_)
              else if (equipped[2])
                const mi.Translate(offset: Offset(-1, -6), child: _kLGauntletIcon)
              else
                const mi.Translate(offset: Offset(-4, -6), child: _kLHandIcon),
            ],
          ),
          if (equipped[0])
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [_kRBootIcon, _kLBootIcon],
            ),
        ],
      ),
    );
  }
}
