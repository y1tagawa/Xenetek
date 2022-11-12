// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

/// 甲冑装備状態表示ウィジェット
///
/// [equipped]の状態に応じて各部位の装備状態を表示する。
class KnightIndicator extends StatelessWidget {
  static const helmetIcon = Icon(Icons.balcony_outlined);
  static const armourIcon = MiScale(
    scale: 1.2,
    child: MiRotate(
      angleDegree: 90.0,
      child: Icon(Icons.bento_outlined),
    ),
  );
  static const _lGauntletIcon = Icon(Icons.thumb_up_outlined);
  static const _rGauntletIcon = MiScale(scaleX: -1, child: _lGauntletIcon);
  static const gauntletsIcon = MiRow(spacing: 0, children: [_rGauntletIcon, _lGauntletIcon]);
  static const _lBootIcon = Icon(Icons.roller_skating_outlined);
  static const _rBootIcon = MiScale(scaleX: -1, child: _lBootIcon);
  static const bootsIcon = MiRow(spacing: 0, children: [_rBootIcon, _lBootIcon]);
  static const shieldIcon = Icon(Icons.shield_outlined);

  static const _faceIcon = Icon(Icons.child_care_outlined);
  static const _rHandIcon = MiScale(scale: 0.8, child: Icon(Icons.front_hand_outlined));
  static const _lHandIcon = MiScale(scaleX: -1, child: _rHandIcon);
  static const _spaceIcon = Icon(null);

  static const items = <String, Widget>{
    'Boots': bootsIcon,
    'Armour': armourIcon,
    'Gauntlets': gauntletsIcon,
    'Helmet': helmetIcon,
    'Shield': shieldIcon,
  };

  final List<bool> equipped;

  const KnightIndicator({
    super.key,
    required this.equipped,
  }) : assert(equipped.length == items.length);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (equipped[3]) helmetIcon else _faceIcon,
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (equipped[2])
              const MiTranslate(offset: Offset(0, -6), child: _rGauntletIcon)
            else
              const MiTranslate(offset: Offset(2, -6), child: _rHandIcon),
            if (equipped[1]) armourIcon else _spaceIcon,
            if (equipped[4])
              const MiTranslate(offset: Offset(-4, 0), child: shieldIcon)
            else if (equipped[2])
              const MiTranslate(offset: Offset(-1, -6), child: _lGauntletIcon)
            else
              const MiTranslate(offset: Offset(-4, -6), child: _lHandIcon),
          ],
        ),
        if (equipped[0])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [_rBootIcon, _lBootIcon],
          ),
      ],
    );
  }
}
