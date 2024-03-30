import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';

class SwitchActionButton extends StatelessWidget {
  const SwitchActionButton(
    this.title, {
    super.key,
    this.isSelected = false,
    this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white54,
          borderRadius: BorderRadius.circular(defaultPadding * 2),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
