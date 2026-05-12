import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Controls app language (English ↔ Malayalam).
/// Default: Malayalam (ml_IN) — matching the React app default.
class LanguageController extends GetxController {
  final _box = GetStorage();
  static const _key = 'language';

  final Rx<Locale> locale = const Locale('ml', 'IN').obs;

  @override
  void onInit() {
    super.onInit();
    final saved = _box.read<String>(_key);
    if (saved != null) {
      final parts = saved.split('_');
      locale.value = Locale(parts[0], parts.length > 1 ? parts[1] : null);
    }
  }

  bool get isMalayalam => locale.value.languageCode == 'ml';
  bool get isEnglish    => locale.value.languageCode == 'en';

  String get languageLabel => isMalayalam ? 'മ' : 'EN';

  void switchToEnglish() {
    locale.value = const Locale('en', 'US');
    Get.updateLocale(locale.value);
    _box.write(_key, 'en_US');
  }

  void switchToMalayalam() {
    locale.value = const Locale('ml', 'IN');
    Get.updateLocale(locale.value);
    _box.write(_key, 'ml_IN');
  }

  void toggle() {
    if (isMalayalam) {
      switchToEnglish();
    } else {
      switchToMalayalam();
    }
  }
}
