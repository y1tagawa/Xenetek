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

/// Shows a dialog with an information icon and OK button.

Future<void> showInfoOkDialog({
  required BuildContext context,
  Widget? icon,
  Widget? title,
  Widget? content,
  bool barrierDismissible = true,
  bool scrollable = false,
  Widget? okText,
}) async {
  return await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
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
    barrierDismissible: barrierDismissible,
  );
}

/// Shows a dialog with an warning icon and OK and cancel buttons.
///
/// Returns `true` for OK, or `false` for cancel.

Future<bool> showWarningOkCancelDialog({
  required BuildContext context,
  Widget? icon,
  Widget? title,
  Widget? content,
  bool barrierDismissible = true,
  bool scrollable = false,
  Widget? okText,
  Widget? cancelText,
}) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
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
    barrierDismissible: barrierDismissible,
  ).then(
    (value) => value ?? false,
  );
}

/// OK/Cancelダイアログの枠

class MiOkCancelDialog<T> extends StatelessWidget {
  final Widget? icon;
  final Widget? title;
  final Widget? content;
  final bool scrollable;
  final T Function(bool ok) getValue;

  const MiOkCancelDialog({
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
