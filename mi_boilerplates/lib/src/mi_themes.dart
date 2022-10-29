// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

extension BrightnessExtension on Brightness {
  bool get isDark => this == Brightness.dark;
}

extension SwitchThemeDataHelper on SwitchThemeData {
  SwitchThemeData withColor({
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

  /// ListTileのデフォルトのIconやCheckbox, Radioの色。disabledColorとonSurfaceの中間。
  /// s.a. https://github.com/flutter/flutter/blob/cc2aedd17aee7203a035a8b3f5968ce040bfbe8f/packages/flutter/lib/src/material/list_tile.dart#L609
  Color get unselectedIconColor => colorScheme.onSurface.withAlpha(0x73);

  /// ListTileのデフォルトのパディング。
  /// s.a. https://api.flutter.dev/flutter/material/ListTile/contentPadding.html
  EdgeInsetsGeometry get listTileContentPadding =>
      (listTileTheme.contentPadding) ?? const EdgeInsets.symmetric(horizontal: 16.0);

  /// 現状のmaterial widgetsの実装では、ダークテーマの挙動がまちまちなので、一貫性を持たせる。
  ///
  /// * ウィジェットの基本色はライト時はprimary color, ダーク時はsecondary color。
  ///   参照 https://material.io/design/color/dark-theme.html#anatomy
  /// その他、
  /// * SnackBar
  ///   actionTextColorがちょっと見づらいので調整
  /// * TabBar
  ///   ラベルの色が明暗に関わらず固定なので対応する。
  ///   M3時のインジケータ位置調整。
  /// * AppBar.
  ///   M3時のelevationの調整。

  ThemeData withMiThemes() {
    // ボタンのforegroundColor
    // * ダークテーマ時はsecondary。
    // * ライトテーマ時はprimaryだが、明るい色だと文字・アイコンが見づらくなるので調整する。
    final foregroundColor = isDark
        ? colorScheme.secondary
        : HSLColor.fromColor(colorScheme.primary).let((it) {
            // 独自研究による閾値
            if (it.lightness <= 0.53) {
              return colorScheme.primary;
            }
            final index = colorScheme.primary.indexOfPrimaries();
            if (index >= 0) {
              return Colors.primaries[index].shade800;
            }
            return it.withLightness((it.lightness - 0.2).clamp(0, 1)).toColor();
          });

    Color Function(Set<MaterialState> states) resolveButtonColor(
      Color color,
      Color disabledColor,
    ) {
      return (Set<MaterialState> states) =>
          states.contains(MaterialState.disabled) ? disabledColor : color;
    }

    // TextButton, OutlinedButton
    // * foregroundColor調整
    // * ダークテーマ時の色をCheckbox等と同じくsecondaryに変更。
    final textButtonTheme_ = TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(
          resolveButtonColor(foregroundColor, disabledColor),
        ),
      ).merge(textButtonTheme.style),
    );

    final outlinedButtonTheme_ = OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(
          resolveButtonColor(foregroundColor, disabledColor),
        ),
      ).merge(outlinedButtonTheme.style),
    );

    // ElevatedButton
    // * ダークテーマ時の色をsecondaryに変更。
    final elevatedButtonTheme_ = ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(
          resolveButtonColor(
            isDark ? colorScheme.onSecondary : colorScheme.onPrimary,
            disabledColor,
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
          // TODO: SOURCE LINK
          resolveButtonColor(
            isDark ? colorScheme.secondary : colorScheme.primary,
            colorScheme.onSurface.withOpacity(0.12),
          ),
        ),
      ).merge(elevatedButtonTheme.style),
    );

    // Checkbox, Radio
    // * ライトテーマ時のforegroundColor調整
    // TODO: ダーク時、checkColorをsurfaceにした方が良い？（secondaryが明色だとvと-が見分けづらいので）
    Color resolveToggleableColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return disabledColor;
      } else if (states.contains(MaterialState.selected)) {
        return isDark ? colorScheme.secondary : foregroundColor;
      } else {
        return unselectedWidgetColor;
      }
    }

    final checkboxTheme_ = checkboxTheme.copyWith(
      fillColor: MaterialStateProperty.resolveWith(resolveToggleableColor),
    );
    final radioTheme_ = radioTheme.copyWith(
      fillColor: MaterialStateProperty.resolveWith(resolveToggleableColor),
    );

    // Switch
    // * ライトテーマ時のforegroundColor調整
    final switchTheme_ = switchTheme.withColor(
      thumbColor: foregroundColor,
      brightness: brightness,
    );

    // TODO: Slider.
    // https://github.com/flutter/flutter/blob/cc2aedd17aee7203a035a8b3f5968ce040bfbe8f/packages/flutter/lib/src/material/slider.dart#L743

    // ToggleButtons
    // * ダークテーマ時のselectedColorをsecondaryに変更
    final toggleButtonsTheme_ = toggleButtonsTheme.copyWith(
      selectedColor: foregroundColor,
      // TODO: SOURCE LINK
      fillColor: foregroundColor.withOpacity(0.12),
    );

    // ListTile
    // * ダークテーマ時のselectedColorをsecondaryに変更
    final listTileTheme_ = listTileTheme.copyWith(
      selectedColor: foregroundColor,
    );

    // ExpansionTile
    // * ダークテーマ時のselectedColorをsecondaryに変更
    final expansionTileTheme_ = expansionTileTheme.copyWith(
      textColor: foregroundColor,
      iconColor: foregroundColor,
    );

    // SnackBar
    // * actionTextColorをちょっと見やすく
    // TODO: ライトテーマ時はprimaryの明色を試す
    final snackBarTheme_ = snackBarTheme.copyWith(
      actionTextColor: isDark
          ? Color.alphaBlend(colorScheme.secondary.withAlpha(178), colorScheme.surface)
          : Color.alphaBlend(colorScheme.secondary.withAlpha(160), colorScheme.surface),
    );

    // TabBar
    // * ラベル文字色のマテリアルデザイン3対応
    // * インジケータ位置もちょっと調整（独自研究）
    final tabBarTheme_ = tabBarTheme.copyWith(
      labelColor: useMaterial3
          ? colorScheme.onSurface
          : isDark
              ? colorScheme.onSurface
              : colorScheme.onPrimary,
      indicator: useMaterial3
          ? UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2.0,
                color: colorScheme.onSurface,
              ),
              insets: const EdgeInsets.only(bottom: 4.0),
            )
          : null,
    );

    // AppBar
    // * マテリアルデザイン3の見栄え調整（独自研究）
    final appBarTheme_ = appBarTheme.copyWith(
      elevation: useMaterial3 ? 4.0 : null,
      shadowColor: useMaterial3 ? Colors.black : null,
    );

    return copyWith(
      textButtonTheme: textButtonTheme_,
      outlinedButtonTheme: outlinedButtonTheme_,
      elevatedButtonTheme: elevatedButtonTheme_,
      checkboxTheme: checkboxTheme_,
      radioTheme: radioTheme_,
      switchTheme: switchTheme_,
      toggleButtonsTheme: toggleButtonsTheme_,
      listTileTheme: listTileTheme_,
      expansionTileTheme: expansionTileTheme_,
      snackBarTheme: snackBarTheme_,
      tabBarTheme: tabBarTheme_,
      appBarTheme: appBarTheme_,
      // *ListTileのselectedColor
      toggleableActiveColor: foregroundColor,
    );
  }
}
