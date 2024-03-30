import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width,
    this.height = 120,
    this.color,
  });

  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/app_logo.png",
      width: width,
      height: height,
      color: color,
    );
  }
}
