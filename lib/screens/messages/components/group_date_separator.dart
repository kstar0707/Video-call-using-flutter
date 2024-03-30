import 'package:flutter/material.dart';
import 'package:chat_messenger/theme/app_theme.dart';

class GroupDateSeparator extends StatelessWidget {
  const GroupDateSeparator(this.formattedDate, {super.key});

  // Params
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(top: 20, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            formattedDate,
            style: TextStyle(color: isDarkMode ? Colors.black : null),
          ),
        ),
      ],
    );
  }
}
