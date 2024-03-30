import 'package:chat_messenger/config/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class EmojiMedia extends StatelessWidget {
  const EmojiMedia({
    super.key,
    this.textController,
    this.onSelected,
  });

  // Params
  final TextEditingController? textController;
  final Function(Category?, Emoji)? onSelected;

  @override
  Widget build(BuildContext context) {
    return EmojiPicker(
      textEditingController: textController,
      onEmojiSelected: onSelected,
      config: const Config(
        emojiViewConfig: EmojiViewConfig(
          columns: 8,
          emojiSizeMax: 32,
        ),
        bottomActionBarConfig: BottomActionBarConfig(
          backgroundColor: greyLight,
          buttonColor: Colors.transparent,
          buttonIconColor: Color(0xFF808080),
        )
      ),
    );
  }
}
