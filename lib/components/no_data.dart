import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';

class NoData extends StatelessWidget {
  const NoData({
    super.key,
    required this.text,
    this.textColor,
    this.iconData,
    this.iconSize = 100,
    this.customIcon,
  });

  // Variables
  final String text;
  final Color? textColor;
  final IconData? iconData;
  final double iconSize;
  final Widget? customIcon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Show icon
          customIcon ?? Icon(iconData, color: primaryColor, size: iconSize),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(fontSize: 18, color: textColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
