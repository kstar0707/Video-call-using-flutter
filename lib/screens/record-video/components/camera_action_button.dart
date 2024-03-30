import 'package:flutter/material.dart';

class CameraActionButton extends StatelessWidget {
  const CameraActionButton({
    super.key,
    required this.icon,
    this.color = Colors.white,
    this.padding = 8,
    required this.onTap,
  });

  // Params
  final Widget icon;
  final Color? color;
  final double padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black26,
          ),
          child: icon,
        ),
      ),
    );
  }
}
