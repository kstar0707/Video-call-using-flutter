import 'dart:io';

import 'package:chat_messenger/components/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/api/auth_api.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:chat_messenger/config/theme_config.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    // Vars
    final bool isDarkMode = AppTheme.of(context).isDarkMode;

    return Column(
      children: [
        // Google
        SocialButton(
          bgColor: Colors.white,
          textColor: Colors.black,
          borderColor: isDarkMode ? Colors.white : Colors.black,
          svgPath: 'assets/icons/google_login.svg',
          text: 'continue_with_google'.tr,
          onPress: () => AuthApi.signInWithGoogle(),
        ),
        const SizedBox(height: 16),

        // Apple
        if (Platform.isIOS)
          SocialButton(
            bgColor: isDarkMode ? greyColor.withOpacity(0.5) : Colors.black,
            iconColor: Colors.white,
            svgPath: 'assets/icons/apple_login.svg',
            text: 'continue_with_apple'.tr,
            onPress: () => AuthApi.signInWithApple(),
          ),
      ],
    );
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.svgPath,
    required this.text,
    required this.onPress,
    this.bgColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
    this.elevation = 0,
  });

  final String svgPath, text;
  final Color? bgColor, borderColor, iconColor, textColor;
  final double elevation;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.maxFinite,
      child: ElevatedButton.icon(
        onPressed: onPress,
        icon: SizedBox(
          width: 24,
          height: 24,
          child: SvgIcon(svgPath, color: iconColor),
        ),
        label: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: textColor ?? Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          backgroundColor: bgColor,
          side: BorderSide(color: borderColor ?? Colors.transparent),
        ),
      ),
    );
  }
}
