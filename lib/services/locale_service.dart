import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  static const _prefKey = 'app_locale';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isRtl => _locale.languageCode == 'ur';

  /// Urdu glyphs render larger at the same font size; scale down UI text slightly.
  static const double urduTextScaleFactor = 0.86;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code == 'ur') {
      _locale = const Locale('ur');
    } else {
      _locale = const Locale('en');
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }
}
