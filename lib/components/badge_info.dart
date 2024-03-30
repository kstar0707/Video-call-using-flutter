import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';

class BadgeInfo extends StatelessWidget {
  const BadgeInfo({
    super.key,
    this.child,
    this.bgColor = Colors.transparent,
    this.borderColor = Colors.transparent,
    this.borderRadius = defaultRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  });

  final Widget? child;
  final Color bgColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: defaultMargin * 0.5),
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
