// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

extension BrightnessHelper on Brightness {
  bool get isDark => this == Brightness.dark;
}

extension SwitchThemeDataHelper on SwitchThemeData {
  SwitchThemeData modifyWith({
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
  // ignore: unused_field
  static final _logger = Logger('ThemeDataExtension');

  bool get isDark => brightness.isDark;

  /// [TextButton]の文字色
  /// 独自研究
  Color get foregroundColor => isDark ? colorScheme.secondary : primaryColorDark;

  /// ListTileのIconやCheckbox, Radioの色。disabledColorとonSurfaceの中間
  /// s.a. https://github.com/flutter/flutter/blob/cc2aedd17aee7203a035a8b3f5968ce040bfbe8f/packages/flutter/lib/src/material/list_tile.dart#L609
  Color get unselectedIconColor => colorScheme.onSurface.withAlpha(0x73);

  /// ListTileのデフォルトのパディング
  /// s.a. https://api.flutter.dev/flutter/material/ListTile/contentPadding.html
  EdgeInsetsGeometry get listTileContentPadding =>
      (listTileTheme.contentPadding) ?? const EdgeInsets.symmetric(horizontal: 16.0);

  /// 現状のmaterial widgetsの実装は、ダークテーマの挙動がまちまちなので、一貫するよう調整
  ThemeData modify({
    Color? textColor,
    Color? backgroundColor,
  }) {
    final foregroundColor_ = foregroundColor;

    // ColorScheme
    // * ボタンの文字色
    final colorScheme_ = colorScheme.copyWith(
      onPrimary: brightness.isDark ? null : backgroundColor,
      onSurface: brightness.isDark ? backgroundColor : null,
    );

    // TextButton, OutlinedButton
    // * ダーク時の色をsecondaryに変更
    // * ライト時の色をprimaryColorDarkに変更
    Color? Function(Set<MaterialState> states) resolveButtonColor(Color color) {
      return (Set<MaterialState> states) => states.contains(MaterialState.disabled) ? null : color;
    }

    final textButtonTheme_ = TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(resolveButtonColor(foregroundColor_)),
      ).merge(textButtonTheme.style),
    );

    final outlinedButtonTheme_ = OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(resolveButtonColor(foregroundColor_)),
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

    // Slider
    // * ダーク時の色をsecondaryに変更
    // s.a. https://github.com/flutter/flutter/blob/b7b8b759bc3ab7a80d2576d52f7b05bc1e6e23bd/packages/flutter/lib/src/material/theme_data.dart#L500
    final secondarySwatch = colorScheme.secondary.toMaterialColor();
    final sliderTheme_ = SliderThemeData.fromPrimaryColors(
      primaryColor: isDark ? colorScheme.secondary : primaryColor,
      primaryColorDark: isDark ? secondarySwatch[700]! : primaryColorDark,
      primaryColorLight: isDark ? secondarySwatch[100]! : primaryColorLight,
      valueIndicatorTextStyle: sliderTheme.valueIndicatorTextStyle ?? textTheme.bodyMedium!,
    );

    // ToggleButtons
    // * ダーク時の色をsecondaryに変更
    // * ライト時の色をprimaryColorDarkに変更
    final toggleButtonsTheme_ = toggleButtonsTheme.copyWith(
      selectedColor: foregroundColor_,
      // TODO: SOURCE LINK
      fillColor: foregroundColor_.withOpacity(0.12),
    );

    // ListTile
    // * ダーク時の色をsecondaryに変更
    final listTileTheme_ = listTileTheme.copyWith(
      selectedColor: foregroundColor_,
    );

    // ExpansionTile
    // * ダーク時の色をsecondaryに変更
    final expansionTileTheme_ = expansionTileTheme.copyWith(
      textColor: foregroundColor_,
      iconColor: foregroundColor_,
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

    // TextTheme, IconTheme
    // * ダーク時の文字色
    final textColor_ = isDark ? backgroundColor : textColor;
    final textTheme_ = backgroundColor != null
        ? textTheme.apply(
            bodyColor: textColor_,
            displayColor: textColor_,
          )
        : textTheme;

    final iconTheme_ = backgroundColor != null
        ? iconTheme.copyWith(
            color: textColor_,
          )
        : iconTheme;

    // ProgressIndicators
    final progressIndicatorTheme_ = progressIndicatorTheme.copyWith(
      color: isDark ? colorScheme.secondary : null,
    );

    return copyWith(
      colorScheme: colorScheme_,
      textButtonTheme: textButtonTheme_,
      outlinedButtonTheme: outlinedButtonTheme_,
      elevatedButtonTheme: elevatedButtonTheme_,
      checkboxTheme: checkboxTheme_,
      // radioTheme: radioTheme_,
      // switchTheme: switchTheme_,
      sliderTheme: sliderTheme_,
      toggleButtonsTheme: toggleButtonsTheme_,
      listTileTheme: listTileTheme_,
      expansionTileTheme: expansionTileTheme_,
      snackBarTheme: snackBarTheme_,
      tabBarTheme: tabBarTheme_,
      appBarTheme: appBarTheme_,
      // *ListTileのselectedColor
      // TODO: source link
      toggleableActiveColor: foregroundColor_,
      scaffoldBackgroundColor: isDark ? null : backgroundColor,
      textTheme: textTheme_,
      iconTheme: iconTheme_,
      progressIndicatorTheme: progressIndicatorTheme_,
    );
  }
}
