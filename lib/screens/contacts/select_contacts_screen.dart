import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/components/no_data.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:get/get.dart';

import 'controllers/select_contact_controller.dart';

class SelectContactsScreen extends StatelessWidget {
  const SelectContactsScreen({
    super.key,
    required this.title,
    this.showGroups = false,
  });

  final String title;
  final bool showGroups;

  @override
  Widget build(BuildContext context) {
    final SelectContactController controller =
        Get.put(SelectContactController(showGroups: showGroups));

    return Scaffold(
      appBar: CustomAppBar(
        title: Obx(() {
          return Text(controller.selectedContacts.isNotEmpty
              ? "${'selected'.tr}: ${controller.selectedContacts.length}"
              : title);
        }),
      ),
      body: Obx(() {
        // Check loading
        if (controller.contacts.isEmpty) {
          return const NoData(iconData: IconlyBold.search, text: '');
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemCount: controller.contacts.length,
          itemBuilder: (context, index) {
            final dynamic item = controller.contacts[index];
            User? user;
            Group? group;
            // Check item type
            if (item is User) {
              user = item;
            } else {
              group = item;
            }

            return Obx(
              () => ListTile(
                leading: CachedCircleAvatar(
                  imageUrl: item is User ? user!.photoUrl : group!.photoUrl,
                  radius: 28,
                ),
                title: Text(item is User ? user!.fullname : group!.name),
                subtitle: item is User
                    ? Text('@${user!.username}')
                    : Text('${group!.participants.length} ${group.isBroadcast ? 'recipients'.tr : 'participants'.tr}'),
                tileColor: controller.isSelected(item)
                    ? primaryColor.withOpacity(0.10)
                    : null,
                trailing: CupertinoCheckbox(
                  value: controller.isSelected(item),
                  onChanged: (bool? value) =>
                      controller.onCheckBoxChanged(value, item),
                ),
                onTap: () => controller.selectItem(item),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        child:
            const Icon(IconlyLight.arrowRight, color: Colors.white, size: 32),
        onPressed: () => controller.onSend(),
      ),
    );
  }
}
