import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  const CircleButton({
    super.key,
    required this.icon,
    this.onPress,
    this.color,
    this.size = 56,
  });

  final Widget icon;
  final Function()? onPress;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: color ?? Colors.white30,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onPress,
          child: SizedBox(
            width: size,
            height: size,
            child: icon,
          ),
        ),
      ),
    );
  }
}
