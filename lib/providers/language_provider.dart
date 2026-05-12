import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/l10n/app_localizations.dart';

/// GetX controller that mirrors the React LanguageContext.
/// Default language is Malayalam ('ml') as set in the web app.
class LanguageProvider extends GetxController {
  static LanguageProvider get to => Get.find();

  final _language = 'ml'.obs;

  String get language => _language.value;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('language') ?? 'ml';
    _language.value = saved;
    final locale =
        saved == 'ml' ? const Locale('ml', 'IN') : const Locale('en', 'US');
    Get.updateLocale(locale);
  }

  Future<void> setLanguage(String lang) async {
    _language.value = lang;
    final locale =
        lang == 'ml' ? const Locale('ml', 'IN') : const Locale('en', 'US');
    Get.updateLocale(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }

  void toggleLanguage() {
    setLanguage(_language.value == 'en' ? 'ml' : 'en');
  }

  /// Translate a key using GetX `AppTranslations` first, then fall back to
  /// legacy local map for any keys that are not migrated yet.
  String t(String key) {
    // Ensure Obx/GetX widgets using `lang.t(...)` always subscribe to language
    // changes via this Rx value.
    final currentLanguage = _language.value;
    final translated = key.tr;
    if (translated != key) return translated;
    return AppLocalizations.translate(currentLanguage, key);
  }

  bool get isEnglish => _language.value == 'en';
  bool get isMalayalam => _language.value == 'ml';
}
