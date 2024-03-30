import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';

final pickerTheme = ThemeData.dark().copyWith(
  primaryColor: primaryColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
  ),
  colorScheme: const ColorScheme.dark().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
    error: errorColor,
  ),
);
