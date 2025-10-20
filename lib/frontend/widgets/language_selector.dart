import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (String languageCode) {
        localeProvider.changeLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) {
        return LocaleProvider.supportedLocales.map((Locale locale) {
          final isSelected = locale == localeProvider.locale;
          return PopupMenuItem<String>(
            value: locale.languageCode,
            child: Row(
              children: [
                if (isSelected)
                  const Icon(Icons.check, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                Text(LocaleProvider.getLanguageName(locale.languageCode)),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}