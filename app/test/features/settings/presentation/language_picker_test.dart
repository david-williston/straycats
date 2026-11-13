import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/settings/data/fake_language_repository.dart';

import '../../../helpers.dart';

void main() {
  testWidgets('switches to Spanish and back to the phone language', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final language = FakeLanguageRepository();
    await pumpApp(tester, cats: FakeCatRepository(), language: language);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Meet a cat'), findsOneWidget);

    await tester.tap(find.byTooltip('Language'));
    await tester.pumpAndSettle();
    expect(find.text("Phone's language"), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Conocer a un gato'), findsOneWidget);
    expect(language.locale, const Locale('es'));

    await tester.tap(find.byTooltip('Idioma'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Idioma del teléfono'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Meet a cat'), findsOneWidget);
    expect(language.locale, isNull);
  });
}
