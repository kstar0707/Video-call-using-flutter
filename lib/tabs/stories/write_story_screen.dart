import 'dart:math';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/api/story_api.dart';
import 'package:chat_messenger/components/floating_button.dart';
import 'package:chat_messenger/components/loading_indicator.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:get/get.dart';

class WriteStoryScreen extends StatefulWidget {
  const WriteStoryScreen({super.key});

  @override
  State<WriteStoryScreen> createState() => _WriteStoryScreenState();
}

class _WriteStoryScreenState extends State<WriteStoryScreen> {
  final FocusNode _keyboardFocus = FocusNode();
  final TextEditingController _textController = TextEditingController();
  Color backgroundColor = Colors.black;
  bool showEmojiKeyboard = false;
  bool isLoading = false;

  void _toggleEmojiKeyboard() {
    setState(() {
      showEmojiKeyboard = !showEmojiKeyboard;
    });
    if (showEmojiKeyboard) {
      _keyboardFocus.unfocus();
    } else {
      _keyboardFocus.requestFocus();
    }
  }

  void _generateBackgroundColor() {
    backgroundColor =
        Colors.primaries[Random().nextInt(Colors.primaries.length)];
  }

  @override
  void initState() {
    super.initState();
    _generateBackgroundColor();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        if (_textController.text.isEmpty) {
          Navigator.pop(context);
          return;
        }

        DialogHelper.showAlertDialog<bool>(
          title: Text('discard_this_story'.tr),
          actionText: 'discard'.tr.toUpperCase(),
          action: () {
            Navigator.pop(context); // Close modal 
            Navigator.pop(context); // Close page
          },
        );
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: const CloseButton(
            style: ButtonStyle(
              splashFactory: NoSplash.splashFactory,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _toggleEmojiKeyboard,
              icon: Icon(
                showEmojiKeyboard
                    ? Icons.keyboard_outlined
                    : Icons.emoji_emotions_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                setState(() => _generateBackgroundColor());
              },
              icon: const Icon(Icons.palette_outlined, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: TextField(
                maxLines: null,
                controller: _textController,
                focusNode: _keyboardFocus,
                textAlign: TextAlign.center,
                autofocus: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: backgroundColor,
                  hintText: 'type_a_story'.tr,
                  hintStyle: const TextStyle(fontSize: 24, color: Colors.white),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const Spacer(),
            if (showEmojiKeyboard) ...{
              SizedBox(
                height: 300,
                child: EmojiPicker(
                  onEmojiSelected: ((category, emoji) {
                    setState(() {
                      _textController.text = _textController.text + emoji.emoji;
                    });
                  }),
                ),
              )
            },
          ],
        ),
        floatingActionButton: Column(
          children: [
            const Spacer(),
            if (showEmojiKeyboard) ...{
              const SizedBox(height: 125.0),
            },
            if (isLoading)
              const LoadingIndicator(size: 50, color: Colors.white),
            if (!isLoading)
              FloatingButton(
                icon: Icons.check,
                onPress: () async {
                  if (_textController.text.trim().isEmpty) {
                    DialogHelper.showSnackbarMessage(
                        SnackMsgType.error, 'type_a_story'.tr,
                        duration: 1);
                    return;
                  }
                  setState(() => isLoading = true);
                  // Upload the text story
                  await StoryApi.uploadTextStory(
                    text: _textController.text.trim(),
                    bgColor: backgroundColor,
                  );
                  setState(() => isLoading = false);
                },
              ),
            if (showEmojiKeyboard) ...{
              const Spacer(),
            }
          ],
        ),
      ),
    );
  }
}
