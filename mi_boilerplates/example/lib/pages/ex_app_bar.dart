// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

import '../main.dart';

/// Exampleアプリでウィジェットの[enable]を切り替えて動作を見る情況が頻出するので、一個フラグを設ける。
/// 各ウィジェットの対応はそれぞれのページで行う。
final enableActionsProvider = StateProvider((ref) => true);

final prominentProvider = StateProvider((ref) => false);

class _EnableActionsSwitch extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(enableActionsProvider.state);
    final enableActions = state.state;

    return Tooltip(
      message: enableActions ? 'Enable actions: ON' : 'Enable actions: OFF',
      child: Switch(
        value: enableActions,
        onChanged: (value) => state.state = value,
      ),
    );
  }
}

class _BrightnessButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(enableActionsProvider);
    final state = ref.watch(brightnessProvider.state);
    final isDark = state.state.isDark;

    return MiIconButton(
      enabled: enabled,
      icon: isDark ? const Icon(Icons.dark_mode_outlined) : const Icon(Icons.light_mode_outlined),
      onPressed: () {
        state.state = isDark ? Brightness.light : Brightness.dark;
      },
      tooltip: isDark ? 'Brightness: DARK' : 'Brightness: LIGHT',
    );
  }
}

class _UseMaterial3Button extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(enableActionsProvider);
    final useM3 = ref.watch(useM3Provider);

    return MiIconButton(
      enabled: enabled,
      icon: useM3 ? const Icon(Icons.filter_3_outlined) : const Icon(Icons.filter_2_outlined),
      onPressed: () {
        ref.read(useM3Provider.state).state = !useM3;
      },
      tooltip: useM3 ? 'Material design: 3' : 'Material design: 2',
    );
  }
}

class _UseMiThemeCheckbox extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(enableActionsProvider);
    final state = ref.watch(useMiThemesProvider.state);
    final useMiTheme = state.state;

    return Tooltip(
      message: useMiTheme ? 'Use mi theme: ON' : 'Use mi theme: OFF',
      child: Checkbox(
        value: useMiTheme,
        onChanged: enabled ? (value) => state.state = value! : null,
      ),
    );
  }
}

class _PopupMenu extends ConsumerWidget {
  static final _logger = Logger((_PopupMenu).toString());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(enableActionsProvider);

    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          MiCheckPopupMenuItem(
            checked: enabled,
            child: const Text('Enable actions'),
            onChanged: (value) {
              ref.read(enableActionsProvider.state).state = value;
            },
          ),
          MiCheckPopupMenuItem(
            enabled: enabled,
            checked: ref.watch(useMiThemesProvider),
            child: const Text('Use MiThemes'),
            onChanged: (value) {
              ref.read(useMiThemesProvider.state).state = value;
            },
          ),
          MiCheckPopupMenuItem(
            enabled: enabled,
            checked: ref.watch(useM3Provider),
            child: const Text('Use M3'),
            onChanged: (value) {
              ref.read(useM3Provider.state).state = value;
            },
          ),
          MiCheckPopupMenuItem(
            enabled: enabled,
            checked: ref.watch(brightnessProvider) == Brightness.dark,
            child: const Text('Dark mode'),
            onChanged: (value) {
              ref.read(brightnessProvider.state).state = value ? Brightness.dark : Brightness.light;
            },
          ),
          MiPopupMenuItem(
            enabled: enabled,
            child: const MiIcon(
              text: Text('Color settings...'),
            ),
            onTap: () {
              _logger.fine('tap!');
            },
          ),
        ];
      },
      offset: const Offset(0, 40),
      tooltip: <String>[
        if (ref.read(enableActionsProvider)) 'Enabled',
        if (ref.read(useMiThemesProvider)) 'MiTheme',
        ref.read(useM3Provider) ? 'M3' : 'M2',
        if (ref.read(brightnessProvider) == Brightness.dark) 'Dark',
      ].join(', '),
      //icon: const Icon(Icons.square),
    );
  }
}

class ExAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool prominent;
  final Widget? leading;
  final Widget title;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final List<Widget>? actions;
  final bool? centerTitle;
  final double? toolbarHeight;

  const ExAppBar({
    super.key,
    this.prominent = false,
    this.leading,
    required this.title,
    this.bottom,
    this.flexibleSpace,
    this.actions,
    this.centerTitle,
    this.toolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        MiAppBar.preferredHeight(
          prominent: prominent,
          bottom: bottom,
          toolbarHeight: toolbarHeight,
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MiAppBar(
      prominent: prominent,
      leading: leading,
      title: InkWell(
        onTap: () {
          ref.read(prominentProvider.state).state = !prominent;
        },
        child: title,
      ),
      bottom: bottom,
      flexibleSpace: flexibleSpace,
      actions: <Widget>[
        if (actions != null) ...actions!,
        if (prominent) ...[
          _EnableActionsSwitch(),
          _UseMiThemeCheckbox(),
          _UseMaterial3Button(),
          _BrightnessButton(),
        ] else
          _PopupMenu(),
      ],
      centerTitle: centerTitle,
    );
  }
}
