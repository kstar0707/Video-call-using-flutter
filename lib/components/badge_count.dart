import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';

class BadgeCount extends StatelessWidget {
  const BadgeCount({
    super.key,
    this.counter = 0,
    this.bgColor = primaryColor,
  });

  final int counter;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    if (counter == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        counter.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
