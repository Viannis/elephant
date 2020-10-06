import 'package:flutter/foundation.dart';
import './languagePreferences.dart';

class TamilLangProvider with ChangeNotifier{
  LanguagePreference languagePreference = LanguagePreference();
  bool _tamilLang = false;

  bool get tamilLang => _tamilLang;

  set tamilLang(bool value) {
    _tamilLang = value;
    languagePreference.setTamilLanguage(value);
    notifyListeners();
  }
}