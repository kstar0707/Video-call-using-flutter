import 'package:flutter/material.dart';

class PopupMenuTitle extends StatelessWidget {
  const PopupMenuTitle({
    super.key,
    required this.title,
    this.icon,
    this.color,
  });

  final String title;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: color)),
      ],
    );
  }
}
