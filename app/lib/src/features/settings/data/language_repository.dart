import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'device_language_repository.dart';

part 'language_repository.g.dart';

/// Where the chosen language is kept. The app uses
/// [DeviceLanguageRepository]; tests override [languageRepository] with an
/// in-memory one.
abstract class LanguageRepository {
  /// The chosen language, or null to follow the phone.
  Future<Locale?> loadLocale();

  Future<void> saveLocale(Locale? locale);
}

@Riverpod(keepAlive: true)
LanguageRepository languageRepository(Ref ref) =>
    DeviceLanguageRepository(SharedPreferencesAsync());
