import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.text,
    this.fontSize = 18,
    this.color = primaryColor,
  });

  final String text;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(color: color, fontSize: fontSize));
  }
}
