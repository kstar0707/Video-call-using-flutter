import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_messenger/config/theme_config.dart';

class AppTheme {
  final BuildContext context;

  // Constructor
  AppTheme(this.context);

  /// Get context using "of" syntax
  static AppTheme of(BuildContext context) => AppTheme(context);

  /// Get current theme mode => [dark or light]
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

// <--- Build light theme --->
  ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightThemeBgColor,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: getSystemOverlayStyle(false),
        backgroundColor: primaryColor,
        actionsIconTheme: IconThemeData(
          color: lightThemeTextColor.withOpacity(0.50),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconTheme: const IconThemeData(color: lightThemeTextColor, size: 28),
      textTheme: GoogleFonts.interTextTheme(customTextTheme).apply(
        bodyColor: lightThemeTextColor,
        displayColor: lightThemeTextColor,
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightThemeBgColor,
        selectedItemColor: primaryColor,
        selectedIconTheme: const IconThemeData(color: primaryColor, size: 28),
        unselectedItemColor: lightThemeTextColor.withOpacity(0.5),
        showUnselectedLabels: true,
      ),
      inputDecorationTheme: inputDecorationTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      dividerTheme: dividerThemeData,
    );
  }

  // <--- Build dark theme --->
  ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkThemeBgColor,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: darkPrimaryContainer,
        systemOverlayStyle: getSystemOverlayStyle(true),
        actionsIconTheme: const IconThemeData(color: darkThemeTextColor),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconTheme: const IconThemeData(color: darkThemeTextColor, size: 28),
      textTheme: GoogleFonts.interTextTheme(customTextTheme).apply(
        bodyColor: darkThemeTextColor,
        displayColor: darkThemeTextColor,
      ),
      colorScheme: const ColorScheme.dark().copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        primaryContainer: darkPrimaryContainer,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: darkThemeBgColor,
        selectedItemColor: Colors.white70,
        unselectedItemColor: darkThemeTextColor.withOpacity(0.32),
        unselectedIconTheme: const IconThemeData(size: 28),
        selectedIconTheme: const IconThemeData(color: primaryColor, size: 28),
        showUnselectedLabels: true,
      ),
      inputDecorationTheme: inputDecorationTheme.copyWith(
        fillColor: primaryColor.withOpacity(0.50),
      ),
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      dividerTheme: dividerThemeData,
    );
  }

  // Get text color
  Color? get textColor => isDarkMode ? Colors.white : null;

  // Build Custom TextTheme
  TextTheme get customTextTheme => TextTheme(
        headlineSmall: TextStyle(
            fontSize: 24.0, fontWeight: FontWeight.bold, color: textColor),
        titleLarge: TextStyle(
            fontSize: 18.0, fontWeight: FontWeight.bold, color: textColor),
        titleMedium: TextStyle(
            fontSize: 16.0, fontWeight: FontWeight.w600, color: textColor),
        bodyLarge: TextStyle(fontSize: 16.0, color: textColor),
        bodyMedium: TextStyle(fontSize: 14.0, color: textColor),
        bodySmall: TextStyle(fontSize: 12.0, color: textColor),
      );

  final inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: greyLight,
    focusColor: primaryColor,
    hintStyle: const TextStyle(color: Colors.grey),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: defaultPadding,
      vertical: defaultPadding,
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(defaultRadius),
    ),
  );

  final elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
    ),
  );

  final outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(width: 1.5, color: primaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius * 2),
      ),
    ),
  );

  final dividerThemeData = const DividerThemeData(
    thickness: 0.0,
    color: Color(0xFFCCCCCC),
  );
}
