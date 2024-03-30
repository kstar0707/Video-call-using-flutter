import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';

class CallBackground extends StatelessWidget {
  const CallBackground({
    super.key,
    required this.preview,
    required this.child,
    this.remoteUid,
  });

  final Widget preview;
  final Widget child;
  final int? remoteUid;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        preview,
        // Check remote user
        if (remoteUid == null)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  secondaryColor,
                ],
                stops: [0, 0.2, 0.5, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        child,
      ],
    );
  }
}
