import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends GetxService {
  static LocalizationService get to => Get.find();

  static const String _localeKey = 'selected_locale';

  // Default locale
  static const Locale defaultLocale = Locale('en', 'US');

  // Supported locales
  static final List<Locale> supportedLocales = [
    const Locale('en', 'US'),
    const Locale('ne', 'NP'),
  ];

  Locale _currentLocale = defaultLocale;

  Locale get currentLocale => _currentLocale;

  Future<LocalizationService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);

    if (localeCode != null) {
      final parts = localeCode.split('_');
      if (parts.length == 2) {
        _currentLocale = Locale(parts[0], parts[1]);
      }
    } else {
      // If no saved locale, try to use device locale if supported
      final deviceLocale = Get.deviceLocale;
      if (deviceLocale != null && _isSupported(deviceLocale)) {
        _currentLocale = deviceLocale;
      }
    }
    return this;
  }

  bool _isSupported(Locale locale) {
    return supportedLocales.any((supported) =>
        supported.languageCode == locale.languageCode &&
        supported.countryCode == locale.countryCode);
  }

  void changeLocale(Locale locale) async {
    if (!_isSupported(locale)) return;

    _currentLocale = locale;
    Get.updateLocale(locale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, '${locale.languageCode}_${locale.countryCode}');
  }

  String getCurrentLanguageName() {
    if (_currentLocale.languageCode == 'ne') {
      return 'नेपाली';
    }
    return 'English';
  }
}
