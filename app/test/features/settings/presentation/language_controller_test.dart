import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/settings/data/fake_language_repository.dart';
import 'package:straycats/src/features/settings/presentation/language_controller.dart';

import '../../../helpers.dart';

void main() {
  test('follows the phone by default', () async {
    final container = makeContainer();
    expect(await container.read(languageControllerProvider.future), isNull);
  });

  test('applies and saves the choice', () async {
    final repo = FakeLanguageRepository();
    final container = makeContainer(language: repo);
    await container.read(languageControllerProvider.future);

    await container
        .read(languageControllerProvider.notifier)
        .choose(const Locale('es'));

    expect(
      container.read(languageControllerProvider).value,
      const Locale('es'),
    );
    expect(repo.locale, const Locale('es'));
  });

  test('restores a saved choice', () async {
    final container = makeContainer(
      language: FakeLanguageRepository(const Locale('es')),
    );
    expect(
      await container.read(languageControllerProvider.future),
      const Locale('es'),
    );
  });

  test('choosing the phone clears the saved choice', () async {
    final repo = FakeLanguageRepository(const Locale('es'));
    final container = makeContainer(language: repo);
    await container.read(languageControllerProvider.future);

    await container.read(languageControllerProvider.notifier).choose(null);

    expect(container.read(languageControllerProvider).value, isNull);
    expect(repo.locale, isNull);
  });
}
