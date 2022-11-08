import 'package:flutter/material.dart';

class MiToggleButtons extends StatelessWidget {
  final bool enabled;
  final int? split;
  final List<Widget> children;
  final List<bool> isSelected;
  final ValueChanged<int>? onPressed;

  const MiToggleButtons({
    super.key,
    this.enabled = true,
    this.split,
    required this.children,
    required this.isSelected,
    this.onPressed,
  })  : assert(children.length == isSelected.length),
        assert(split == null || split >= 2);

  @override
  Widget build(BuildContext context) {
    if (split == null) {
      return ToggleButtons(
        isSelected: isSelected,
        onPressed: enabled ? onPressed : null,
        children: children,
      );
    }

    final n = split!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i += n)
          ToggleButtons(
            isSelected: isSelected.skip(i).take(n).toList(),
            onPressed: enabled ? (index) => onPressed?.call(index + i) : null,
            children: children.skip(i).take(n).toList(),
          ),
      ],
    );
  }
}
