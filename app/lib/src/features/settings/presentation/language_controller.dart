import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/language_repository.dart';

part 'language_controller.g.dart';

/// The language the user chose, or null to follow the phone.
@Riverpod(keepAlive: true)
class LanguageController extends _$LanguageController {
  @override
  Future<Locale?> build() => ref.watch(languageRepositoryProvider).loadLocale();

  /// Switches the app's language at once, then remembers it.
  Future<void> choose(Locale? locale) async {
    state = AsyncData(locale);
    await ref.read(languageRepositoryProvider).saveLocale(locale);
  }
}
