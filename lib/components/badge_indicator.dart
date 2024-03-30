import 'package:flutter/material.dart';

class BadgeIndicator extends StatelessWidget {
  const BadgeIndicator({
    super.key,
    required this.icon,
    required this.isNew,
    this.iconSize,
    this.iconColor,
  });

  final IconData icon;
  final bool isNew;
  final double? iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(
          icon, size: iconSize, color: iconColor,
        ),
        if (isNew) const Positioned(right: 0, child: Badge(smallSize: 8))
      ],
    );
  }
}
