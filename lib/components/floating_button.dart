import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({
    super.key,
    required this.icon,
    this.onPress,
    this.bgColor,
  });

  final IconData icon;
  final Function()? onPress;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: bgColor ?? primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      onPressed: onPress,
      child: Icon(icon, color: Colors.white, size: 32),
    );
  }
}
