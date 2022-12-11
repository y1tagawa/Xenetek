// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart' hide ExpansionTile;
import 'package:flutter/material.dart' as material show ExpansionTile;
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

/// カスタム[ExpansionTile]
///
/// * [enabled]追加、それに合わせ動作もいろいろ変更。

class ExpansionTile extends StatelessWidget {
  //<editor-fold>
  final bool enabled;
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final ValueChanged<bool>? onExpansionChanged;
  final List<Widget> children;
  final Widget? trailing;
  final bool initiallyExpanded;
  final bool maintainState;
  final EdgeInsetsGeometry? tilePadding;
  final CrossAxisAlignment? expandedCrossAxisAlignment;
  final Alignment? expandedAlignment;
  final EdgeInsetsGeometry? childrenPadding;
  final Color? backgroundColor;
  final Color? collapsedBackgroundColor;
  final Color? textColor;
  final Color? collapsedTextColor;
  final Color? iconColor;
  final Color? collapsedIconColor;
  final ListTileControlAffinity? controlAffinity;
  final Color? dividerColor;
//</editor-fold>

  const ExpansionTile({
    //<editor-fold>
    super.key,
    this.enabled = true,
    this.leading,
    required this.title,
    this.subtitle,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.initiallyExpanded = false,
    this.maintainState = false,
    this.tilePadding,
    this.expandedCrossAxisAlignment,
    this.expandedAlignment,
    this.childrenPadding,
    this.backgroundColor,
    this.collapsedBackgroundColor,
    this.textColor,
    this.collapsedTextColor,
    this.iconColor,
    this.collapsedIconColor,
    this.controlAffinity,
    this.dividerColor,
    //</editor-fold>
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabledColor = theme.disabledColor;

    return IgnorePointer(
      ignoring: !enabled,
      child: Theme(
        data: theme.copyWith(dividerColor: dividerColor),
        child: ExpansionTileTheme(
          data: theme.expansionTileTheme.copyWith(
            iconColor: enabled ? null : disabledColor,
            textColor: enabled ? null : disabledColor,
            collapsedIconColor: enabled ? null : disabledColor,
            collapsedTextColor: enabled ? null : disabledColor,
          ),
          child: mi.DefaultTextColor(
            color: enabled ? null : disabledColor,
            child: material.ExpansionTile(
              initiallyExpanded: initiallyExpanded,
              leading: leading,
              title: title,
              subtitle: subtitle,
              onExpansionChanged: onExpansionChanged,
              trailing: trailing,
              maintainState: maintainState,
              tilePadding: tilePadding,
              expandedCrossAxisAlignment: expandedCrossAxisAlignment,
              expandedAlignment: expandedAlignment,
              childrenPadding: childrenPadding,
              backgroundColor: backgroundColor,
              collapsedBackgroundColor: collapsedBackgroundColor,
              textColor: textColor,
              collapsedTextColor: collapsedTextColor,
              iconColor: iconColor,
              collapsedIconColor: collapsedIconColor,
              controlAffinity: controlAffinity,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// [ListTile]のテキストボタン的用法
///
/// * 頻出コード

class ButtonListTile extends StatelessWidget {
  final bool enabled;
  final bool selected;
  final Widget? leading;
  final Widget? trailing;
  final Widget? icon;
  final Widget text;
  final Widget? title;
  final MainAxisAlignment alignment;
  final TextDirection iconPosition;
  final VoidCallback? onPressed;

  const ButtonListTile({
    super.key,
    this.enabled = true,
    this.selected = false,
    this.leading,
    this.trailing,
    this.icon,
    required this.text,
    this.title,
    this.alignment = MainAxisAlignment.center,
    this.iconPosition = TextDirection.ltr,
    this.onPressed,
    // TODO: 他のプロパティ
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = enabled ? theme.foregroundColor : null;

    Widget? subtitle_;
    Widget title_ = Row(
      mainAxisAlignment: alignment,
      children: [
        mi.DefaultTextColor(
          color: textColor,
          child: icon != null
              ? mi.MiIcon(
                  icon: icon,
                  text: text,
                  iconPosition: iconPosition,
                )
              : text,
        ),
      ],
    );

    if (title != null) {
      subtitle_ = title_;
      title_ = Row(
        mainAxisAlignment: alignment,
        children: [title!],
      );
    }

    return ListTile(
      enabled: enabled,
      selected: selected,
      leading: leading?.let((it) => mi.DefaultTextColor(color: textColor, child: it)),
      trailing: trailing?.let((it) => mi.DefaultTextColor(color: textColor, child: it)),
      title: title_,
      subtitle: subtitle_,
      onTap: onPressed,
    );
  }
}
