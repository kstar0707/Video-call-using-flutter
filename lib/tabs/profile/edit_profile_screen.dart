import 'dart:io';

import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/components/default_button.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/config/theme_config.dart';

import 'controllers/edit_profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EditProfileController controller = Get.put(EditProfileController());
    final User currentUser = AuthController.instance.currentUser;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('edit_profile'.tr),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // <--- Profile photo --->
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

                      return Stack(
                        children: [
                          // Photo
                          Container(
                            child: photoFile != null
                                ? CircleAvatar(
                                    radius: 70,
                                    backgroundImage:
                                        FileImage(File(photoFile.path)),
                                  )
                                : CachedCircleAvatar(
                                    radius: 70,
                                    iconSize: 60,
                                    imageUrl: currentUser.photoUrl,
                                  ),
                          ),
                          // Icon
                          const Positioned(
                            right: 0,
                            bottom: 16,
                            child: CircleAvatar(
                              backgroundColor: primaryColor,
                              child: Icon(IconlyBold.camera,
                                  color: Colors.white, size: 23),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text("profile_photo".tr,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: greyColor)),
                ),
                const SizedBox(height: 30),

                // <-- Fullname -->
                Text("fullname".tr,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    hintText: 'enter_your_fullname'.tr,
                    prefixIcon: const Icon(IconlyLight.profile),
                  ),
                  validator: (String? name) {
                    if (name == null || name.trim().isEmpty) {
                      return 'enter_your_fullname'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // <-- Username -->
                GestureDetector(
                  onTap: () => controller.isExtended.toggle(),
                  child: Row(
                    children: [
                      Text("update_username_for_contact".tr,
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Obx(
                        () => Icon(controller.isExtended.value
                            ? IconlyLight.arrowUp2
                            : IconlyLight.arrowDown2),
                      )
                    ],
                  ),
                ),
                Obx(() {
                  if (!controller.isExtended.value) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: defaultPadding / 2),
                    child: Text(
                      "username_usage".tr,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: greyColor),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Username field
                TextFormField(
                  textInputAction: TextInputAction.search,
                  controller: controller.usernameController,
                  validator: AppHelper.usernameValidator,
                  inputFormatters: AppHelper.usernameFormatter,
                  decoration: InputDecoration(
                    hintText: 'enter_your_username'.tr,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.alternate_email, color: Colors.grey),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: DefaultButton(
                        height: 35,
                        text: 'check'.tr,
                        onPress: () {
                          final String username =
                              controller.usernameController.text.trim();
                          // Check input
                          if (username.isEmpty) {
                            DialogHelper.showSnackbarMessage(
                                SnackMsgType.error, "enter_your_username".tr);
                            return;
                          }
                          // Check username in database
                          UserApi.checkUsername(username: username);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Bio
                Text("bio".tr, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  maxLines: 2,
                  controller: controller.bioController,
                  decoration: InputDecoration(
                    hintText: 'about_you'.tr,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.info_outline, color: Colors.grey),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'about_you'.tr;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding * 2,
          ),
          child: DefaultButton(
            height: 45,
            isLoading: controller.isLoading.value,
            width: double.maxFinite,
            text: 'update_account'.tr.toUpperCase(),
            onPress: () => controller.updateAccount(),
          ),
        ),
      ),
    );
  }
}
