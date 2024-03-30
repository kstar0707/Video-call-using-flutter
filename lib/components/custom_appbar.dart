import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.leading,
    this.hideLeading = false,
    this.height = 60,
    this.title,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.onBackPress,
  });

  final Widget? leading;
  final double height;
  final Widget? title;
  final bool centerTitle, hideLeading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Function()? onBackPress;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      leading: hideLeading
          ? null
          : leading ??
              IconButton(
                onPressed: onBackPress ?? () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_sharp,
                    color: Colors.white),
              ),
      titleSpacing: 0,
      title: title,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
