import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/components/default_button.dart';
import 'package:chat_messenger/components/svg_icon.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:get/get.dart';

import '../components/contact_list.dart';
import '../controllers/create_group_controller.dart';

class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key, required this.isBroadcast});

  final bool isBroadcast;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateGroupController());

    const contentPadding = EdgeInsets.symmetric(horizontal: defaultPadding);
    final String name = isBroadcast ? 'broadcast_name'.tr : 'group_name'.tr;
    const Widget broadcastIcon = SvgIcon('assets/icons/broadcast.svg',
        width: 65, height: 65, color: Colors.white);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(isBroadcast ? 'new_broadcast'.tr : 'new_group'.tr),
        height: 56,
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // <--- Group photo --->
              Center(
                child: GestureDetector(
                  onTap: () async {
                    // Pick image from camera/gallery
                    final File? resultFile =
                        await DialogHelper.showPickImageDialog(
                      isAvatar: true,
                    );
                    // Update file
                    controller.photoFile.value = resultFile;
                  },
                  child: Obx(() {
                    // Get file
                    final File? photoFile = controller.photoFile.value;

                    return Container(
                      child: photoFile != null
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(File(photoFile.path)),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: primaryColor,
                              child: isBroadcast
                                  ? broadcastIcon
                                  : const Icon(IconlyLight.camera, size: 65),
                            ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: Text("photo".tr,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: greyColor)),
              ),
              const SizedBox(height: 20),

              // <-- Group name -->
              Padding(
                padding: contentPadding,
                child: TextFormField(
                  autofocus: true,
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: name,
                    hintText: name,
                    prefixIcon: const Icon(IconlyLight.user2),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return name;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: contentPadding,
                child: Obx(
                  () => Text(
                    controller.members.isNotEmpty
                        ? "${'selected'.tr}: ${controller.members.length}"
                        : isBroadcast
                            ? "add_recipients".tr
                            : "add_participants".tr,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 0),
              // Show Contacts List
              const Expanded(child: ContactList()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => Padding(
          padding: const EdgeInsets.fromLTRB(16, 3, 16, 16),
          child: DefaultButton(
            height: 45,
            isLoading: controller.isLoading.value,
            width: double.maxFinite,
            text: isBroadcast
                ? 'create_broadcast'.tr.toUpperCase()
                : 'create_group'.tr.toUpperCase(),
            onPress: controller.members.isEmpty
                ? null
                : () => controller.createGroup(isBroadcast),
          ),
        ),
      ),
    );
  }
}
