import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!supportedLocales.contains(locale)) return;

    _locale = locale;
    notifyListeners();
  }

  void changeLanguage(String languageCode) {
    final newLocale = Locale(languageCode);
    setLocale(newLocale);
  }

  // Поддерживаемые языки
  static const List<Locale> supportedLocales = [
    Locale('en'), // Английский
    Locale('et'), // Эстонский
    Locale('ru'), // Русский
  ];

  // Получить название языка
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'et':
        return 'Eesti';
      case 'ru':
        return 'Русский';
      default:
        return 'English';
    }
  }
}