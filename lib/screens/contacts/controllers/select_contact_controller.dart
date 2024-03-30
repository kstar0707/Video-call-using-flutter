import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/screens/contacts/controllers/contact_controller.dart';
import 'package:chat_messenger/tabs/groups/controllers/group_controller.dart';
import 'package:get/get.dart';

class SelectContactController extends GetxController {
  // Params
  final bool showGroups;

  SelectContactController({this.showGroups = false});

  // Other controllers
  final ContactController _contactController = Get.find();
  final GroupController _groupController = Get.find();
  // Vars
  final RxList<dynamic> contacts = RxList();
  final RxSet<dynamic> selectedContacts = RxSet();

  @override
  void onInit() {
    if (showGroups) {
      contacts.addAll(_groupController.groups);
    }
    contacts.addAll(_contactController.contacts);
    super.onInit();
  }

  void onSend() {
    if (selectedContacts.isEmpty) {
      DialogHelper.showSnackbarMessage(
          SnackMsgType.error, "select_contacts".tr);
      return;
    }
    Get.back(result: selectedContacts.toList());
  }

  bool isSelected(dynamic item) {
    return selectedContacts.contains(item);
  }

  void selectItem(dynamic item) {
    if (selectedContacts.contains(item)) {
      selectedContacts.remove(item);
    } else {
      selectedContacts.add(item);
    }
  }

  void onCheckBoxChanged(bool? value, dynamic item) {
    if (value != null) {
      if (value) {
        selectedContacts.add(item);
      } else {
        selectedContacts.remove(item);
      }
    }
  }
}
