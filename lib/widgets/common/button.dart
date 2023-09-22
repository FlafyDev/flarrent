import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InkButton extends HookConsumerWidget {
  const InkButton({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.color,
    this.onPressed,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final Color? color;
  final EdgeInsets? padding;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: borderRadius,
      splashColor: Colors.blue.shade700.withOpacity(0.2),
      highlightColor: Colors.blue.shade700.withOpacity(0.2),
      onTap: onPressed,
      child: color != null || padding != null
          ? Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: color,
              ),
              padding: padding,
              child: child,
            )
          : child,
    );
  }
}
