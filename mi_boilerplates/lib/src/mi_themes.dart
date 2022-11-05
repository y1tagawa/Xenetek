// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

extension BrightnessExtension on Brightness {
  bool get isDark => this == Brightness.dark;
}

extension SwitchThemeDataHelper on SwitchThemeData {
  SwitchThemeData adjustByColor({
    required Color thumbColor,
    Brightness brightness = Brightness.light,
  }) {
    // s.a. https://github.com/flutter/flutter/blob/b7b8b759bc3ab7a80d2576d52f7b05bc1e6e23bd/packages/flutter/lib/src/material/switch.dart#L281-323
    return copyWith(
      thumbColor: MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.disabled)) {
            return brightness.isDark ? Colors.grey.shade800 : Colors.grey.shade400;
          } else if (states.contains(MaterialState.selected)) {
            return thumbColor;
          } else {
            return brightness.isDark ? Colors.grey.shade400 : Colors.grey.shade50;
          }
        },
      ),
      trackColor: MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.disabled)) {
            return brightness.isDark ? Colors.white10 : Colors.black12;
          } else if (states.contains(MaterialState.selected)) {
            return thumbColor.withAlpha(0x80);
          } else {
            return brightness.isDark ? Colors.white30 : const Color(0x52000000);
          }
        },
      ),
    );
  }
}

extension ThemeDataHelper on ThemeData {
  static final _logger = Logger('ThemeDataExtension');

  bool get isDark => brightness.isDark;

  /// ListTileのIconやCheckbox, Radioの色。disabledColorとonSurfaceの中間
  /// s.a. https://github.com/flutter/flutter/blob/cc2aedd17aee7203a035a8b3f5968ce040bfbe8f/packages/flutter/lib/src/material/list_tile.dart#L609
  Color get unselectedIconColor => colorScheme.onSurface.withAlpha(0x73);

  /// ListTileのデフォルトのパディング
  /// s.a. https://api.flutter.dev/flutter/material/ListTile/contentPadding.html
  EdgeInsetsGeometry get listTileContentPadding =>
      (listTileTheme.contentPadding) ?? const EdgeInsets.symmetric(horizontal: 16.0);

  /// 現状のmaterial widgetsの実装は、ダークテーマの挙動がまちまちなので、一貫するよう調整
  ThemeData adjust() {
    final foregroundColor = isDark ? colorScheme.secondary : primaryColorDark;

    Color? Function(Set<MaterialState> states) resolveButtonColor(Color color) {
      return (Set<MaterialState> states) => states.contains(MaterialState.disabled) ? null : color;
    }

    // TextButton, OutlinedButton
    // * ダーク時の色をsecondaryに変更
    final textButtonTheme_ = TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(resolveButtonColor(foregroundColor)),
      ).merge(textButtonTheme.style),
    );

    final outlinedButtonTheme_ = OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(resolveButtonColor(foregroundColor)),
      ).merge(outlinedButtonTheme.style),
    );

    // ElevatedButton
    // * ダーク時の色をsecondaryに変更
    final elevatedButtonTheme_ = ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(
          resolveButtonColor(isDark ? colorScheme.onSecondary : colorScheme.onPrimary),
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
          resolveButtonColor(isDark ? colorScheme.secondary : colorScheme.primary),
        ),
      ).merge(elevatedButtonTheme.style),
    );

    // Checkbox
    // * ダーク時のcheckColorを調整
    Color? Function(Set<MaterialState> states) resolveCheckColor() {
      return (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return isDark ? colorScheme.surface : colorScheme.onPrimary;
        }
        return null;
      };
    }

    final checkboxTheme_ = checkboxTheme.copyWith(
      checkColor: MaterialStateProperty.resolveWith<Color?>(resolveCheckColor()),
    );

    // TODO: Slider.
    // https://github.com/flutter/flutter/blob/cc2aedd17aee7203a035a8b3f5968ce040bfbe8f/packages/flutter/lib/src/material/slider.dart#L743

    // ToggleButtons
    // * ダーク時の色をsecondaryに変更
    final toggleButtonsTheme_ = toggleButtonsTheme.copyWith(
      selectedColor: foregroundColor,
      // TODO: SOURCE LINK
      fillColor: foregroundColor.withOpacity(0.12),
    );

    // ListTile
    // * ダーク時の色をsecondaryに変更
    final listTileTheme_ = listTileTheme.copyWith(
      selectedColor: foregroundColor,
    );

    // ExpansionTile
    // * ダーク時の色をsecondaryに変更
    final expansionTileTheme_ = expansionTileTheme.copyWith(
      textColor: foregroundColor,
      iconColor: foregroundColor,
    );

    // SnackBar
    // * actionTextColorをちょっと見やすく（独自研究）
    final snackBarTheme_ = snackBarTheme.copyWith(
      actionTextColor: isDark
          ? Color.alphaBlend(colorScheme.secondary.withAlpha(80), colorScheme.surface)
          : primaryColorLight,
    );

    // TabBar
    // * ラベル文字色、インジケータ色のM3対応
    final indicatorColor_ = useMaterial3
        ? colorScheme.onSurface
        : isDark
            ? colorScheme.secondary
            : colorScheme.onPrimary;
    final labelColor = useMaterial3
        ? colorScheme.onSurface
        : isDark
            ? colorScheme.onSurface
            : colorScheme.onPrimary;
    final tabBarTheme_ = tabBarTheme.copyWith(
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2.0,
          color: indicatorColor_,
        ),
      ),
      labelColor: labelColor,
    );
    // AppBar
    // * M3時のelevation調整（独自研究）
    final appBarTheme_ = appBarTheme.copyWith(
      elevation: useMaterial3 ? 2.0 : null,
      shadowColor: useMaterial3 ? Colors.black : null,
    );

    return copyWith(
      textButtonTheme: textButtonTheme_,
      outlinedButtonTheme: outlinedButtonTheme_,
      elevatedButtonTheme: elevatedButtonTheme_,
      checkboxTheme: checkboxTheme_,
      // radioTheme: radioTheme_,
      // switchTheme: switchTheme_,
      toggleButtonsTheme: toggleButtonsTheme_,
      listTileTheme: listTileTheme_,
      expansionTileTheme: expansionTileTheme_,
      snackBarTheme: snackBarTheme_,
      tabBarTheme: tabBarTheme_,
      appBarTheme: appBarTheme_,
      // *ListTileのselectedColor
      // TODO: source link
      toggleableActiveColor: foregroundColor,
    );
  }
}
