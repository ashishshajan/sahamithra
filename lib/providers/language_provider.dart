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
  }

  Future<void> setLanguage(String lang) async {
    _language.value = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }

  void toggleLanguage() {
    setLanguage(_language.value == 'en' ? 'ml' : 'en');
  }

  /// Translate a key in the current language
  String t(String key) => AppLocalizations.translate(_language.value, key);

  bool get isEnglish => _language.value == 'en';
  bool get isMalayalam => _language.value == 'ml';
}
