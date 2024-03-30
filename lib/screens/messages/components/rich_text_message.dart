import 'package:chat_messenger/config/theme_config.dart';
import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';

class RichTexMessage extends StatelessWidget {
  const RichTexMessage({
    super.key,
    required this.text,
    this.defaultStyle,
    this.maxLines,
  });

  final String text;
  final TextStyle? defaultStyle;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return EasyRichText(
      text,
      maxLines: maxLines,
      overflow: defaultStyle?.overflow ?? TextOverflow.clip,
      defaultStyle: defaultStyle ?? DefaultTextStyle.of(context).style,
      patternList: [
        EasyRichTextPattern(
          targetString: EasyRegexPattern.emailPattern,
          urlType: 'email',
          style: const TextStyle(
            color: secondaryColor,
            decoration: TextDecoration.underline,
          ),
        ),
        EasyRichTextPattern(
          targetString:
              r'\b(?:(?:(?:https?|ftp):\/\/)|(?:www\.))(?:(?![@\s])[\w-]+(?:\.[\w-]+)+)(?:\/[^\s]*)?\b', //EasyRegexPattern.webPattern,
          urlType: 'web',
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
        EasyRichTextPattern(
          targetString: EasyRegexPattern.telPattern,
          urlType: 'tel',
          style: const TextStyle(
            color: secondaryColor,
            decoration: TextDecoration.underline,
          ),
        ),
        // Bold font
        EasyRichTextPattern(
          targetString: '(\\*)(.*?)(\\*)',
          matchBuilder: (_, match) {
            return TextSpan(
              text: match?[0]?.replaceAll('*', ''),
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),

        // Italic font
        EasyRichTextPattern(
          targetString: '(_)(.*?)(_)',
          matchBuilder: (_, match) {
            return TextSpan(
              text: match?[0]?.replaceAll('_', ''),
              style: const TextStyle(fontStyle: FontStyle.italic),
            );
          },
        ),

        // Strikethrough
        EasyRichTextPattern(
          targetString: '(~)(.*?)(~)',
          matchBuilder: (_, match) {
            return TextSpan(
              text: match?[0]?.replaceAll('~', ''),
              style: const TextStyle(decoration: TextDecoration.lineThrough),
            );
          },
        ),
      ],
    );
  }
}
