import 'package:flutter/material.dart';
import 'package:chat_messenger/components/svg_icon.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/helpers/routes_helper.dart';
import 'package:get/get.dart';

class CreateGroupModal extends StatelessWidget {
  const CreateGroupModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(defaultRadius),
          topRight: Radius.circular(defaultRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: greyColor),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const Divider(height: 0),
          ListTile(
            onTap: () {
              Get.back();
              RoutesHelper.toNewGroup(false);
            },
            leading: const CircleAvatar(
              backgroundColor: primaryColor,
              child: Icon(Icons.group_add, color: Colors.white, size: 22),
            ),
            title: Text('new_group'.tr),
          ),
          const Divider(height: 16),
          ListTile(
            onTap: () {
              Get.back();
              RoutesHelper.toNewGroup(true);
            },
            leading: const CircleAvatar(
              backgroundColor: primaryColor,
              child: SvgIcon(
                'assets/icons/broadcast.svg',
                width: 22,
                height: 22,
                color: Colors.white,
              ),
            ),
            title: Text('new_broadcast'.tr),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
