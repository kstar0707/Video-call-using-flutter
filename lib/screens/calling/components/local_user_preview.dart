import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';

class LocalUserPreview extends StatelessWidget {
  const LocalUserPreview({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 96,
        height: 120,
        margin: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultRadius),
          border: Border.all(
            color: Colors.white54,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(defaultRadius),
          child: child,
        ),
      ),
    );
  }
}
