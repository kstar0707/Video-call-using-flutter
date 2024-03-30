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
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : null,
          borderRadius: BorderRadius.circular(defaultPadding * 2),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
