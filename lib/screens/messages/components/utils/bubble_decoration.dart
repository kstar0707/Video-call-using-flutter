import 'package:chat_messenger/config/theme_config.dart';
import 'package:flutter/material.dart';

BoxDecoration getBubbleDecoration(bool isSender) {
  return BoxDecoration(
    color: isSender ? primaryColor.withOpacity(.2) : greyLight,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(!isSender ? 2 : 15),
      topRight: const Radius.circular(15),
      bottomLeft: const Radius.circular(15),
      bottomRight: Radius.circular(!isSender ? 15 : 2),
    ),
  );
}
