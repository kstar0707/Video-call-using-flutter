import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(
    this.svgPath, {
    super.key,
    this.color,
    this.width,
    this.height,
  });

  final String svgPath;
  final Color? color;
  final double? width, height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svgPath,
      width: width,
      height: width,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
