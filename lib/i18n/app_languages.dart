import 'package:get/get.dart';

import 'lang/en.dart';

class AppLanguages extends Translations {

  @override
  // App supported languages
  Map<String, Map<String, String>> get keys {
    return {
      "en": english,
    };
  }
}
