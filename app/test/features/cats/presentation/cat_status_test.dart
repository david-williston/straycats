import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/cat_status.dart';
import 'package:straycats/src/features/cats/presentation/cat_card.dart';
import 'package:straycats/src/features/cats/presentation/cat_tile.dart';
import 'package:straycats/src/localization/app_localizations.dart';

import '../../../helpers.dart';

final _since = DateTime(2026, 11, 10);

Cat _missing([String name = 'Ninja']) =>
    cat('1', name, [1000]).withStatus(CatStatus.missing, since: _since);

void main() {
  group('domain', () {
    test('a status survives a round trip through JSON', () {
      final c = cat('1', 'Saibo', [1000]).withStatus(
        CatStatus.remembered,
        since: _since,
        note: 'Sunny in the window',
      );
      final back = Cat.fromJson(c.toJson());
      expect(back, c);
      expect(back.status, CatStatus.remembered);
      expect(back.statusSince, _since);
      expect(back.statusNote, 'Sunny in the window');
    });

    test('a known cat has no status in its JSON', () {
      final json = cat('1', 'Saibo', [1000]).toJson();
      expect(json.containsKey('status'), isFalse);
      expect(Cat.fromJson(json).status, CatStatus.known);
    });

    test('back to normal clears the date and the note', () {
      final c = _missing().withStatus(
        CatStatus.known,
        since: _since,
        note: 'x',
      );
      expect(c.status, CatStatus.known);
      expect(c.statusSince, isNull);
      expect(c.statusNote, '');
    });

    test('a status keeps the encounters and the name', () {
      final c = cat('1', 'Ninja', [1000, 2000]);
      final m = c.withStatus(CatStatus.missing, since: _since);
      expect(m.encounters, c.encounters);
      expect(m.name, 'Ninja');
      expect(m == c, isFalse);
      expect(m.copyWith(name: 'Ciccio').status, CatStatus.missing);
    });

    test('the first meeting is the earliest encounter', () {
      expect(
        cat('1', '', [3000, 1000, 2000]).firstMet,
        DateTime.fromMillisecondsSinceEpoch(1000),
      );
      expect(cat('1', '', []).firstMet, isNull);
    });

    test('missing cats sort first and remembered ones last', () {
      final cats = [
        cat('seen-lately', '', [9000]),
        cat('remembered', '', [
          8000,
        ]).withStatus(CatStatus.remembered, since: _since),
        cat('found', '', [5000]).withStatus(CatStatus.found, since: _since),
        cat('missing-old', '', [
          1000,
        ]).withStatus(CatStatus.missing, since: _since),
        cat('missing-new', '', [
          2000,
        ]).withStatus(CatStatus.missing, since: _since),
        cat('plain', '', [7000]),
      ];
      expect(byLastSeen(cats).map((c) => c.id), [
        'missing-new',
        'missing-old',
        'seen-lately',
        'plain',
        'found',
        'remembered',
      ]);
    });
  });

  group('home grid', () {
    testWidgets('badges show on the tiles, missing first and remembered last', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        cat('r', 'Saibo', [
          9000,
        ]).withStatus(CatStatus.remembered, since: _since),
        cat('a', 'Ciccio', [5000]),
        cat('f', 'Luna', [4000]).withStatus(CatStatus.found, since: _since),
        cat('m', 'Ninja', [1000]).withStatus(CatStatus.missing, since: _since),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();

      expect(find.text('Missing since Nov 10, 2026'), findsOneWidget);
      expect(find.text('Found Nov 10, 2026'), findsOneWidget);
      expect(find.text('Remembered'), findsOneWidget);
      final order = tester
          .widgetList<CatTile>(find.byType(CatTile))
          .map((t) => t.cat.name);
      expect(order, ['Ninja', 'Ciccio', 'Luna', 'Saibo']);
    });

    testWidgets('the badges read in Spanish', (tester) async {
      final repo = FakeCatRepository([
        cat('r', 'Saibo', [
          9000,
        ]).withStatus(CatStatus.remembered, since: _since),
        cat('m', 'Ninja', [1000]).withStatus(CatStatus.missing, since: _since),
      ]);
      await pumpApp(tester, cats: repo, locale: const Locale('es'));
      await tester.pump();

      expect(find.textContaining('Desaparecido desde el'), findsOneWidget);
      expect(find.text('Recordado'), findsOneWidget);
    });

    testWidgets('a known cat has no badge', (tester) async {
      await pumpApp(
        tester,
        cats: FakeCatRepository([
          cat('1', 'Ciccio', [1000]),
        ]),
      );
      await tester.pump();
      expect(find.textContaining('Missing'), findsNothing);
      expect(find.text('Remembered'), findsNothing);
    });
  });

  group('cat card', () {
    Future<void> openCard(WidgetTester tester, String name) async {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }

    Future<void> chooseStatus(WidgetTester tester, String label) async {
      await tester.tap(find.text('Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    testWidgets('marks a cat as missing, with a note, since today', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await chooseStatus(tester, 'Mark as missing');
      await tester.enterText(
        find.byType(TextField).last,
        '  near the market on Tuesday ',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final (id, status, since, note) = repo.statusChanges.single;
      expect(id, '1');
      expect(status, CatStatus.missing);
      final now = DateTime.now();
      expect(since, DateTime(now.year, now.month, now.day));
      expect(note.trim(), 'near the market on Tuesday');
      expect(repo.cats.single.status, CatStatus.missing);
      expect(find.textContaining('Missing since'), findsWidgets);
      expect(find.text('near the market on Tuesday'), findsOneWidget);
    });

    testWidgets('cancelling the dialog changes nothing', (tester) async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await chooseStatus(tester, 'Mark as missing');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repo.statusChanges, isEmpty);
    });

    testWidgets('a missing cat can be found, with a celebration', (
      tester,
    ) async {
      final repo = FakeCatRepository([_missing()]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await chooseStatus(tester, 'Found!');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Ninja is found. Welcome home!'), findsOneWidget);
      expect(repo.cats.single.status, CatStatus.found);
      await tester.tap(find.text('Wonderful'));
      await tester.pumpAndSettle();
      expect(find.text('Ninja is found. Welcome home!'), findsNothing);
      expect(find.textContaining('Found '), findsWidgets);
    });

    testWidgets('the celebration is still, and readable, with reduced motion', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final repo = FakeCatRepository([_missing('')]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await tester.tap(find.text('No name yet'));
      await tester.pumpAndSettle();

      await chooseStatus(tester, 'Found!');
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump();

      expect(find.text('This cat is found. Welcome home!'), findsOneWidget);
    });

    testWidgets('remembering a cat shows its dates and keeps the record open', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        Cat(
          id: '1',
          name: 'Saibo',
          encounters: cat('1', '', [
            DateTime(2025, 3, 2).millisecondsSinceEpoch,
          ]).encounters,
        ),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Saibo');

      await chooseStatus(tester, 'Remember this cat');
      await tester.enterText(
        find.byType(TextField).last,
        'Sunny in the window',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.cats.single.status, CatStatus.remembered);
      expect(repo.cats.single.statusNote, 'Sunny in the window');
      expect(find.text('Remembered'), findsOneWidget);
      expect(find.textContaining('Mar 2, 2025 – '), findsOneWidget);
      expect(find.text('Sunny in the window'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
    });

    testWidgets('back to normal asks first, then clears the status', (
      tester,
    ) async {
      final repo = FakeCatRepository([_missing()]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await chooseStatus(tester, 'Back to normal');
      expect(repo.statusChanges, isEmpty);
      await tester.tap(find.widgetWithText(FilledButton, 'Back to normal'));
      await tester.pumpAndSettle();

      expect(repo.statusChanges.single.$2, CatStatus.known);
      expect(repo.cats.single.status, CatStatus.known);
      expect(find.textContaining('Missing since'), findsNothing);
    });

    testWidgets('the card speaks Spanish', (tester) async {
      final repo = FakeCatRepository([_missing()]);
      await pumpApp(tester, cats: repo, locale: const Locale('es'));
      await tester.pump();
      await openCard(tester, 'Ninja');

      await tester.tap(find.text('Estado'));
      await tester.pumpAndSettle();
      expect(find.text('¡Apareció!'), findsOneWidget);
      expect(find.text('Recordar a este gato'), findsOneWidget);
      expect(find.text('Volver a la normalidad'), findsOneWidget);
      await tester.tap(find.text('Recordar a este gato'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Lo sentimos mucho'), findsOneWidget);
    });

    testWidgets('a rename keeps nothing but the name changed', (tester) async {
      final repo = FakeCatRepository([_missing('')]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await tester.tap(find.text('No name yet'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Ninja');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(repo.cats.single.name, 'Ninja');
      expect(repo.cats.single.status, CatStatus.missing);
    });
  });

  group('admin view', () {
    Future<void> pumpCard(WidgetTester tester, Cat c, Locale locale) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: fakeOverrides(),
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CatCard(cat: c, ownerUid: 'someone-else'),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows the badge and its note, with no actions', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _missing().withStatus(
          CatStatus.missing,
          since: _since,
          note: 'near the market',
        ),
        const Locale('en'),
      );

      expect(find.text('Missing since Nov 10, 2026'), findsOneWidget);
      expect(find.text('near the market'), findsOneWidget);
      expect(find.text('Status'), findsNothing);
      expect(find.byIcon(Icons.flag_outlined), findsNothing);
    });

    testWidgets('a known cat shows no status area at all', (tester) async {
      await pumpCard(tester, cat('1', 'Ninja', [1000]), const Locale('es'));

      expect(find.text('Estado'), findsNothing);
    });
  });
}
