import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/models/call_history.dart';
import 'package:get/get.dart';

class CallTypeMessage extends StatelessWidget {
  const CallTypeMessage(
    this.type, {
    super.key,
  });

  final CallType type;

  @override
  Widget build(BuildContext context) {
    Widget icon = const SizedBox.shrink();
    Widget title = const SizedBox.shrink();
    TextStyle? style = Theme.of(context).textTheme.bodyMedium;

    switch (type) {
      case CallType.incoming:
        icon = const Icon(
          IconlyBold.arrowDownSquare,
          color: primaryColor,
          size: 20,
        );
        title = Text('incoming'.tr, style: style);
        break;
      case CallType.outgoing:
        icon = const Icon(
          IconlyBold.arrowUpSquare,
          color: Color(0xFF4ADE80),
          size: 20,
        );
        title = Text('outgoing'.tr, style: style);
        break;
      case CallType.missed:
        icon = const Icon(
          IconlyBold.closeSquare,
          color: errorColor,
          size: 20,
        );
        title = Text('missed'.tr, style: style);
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [icon, const SizedBox(width: 4), title],
    );
  }
}
