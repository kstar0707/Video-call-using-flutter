import 'package:chat_messenger/config/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    super.key,
    this.onPress,
    this.text,
    this.child,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.elevation,
    this.isText = true,
    this.isOutline = false,
    this.isLoading = false,
  });

  final String? text;
  final Widget? child;
  final Color? color, textColor;
  final double? width, height, elevation;
  final bool isText, isOutline, isLoading;
  final Function()? onPress;

  @override
  Widget build(BuildContext context) {
    // Vars
    Widget? buttonChild, textWidget;

    // Check text param
    if (isText) {
      textWidget = Text(
        text ?? '',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: isOutline ? null : textColor ?? Colors.white),
      );
    }

    // Check loading status
    if (isLoading) {
      buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('processing'.tr, style: const TextStyle(color: Colors.white)),
          const SpinKitThreeBounce(size: 25, color: Colors.white),
        ],
      );
    } else {
      buttonChild = isText ? textWidget : child;
    }

    return SizedBox(
      width: width,
      height: height ?? 50,
      child: isOutline
          ? OutlinedButton(
              onPressed: isLoading ? () {} : onPress,
              style: OutlinedButton.styleFrom(
                backgroundColor: color,
                elevation: elevation,
              ),
              child: buttonChild,
            )
          : ElevatedButton(
              onPressed: isLoading ? () {} : onPress,
              style: ElevatedButton.styleFrom(
                elevation: elevation,
                backgroundColor: color ?? primaryColor,
              ),
              child: buttonChild,
            ),
    );
  }
}
