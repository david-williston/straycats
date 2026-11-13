import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import 'language_repository.dart';

/// Keeps the chosen language in the phone's preferences.
class DeviceLanguageRepository implements LanguageRepository {
  DeviceLanguageRepository(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _key = 'language';

  @override
  Future<Locale?> loadLocale() async {
    final code = await _prefs.getString(_key);
    return code == null ? null : Locale(code);
  }

  @override
  Future<void> saveLocale(Locale? locale) => locale == null
      ? _prefs.remove(_key)
      : _prefs.setString(_key, locale.languageCode);
}
