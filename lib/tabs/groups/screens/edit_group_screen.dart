import 'package:flutter/material.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/components/default_button.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:get/get.dart';

import '../controllers/edit_group_controller.dart';

class EditGroupScreen extends StatelessWidget {
  const EditGroupScreen({
    super.key,
    required this.group,
  });

  final Group group;

  @override
  Widget build(BuildContext context) {
    // Init controller
    final EditGroupController controller = Get.put(EditGroupController(group));
    final bool isBroadcast = group.isBroadcast;
    final String name = isBroadcast ? 'broadcast_name'.tr : 'group_name'.tr;
    final String description =
        isBroadcast ? 'broadcast_description'.tr : 'group_description'.tr;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(isBroadcast ? 'edit_broadcast'.tr : 'edit_group'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding * 2,
        ),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group name
              TextFormField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: name,
                  hintText: name,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.group_add, color: Colors.grey),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return name;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Group description
              TextFormField(
                maxLines: 2,
                controller: controller.descriptionController,
                decoration: InputDecoration(
                  labelText: description,
                  hintText: description,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.info_outline, color: Colors.grey),
                  ),
                ),
              ),

              // <-- Group Options -->
              if (!isBroadcast)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Group permissions
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
                      child: Text(
                        "group_permissions".tr,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: greyColor),
                      ),
                    ),

                    // Select options
                    Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            checkboxShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            title: Text('only_admins_can_send_messages'.tr),
                            value: !controller.sendMessages.value,
                            onChanged: (bool? value) {
                              if (value == null) return;
                              controller.sendMessages.value = !value;
                            },
                          ),
                          CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            title: Text(
                                'both_admins_and_participants_can_send_messages'
                                    .tr),
                            value: controller.sendMessages.value,
                            onChanged: (bool? value) {
                              if (value == null) return;
                              controller.sendMessages.value = value;
                            },
                          ),
                        ],
                      );
                    }),
                  ],
                ),

              const SizedBox(height: 50),

              // Save changes
              DefaultButton(
                width: double.maxFinite,
                height: 45,
                text: 'save_changes'.tr,
                onPress: () => controller.updateGroupDetails(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
