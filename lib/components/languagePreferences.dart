import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreference {
  static const LANG_STATUS = "LANGSTATUS";

  setTamilLanguage(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(LANG_STATUS, value);
  }

  Future<bool> getLang() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(LANG_STATUS) ?? false;
  }
}