import 'package:chat_messenger/components/svg_icon.dart';
import 'package:flutter/material.dart';

class ScrollDownButton extends StatelessWidget {
  const ScrollDownButton({
    super.key,
    required this.onPress,
  });

  // Params
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPress,
      elevation: 6.0,
      fillColor: const Color(0xFFF9F8F8),
      constraints: const BoxConstraints(),
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(8),
      child: const SvgIcon(
        'assets/icons/arrow_double_down.svg',
        width: 14,
        height: 11,
        color: Colors.black54,
      ),
    );
  }
}
