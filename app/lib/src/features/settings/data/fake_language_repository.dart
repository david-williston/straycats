import 'dart:ui';

import 'language_repository.dart';

/// Keeps the language in memory, for tests.
class FakeLanguageRepository implements LanguageRepository {
  FakeLanguageRepository([this.locale]);

  Locale? locale;

  @override
  Future<Locale?> loadLocale() async => locale;

  @override
  Future<void> saveLocale(Locale? locale) async => this.locale = locale;
}
