import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/api/contact_api.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/components/floating_button.dart';
import 'package:chat_messenger/components/loading_indicator.dart';
import 'package:chat_messenger/components/no_data.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/helpers/routes_helper.dart';
import 'package:get/get.dart';

import 'components/contact_card.dart';
import 'controllers/contact_search_controller.dart';

class ContactSearchScreen extends StatelessWidget {
  const ContactSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContactSearchController());

    return Scaffold(
      appBar: CustomAppBar(
        title: Text("search_contact".tr),
      ),
      body: Column(
        children: [
          // Searh Contact
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: defaultPadding,
            ),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Form(
              key: controller.formKey,
              child: TextFormField(
                autofocus: true,
                onFieldSubmitted: (String value) => controller.searchContact(),
                textInputAction: TextInputAction.search,
                validator: AppHelper.usernameValidator,
                inputFormatters: AppHelper.usernameFormatter,
                controller: controller.usernameController,
                decoration: InputDecoration(
                  hintText: 'enter_username'.tr,
                  prefixIcon: const Icon(Icons.alternate_email),
                  suffixIcon: FloatingButton(
                    bgColor: secondaryColor,
                    icon: IconlyLight.search,
                    onPress: () => controller.searchContact(),
                  ),
                ),
              ),
            ),
          ),

          // Contact result
          Obx(() {
            // Check loading
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.only(top: 50),
                child: LoadingIndicator(size: 50),
              );
            } else if (controller.contact.value == null) {
              return Padding(
                padding: const EdgeInsets.only(top: 50),
                child: NoData(
                  iconData: IconlyLight.search,
                  text: 'search'.tr,
                ),
              );
            }
            // Get contact
            final User user = controller.contact.value!;

            return ContactCard(
              user: user,
              onPress: () {
                // Closes keyboard
                FocusScope.of(context).unfocus();

                // Add contact to list
                ContactApi.addContact(userId: user.userId);

                // Go to messages page
                RoutesHelper.toMessages(user: user).then((_) {
                  Get.back(); // Closes contacts page
                  Get.back(); // Closes search contacts page
                });
              },
            );
          }),
        ],
      ),
    );
  }
}
