// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

const _iconSize = 48.0;
const _infoIcon = Icon(Icons.info_outline, size: _iconSize);
// ignore: unused_element
const _questionIcon = Icon(Icons.help_outline, size: _iconSize);
const _warningIcon = Icon(Icons.report_problem_outlined, size: _iconSize);
// ignore: unused_element
const _errorIcon = Icon(Icons.block_outlined, size: _iconSize);

const _okText = Text('OK');
const _cancelText = Text('CANCEL');

/// [data]を省略しても良い[Theme]
class _Theme extends StatelessWidget {
  final ThemeData? data;
  final Widget child;

  const _Theme({super.key, this.data, required this.child});

  @override
  Widget build(BuildContext context) {
    return data != null ? Theme(data: data!, child: child) : child;
  }
}

/// 情報アイコンとOKボタンを表示するダイアログ。
///
Future<void> showInfoOkDialog({
  required BuildContext context,
  Widget? icon,
  Widget? title,
  Widget? content,
  bool barrierDismissible = true,
  bool scrollable = false,
  Widget? okText,
  ThemeData? theme,
}) async {
  return await showDialog<void>(
    context: context,
    builder: (context) => _Theme(
      data: theme,
      child: AlertDialog(
        icon: icon ?? _infoIcon,
        title: title,
        content: content,
        scrollable: scrollable,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: okText ?? _okText,
          ),
        ],
      ),
    ),
    barrierDismissible: barrierDismissible,
  );
}

/// 警告アイコンとOK、キャンセルボタンを表示するダイアログ。
///
/// OKに対して`true`、キャンセルに対して`false`を返す。
Future<bool> showWarningOkCancelDialog({
  required BuildContext context,
  Widget? icon,
  Widget? title,
  Widget? content,
  bool barrierDismissible = true,
  bool scrollable = false,
  Widget? okText,
  Widget? cancelText,
  ThemeData? theme,
}) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => _Theme(
      data: theme,
      child: AlertDialog(
        icon: icon ?? _warningIcon,
        title: title,
        content: content,
        scrollable: scrollable,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: cancelText ?? _cancelText,
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: okText ?? _okText,
          ),
        ],
      ),
    ),
    barrierDismissible: barrierDismissible,
  ).then(
    (value) => value ?? false,
  );
}

/// OK/Cancelダイアログの枠

class OkCancelDialog<T> extends StatelessWidget {
  final Widget? icon;
  final Widget? title;
  final Widget? content;
  final bool scrollable;
  final T Function(bool ok) getValue;

  const OkCancelDialog({
    super.key,
    this.icon,
    this.title,
    this.content,
    this.scrollable = false,
    required this.getValue,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: icon,
      title: title,
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, getValue(false)),
          child: _cancelText,
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, getValue(true)),
          child: _okText,
        ),
      ],
    );
  }
}
