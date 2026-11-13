import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/data/offer_repository.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/encounter.dart';
import 'package:straycats/src/features/cats/domain/encounter_details.dart';
import 'package:straycats/src/features/cats/domain/life_event.dart';
import 'package:straycats/src/features/cats/domain/partial_date.dart';
import 'package:straycats/src/features/cats/presentation/cat_card.dart';
import 'package:straycats/src/features/cats/presentation/cat_tile.dart';
import 'package:straycats/src/features/cats/presentation/cats_controller.dart';
import 'package:straycats/src/features/cats/presentation/life_badge.dart';
import 'package:straycats/src/localization/app_localizations.dart';

import '../../../helpers.dart';

final _today = DateTime.now();
final _todayDate = PartialDate.day(_today.year, _today.month, _today.day);
final _recent = DateTime(_today.year, _today.month, _today.day);

LifeEvent ev(
  LifeEventType type,
  PartialDate on, {
  String id = '',
  String note = '',
}) => LifeEvent(
  id: id.isEmpty ? '${type.name}-${on.stored}' : id,
  type: type,
  on: on,
  note: note,
  createdAt: DateTime.fromMillisecondsSinceEpoch(1),
);

/// A cat met once, on 2 March 2025 (a local date, so no time zone shifts it).
final _met = DateTime(2025, 3, 2).millisecondsSinceEpoch;

Cat withEvents(String name, List<LifeEvent> events, [List<int>? times]) =>
    cat('1', name, times ?? [_met]).copyWith(events: events);

void main() {
  Future<void> openCard(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  Future<void> chooseToAdd(WidgetTester tester, String label) async {
    await tester.tap(find.text('Add to story'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  group('home grid', () {
    testWidgets('badges are derived, missing first and remembered last', (
      tester,
    ) async {
      final foundOn = PartialDate.day(_recent.year, _recent.month, _recent.day);
      final repo = FakeCatRepository([
        cat('r', 'Saibo', [9000]).copyWith(
          events: [ev(LifeEventType.died, const PartialDate.day(2026, 9, 16))],
        ),
        cat('a', 'Ciccio', [5000]),
        cat('f', 'Luna', [
          4000,
        ]).copyWith(events: [ev(LifeEventType.found, foundOn)]),
        cat('m', 'Ninja', [1000]).copyWith(
          events: [
            ev(LifeEventType.missing, const PartialDate.day(2026, 11, 3)),
          ],
        ),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();

      expect(find.text('Missing since Nov 3, 2026'), findsOneWidget);
      expect(find.textContaining('Found '), findsOneWidget);
      expect(find.text('Remembered'), findsOneWidget);
      final order = tester
          .widgetList<CatTile>(find.byType(CatTile))
          .map((t) => t.cat.name);
      expect(order, ['Ninja', 'Ciccio', 'Luna', 'Saibo']);
    });

    testWidgets('the badges read in Spanish', (tester) async {
      final repo = FakeCatRepository([
        cat('r', 'Saibo', [9000]).copyWith(
          events: [ev(LifeEventType.died, const PartialDate.day(2026, 9, 16))],
        ),
        cat('m', 'Ninja', [1000]).copyWith(
          events: [
            ev(LifeEventType.missing, const PartialDate.day(2026, 11, 3)),
          ],
        ),
      ]);
      await pumpApp(tester, cats: repo, locale: const Locale('es'));
      await tester.pump();

      expect(find.text('Se perdió el 3 nov 2026'), findsOneWidget);
      expect(find.text('En su memoria'), findsOneWidget);
    });

    testWidgets('a cat with only born and sterilised has no badge', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        withEvents('Ciccio', [
          ev(LifeEventType.born, const PartialDate.year(2019, around: true)),
          ev(LifeEventType.sterilised, const PartialDate.year(2021)),
        ]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      expect(find.textContaining('Missing'), findsNothing);
      expect(find.text('Remembered'), findsNothing);
    });
  });

  group('the story on the card', () {
    testWidgets('mixes encounters and entries, as precise as given', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        withEvents('Ninja', [
          ev(LifeEventType.born, const PartialDate.year(2019, around: true)),
          ev(LifeEventType.sterilised, const PartialDate.month(2021, 3)),
        ]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      expect(find.text('Born around 2019'), findsOneWidget);
      expect(find.text('Sterilised in March 2021'), findsOneWidget);
      expect(find.text('You recorded this'), findsNWidgets(2));
      expect(find.text('Mar 2, 2025'), findsOneWidget);
      // Newest first: the encounter, then the sterilisation, then the birth.
      final dx = {
        for (final t in ['Sterilised in March 2021', 'Born around 2019'])
          t: tester.getTopLeft(find.text(t)).dx,
      };
      expect(
        dx['Sterilised in March 2021']!,
        lessThan(dx['Born around 2019']!),
      );
    });

    testWidgets('speaks Spanish', (tester) async {
      final repo = FakeCatRepository([
        withEvents('Ninja', [
          ev(LifeEventType.born, const PartialDate.year(2019, around: true)),
          ev(
            LifeEventType.died,
            const PartialDate.day(2026, 9, 16),
            note: 'Dormía al sol',
          ),
        ]),
      ]);
      await pumpApp(tester, cats: repo, locale: const Locale('es'));
      await tester.pump();
      await openCard(tester, 'Ninja');

      expect(find.text('Nació alrededor de 2019'), findsOneWidget);
      expect(find.text('Falleció el 16 sept 2026'), findsWidgets);
      expect(find.text('Dormía al sol'), findsOneWidget);
      expect(find.text('Lo registraste tú'), findsNWidgets(2));
      expect(find.text('Añadir a su historia'), findsOneWidget);
      expect(find.text('alrededor de 2019 – 16 sept 2026'), findsOneWidget);
    });

    testWidgets('a remembered cat keeps its first met - passed away line', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        withEvents('Saibo', [
          ev(LifeEventType.died, const PartialDate.day(2026, 9, 16)),
        ]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Saibo');

      expect(find.text('Passed away Sep 16, 2026'), findsWidgets);
      expect(find.text('Mar 2, 2025 – Sep 16, 2026'), findsOneWidget);
      // The record stays open.
      expect(find.text('Add to story'), findsOneWidget);
    });
  });

  group('the life range of a remembered cat', () {
    Future<void> openRemembered(
      WidgetTester tester,
      List<LifeEvent> events, {
      Locale? locale,
    }) async {
      final repo = FakeCatRepository([withEvents('Saibo', events)]);
      await pumpApp(tester, cats: repo, locale: locale);
      await tester.pump();
      await openCard(tester, 'Saibo');
    }

    testWidgets('starts from the birth entry, as rough as given', (
      tester,
    ) async {
      await openRemembered(tester, [
        ev(LifeEventType.born, const PartialDate.year(2019, around: true)),
        ev(LifeEventType.died, const PartialDate.day(2026, 9, 16)),
      ]);
      expect(find.text('around 2019 – Sep 16, 2026'), findsOneWidget);
    });

    testWidgets('a precise birth is shown plainly', (tester) async {
      await openRemembered(tester, [
        ev(LifeEventType.born, const PartialDate.month(2021, 3)),
        ev(LifeEventType.died, const PartialDate.year(2026)),
      ]);
      expect(find.text('March 2021 – 2026'), findsOneWidget);
    });

    testWidgets('without a birth it starts from the first encounter', (
      tester,
    ) async {
      await openRemembered(tester, [
        ev(LifeEventType.died, const PartialDate.day(2026, 9, 16)),
      ]);
      expect(find.text('Mar 2, 2025 – Sep 16, 2026'), findsOneWidget);
    });

    testWidgets('two different deaths are said, not picked between', (
      tester,
    ) async {
      await openRemembered(tester, [
        ev(LifeEventType.born, const PartialDate.year(2019, around: true)),
        ev(LifeEventType.died, const PartialDate.year(2024)),
        ev(LifeEventType.died, const PartialDate.day(2025, 2, 2)),
      ]);
      expect(find.text('around 2019 – two dates recorded'), findsOneWidget);
      expect(find.textContaining('Feb 2, 2025 –'), findsNothing);
    });

    testWidgets('reads in Spanish', (tester) async {
      await openRemembered(tester, [
        ev(LifeEventType.born, const PartialDate.year(2019, around: true)),
        ev(LifeEventType.died, const PartialDate.day(2026, 9, 16)),
      ], locale: const Locale('es'));
      expect(find.text('alrededor de 2019 – 16 sept 2026'), findsOneWidget);
    });

    testWidgets('the badge has its own row, the button is below', (
      tester,
    ) async {
      await openRemembered(tester, [
        ev(LifeEventType.died, const PartialDate.day(2026, 9, 16)),
      ]);
      final badge = tester.getRect(find.byType(LifeBadge));
      final button = tester.getRect(find.text('Add to story'));
      expect(button.top, greaterThanOrEqualTo(badge.bottom));
      expect(find.text('Passed away Sep 16, 2026'), findsWidgets);
    });
  });

  group('adding to the story', () {
    testWidgets('went missing: today, with a note', (tester) async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await chooseToAdd(tester, 'Went missing');
      await tester.enterText(
        find.byType(TextField).last,
        '  near the market on Tuesday ',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final (id, event) = repo.addedEvents.single;
      expect(id, '1');
      expect(event.type, LifeEventType.missing);
      expect(event.on, _todayDate);
      expect(event.note, 'near the market on Tuesday');
      expect(event.place, isNull);
      expect(find.textContaining('Missing since'), findsWidgets);
      expect(find.text('near the market on Tuesday'), findsOneWidget);
    });

    testWidgets('a missing entry keeps the last-seen coarse area only', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        catAt('1', 'Ninja', [(1000, '9g3q4k')]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await chooseToAdd(tester, 'Went missing');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.addedEvents.single.$2.place?.area.geohash, '9g3q4k');
      // Other types never carry a place.
      await chooseToAdd(tester, 'Passed away');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repo.addedEvents.last.$2.type, LifeEventType.died);
      expect(repo.addedEvents.last.$2.place, isNull);
    });

    testWidgets('cancelling changes nothing', (tester) async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await chooseToAdd(tester, 'Went missing');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repo.wroteAnything, isFalse);
    });

    testWidgets('found celebrates, and keeps the cat as it was', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        withEvents('Ninja', [
          ev(LifeEventType.missing, const PartialDate.day(2026, 11, 3)),
        ]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await chooseToAdd(tester, 'Found');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Ninja is found. Welcome home!'), findsOneWidget);
      expect(repo.addedEvents.single.$2.type, LifeEventType.found);
      await tester.tap(find.text('Wonderful'));
      await tester.pumpAndSettle();
      expect(find.text('Ninja is found. Welcome home!'), findsNothing);
      expect(find.textContaining('Found '), findsWidgets);
    });

    testWidgets('the celebration is still with reduced motion', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final repo = FakeCatRepository([
        withEvents('', [
          ev(LifeEventType.missing, const PartialDate.day(2026, 11, 3)),
        ]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await tester.tap(find.text('No name yet'));
      await tester.pumpAndSettle();

      await chooseToAdd(tester, 'Found');
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump();

      expect(find.text('This cat is found. Welcome home!'), findsOneWidget);
    });

    testWidgets(
      'passed away is gentle, never celebrates, keeps the record open',
      (tester) async {
        final repo = FakeCatRepository([
          cat('1', 'Saibo', [1000]),
        ]);
        await pumpApp(tester, cats: repo);
        await tester.pump();
        await openCard(tester, 'Saibo');

        await chooseToAdd(tester, 'Passed away');
        expect(find.textContaining("We're so sorry"), findsOneWidget);
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(repo.addedEvents.single.$2.type, LifeEventType.died);
        expect(find.textContaining('Welcome home'), findsNothing);
        expect(find.textContaining('Passed away '), findsWidgets);
        expect(find.text('Add to story'), findsOneWidget);
      },
    );

    testWidgets('born needs a year to be picked before it can be saved', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await chooseToAdd(tester, 'Born');
      expect(
        tester.widget<FilterChip>(find.byType(FilterChip)).selected,
        isTrue,
      );
      FilledButton save() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(save().onPressed, isNull);
      expect(find.text('${_today.year}'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('year-null')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2019').last);
      await tester.pumpAndSettle();
      expect(save().onPressed, isNotNull);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
        repo.addedEvents.single.$2.on,
        const PartialDate.year(2019, around: true),
      );
      expect(find.text('Born around 2019'), findsOneWidget);
    });

    testWidgets('the date fields fit at phone width and larger text', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();

      await chooseToAdd(tester, 'Went missing');
      // Day precision is the default: day, month and year all readable.
      expect(find.text('${_today.day}'), findsWidgets);
      expect(find.text('${_today.year}'), findsWidgets);
      expect(tester.takeException(), isNull);
      final year = tester.getSize(find.byKey(ValueKey('year-${_today.year}')));
      expect(year.width, greaterThan(150));
      final day = tester.getSize(find.byKey(ValueKey('day-${_today.day}')));
      expect(day.width, greaterThan(70));
    });

    testWidgets('precision: month and day drop "around"; no future dates', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await chooseToAdd(tester, 'Sterilised');
      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();
      expect(find.byType(FilterChip), findsNothing);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
        repo.addedEvents.single.$2.on,
        PartialDate.month(_today.year, _today.month),
      );
      expect(find.textContaining('Sterilised in '), findsWidgets);
    });

    testWidgets('a once-only entry already there offers to change its date', (
      tester,
    ) async {
      final born = ev(
        LifeEventType.born,
        const PartialDate.year(2019, around: true),
      );
      final repo = FakeCatRepository([
        withEvents('Ninja', [born]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await tester.tap(find.text('Add to story'));
      await tester.pumpAndSettle();
      expect(
        find.text('Already in the story: Born around 2019'),
        findsOneWidget,
      );
      await tester.tap(find.text('Born').last);
      await tester.pumpAndSettle();
      expect(find.text('Change the date'), findsOneWidget);
      expect(find.text('Add another anyway'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(SegmentedButton<DatePrecision>),
          matching: find.text('Year'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final (id, changed) = repo.updatedEvents.single;
      expect(id, '1');
      expect(changed.id, born.id);
      expect(changed.on, PartialDate.year(2019));
      expect(repo.addedEvents, isEmpty);
    });

    testWidgets('"Add another anyway" adds a second entry, nothing refused', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        withEvents('Ninja', [
          ev(LifeEventType.died, const PartialDate.year(2024)),
        ]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await chooseToAdd(tester, 'Passed away');
      expect(find.text('Change the date'), findsOneWidget);
      await tester.tap(find.text('Add another anyway'));
      await tester.pumpAndSettle();
      expect(find.text('Change the date'), findsNothing);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.updatedEvents, isEmpty);
      expect(repo.addedEvents.single.$2.on, _todayDate);
      expect(repo.cats.single.events, hasLength(2));
      expect(find.text('Possible conflict — check these'), findsOneWidget);
    });
  });

  group('editing and deleting', () {
    Future<void> tapEntry(WidgetTester tester, String text) async {
      // The badge may say the same: the entry is the last one on the card.
      await tester.ensureVisible(find.text(text).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(text).last);
      await tester.pumpAndSettle();
    }

    testWidgets('tap an entry to change its date and note', (tester) async {
      final repo = FakeCatRepository([
        withEvents('Ninja', [
          ev(LifeEventType.missing, const PartialDate.day(2026, 11, 3)),
        ]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await tapEntry(tester, 'Missing since Nov 3, 2026');
      await tester.tap(find.text('Edit this entry'));
      await tester.pumpAndSettle();
      expect(find.text('Add another anyway'), findsNothing);
      await tester.enterText(find.byType(TextField).last, 'by the school');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final (_, changed) = repo.updatedEvents.single;
      expect(changed.on, const PartialDate.day(2026, 11, 3));
      expect(changed.note, 'by the school');
      expect(find.text('by the school'), findsOneWidget);
    });

    testWidgets('delete asks once, then removes only that entry', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        withEvents('Ninja', [
          ev(LifeEventType.born, const PartialDate.year(2019, around: true)),
          ev(LifeEventType.missing, const PartialDate.day(2026, 11, 3)),
        ]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await tapEntry(tester, 'Born around 2019');
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this entry?'), findsOneWidget);
      expect(repo.deletedEvents, isEmpty);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(repo.deletedEvents, ['born-2019']);
      expect(find.text('Born around 2019'), findsNothing);
      expect(find.textContaining('Missing since'), findsWidgets);
      expect(repo.cats.single.encounters, hasLength(1));
    });

    testWidgets('cancelling a delete keeps the entry', (tester) async {
      final repo = FakeCatRepository([
        withEvents('Ninja', [
          ev(LifeEventType.born, const PartialDate.year(2019, around: true)),
        ]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await tapEntry(tester, 'Born around 2019');
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repo.deletedEvents, isEmpty);
      expect(find.text('Born around 2019'), findsOneWidget);
    });
  });

  group('conflicts and nudges', () {
    testWidgets('two dates for a death: both shown, one gentle question', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        withEvents('Ninja', [
          ev(LifeEventType.died, const PartialDate.year(2024)),
          ev(LifeEventType.died, const PartialDate.day(2025, 2, 2)),
        ]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      expect(find.text('Possible conflict — check these'), findsOneWidget);
      expect(
        find.text(
          'Two dates for when this cat passed away. Is one of them wrong?',
        ),
        findsOneWidget,
      );
      expect(find.text('Passed away in 2024'), findsOneWidget);
      expect(find.text('Passed away Feb 2, 2025'), findsWidgets);
    });

    testWidgets('the conflict reads in Spanish', (tester) async {
      final repo = FakeCatRepository([
        withEvents('Ninja', [
          ev(LifeEventType.died, const PartialDate.year(2024)),
          ev(LifeEventType.died, const PartialDate.day(2025, 2, 2)),
        ]),
      ]);
      await pumpApp(tester, cats: repo, locale: const Locale('es'));
      await tester.pump();
      await openCard(tester, 'Ninja');

      expect(find.text('Puede que no coincidan — revísalos'), findsOneWidget);
      expect(
        find.text('Hay dos fechas de su fallecimiento. ¿Alguna está mal?'),
        findsOneWidget,
      );
    });

    testWidgets('a sighting after a death is a question, nothing is hidden', (
      tester,
    ) async {
      final c = Cat(
        id: '1',
        name: 'Saibo',
        encounters: [
          Encounter(id: 'e1', photoId: 'e1', time: DateTime(2026, 3, 2, 10)),
        ],
        events: [ev(LifeEventType.died, const PartialDate.day(2026, 3, 1))],
      );
      final repo = FakeCatRepository([c]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Saibo');

      expect(find.text('Possible conflict — check these'), findsOneWidget);
      expect(
        find.text(
          "There's a sighting on Mar 2, 2026, after this cat was recorded as "
          'having passed away. Is one of them wrong?',
        ),
        findsOneWidget,
      );
      expect(find.text('Passed away Mar 1, 2026'), findsWidgets);
      expect(repo.wroteAnything, isFalse);
    });

    testWidgets('a sighting after missing offers "Found?" in one tap', (
      tester,
    ) async {
      final c = Cat(
        id: '1',
        name: 'Ninja',
        encounters: [
          Encounter(id: 'e1', photoId: 'e1', time: DateTime(2026, 11, 12, 9)),
        ],
        events: [ev(LifeEventType.missing, const PartialDate.day(2026, 11, 3))],
      );
      final repo = FakeCatRepository([c]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      expect(find.text('Possible conflict — check these'), findsNothing);
      expect(repo.wroteAnything, isFalse);
      await tester.tap(find.text('Seen on Nov 12. Found?'));
      await tester.pumpAndSettle();

      final (_, found) = repo.addedEvents.single;
      expect(found.type, LifeEventType.found);
      expect(found.on, const PartialDate.day(2026, 11, 12));
      expect(find.text('Ninja is found. Welcome home!'), findsOneWidget);
    });
  });

  group('the ear-tip offer', () {
    Cat tipped() => Cat(
      id: '1',
      name: 'Ninja',
      encounters: [
        Encounter(
          id: 'e1',
          photoId: 'e1',
          time: DateTime(2026, 5, 1),
          details: const EncounterDetails(conditions: [Condition.earTipped]),
        ),
      ],
    );

    testWidgets('is offered, adds nothing by itself, and only once', (
      tester,
    ) async {
      final repo = FakeCatRepository([tipped()]);
      final offers = FakeOfferRepository();
      await pumpApp(tester, cats: repo, offers: offers);
      await tester.pump();
      await openCard(tester, 'Ninja');

      expect(
        find.text('Ear-tipped: add sterilisation to the story?'),
        findsOneWidget,
      );
      expect(repo.wroteAnything, isFalse);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(
        find.text('Ear-tipped: add sterilisation to the story?'),
        findsNothing,
      );
      expect(offers.answered, {'1'});
      expect(repo.wroteAnything, isFalse);
    });

    testWidgets('is not offered again once answered', (tester) async {
      final repo = FakeCatRepository([tipped()]);
      await pumpApp(tester, cats: repo, offers: FakeOfferRepository({'1'}));
      await tester.pump();
      await openCard(tester, 'Ninja');
      expect(find.textContaining('Ear-tipped'), findsNothing);
    });

    testWidgets('is not offered when sterilisation is already in the story', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        tipped().copyWith(
          events: [ev(LifeEventType.sterilised, const PartialDate.year(2024))],
        ),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');
      expect(find.textContaining('Ear-tipped'), findsNothing);
    });

    testWidgets('Add opens the sterilisation dialog; saving adds it', (
      tester,
    ) async {
      final repo = FakeCatRepository([tipped()]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.text('Sterilised'), findsOneWidget);
      expect(repo.wroteAnything, isFalse);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final (_, e) = repo.addedEvents.single;
      expect(e.type, LifeEventType.sterilised);
      expect(e.on, PartialDate.year(_today.year, around: true));
      expect(find.textContaining('Ear-tipped'), findsNothing);
    });

    testWidgets('speaks Spanish', (tester) async {
      final repo = FakeCatRepository([tipped()]);
      await pumpApp(tester, cats: repo, locale: const Locale('es'));
      await tester.pump();
      await openCard(tester, 'Ninja');
      expect(
        find.text('Oreja cortada: ¿añadir la esterilización a su historia?'),
        findsOneWidget,
      );
    });
  });

  group('the add dialog in Spanish', () {
    testWidgets('choices, help and precision', (tester) async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]),
      ]);
      await pumpApp(tester, cats: repo, locale: const Locale('es'));
      await tester.pump();
      await openCard(tester, 'Ninja');

      await tester.tap(find.text('Añadir a su historia'));
      await tester.pumpAndSettle();
      for (final t in [
        'Se perdió',
        'Apareció',
        'Nació',
        'Esterilización',
        'Falleció',
      ]) {
        expect(find.text(t), findsOneWidget);
      }
      await tester.tap(find.text('Falleció'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Lo sentimos mucho'), findsOneWidget);
      expect(find.text('Día'), findsWidgets);
      expect(find.text('Mes'), findsWidgets);
      expect(find.text('Año'), findsWidgets);
    });
  });

  group('rename keeps the story', () {
    testWidgets('only the name changes', (tester) async {
      final repo = FakeCatRepository([
        withEvents('', [
          ev(LifeEventType.missing, const PartialDate.day(2026, 11, 3)),
        ]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await tester.tap(find.text('No name yet'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Ninja');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(repo.cats.single.name, 'Ninja');
      expect(repo.cats.single.events, hasLength(1));
    });
  });

  group('controller', () {
    test('a date in the future becomes today, at the same precision', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]),
      ]);
      final container = makeContainer(cats: repo);
      container.listen(catsControllerProvider, (_, _) {});
      await container.read(catsControllerProvider.future);
      final controller = container.read(catsControllerProvider.notifier);

      await controller.addEvent(
        '1',
        LifeEventType.found,
        PartialDate.day(_today.year + 1, 1, 1),
      );
      await controller.addEvent(
        '1',
        LifeEventType.found,
        PartialDate.month(_today.year, 12),
        note: ' ${'x' * 1200} ',
      );

      final first = repo.addedEvents[0].$2;
      expect(first.on, _todayDate);
      final second = repo.addedEvents[1].$2;
      expect(second.on.precision, DatePrecision.month);
      expect(second.note.length, LifeEventType.maxNoteLength);
      expect(first.id, isNot(second.id));
    });

    test('an unknown cat gets nothing', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]),
      ]);
      final container = makeContainer(cats: repo);
      container.listen(catsControllerProvider, (_, _) {});
      await container.read(catsControllerProvider.future);
      final e = await container
          .read(catsControllerProvider.notifier)
          .addEvent('nobody', LifeEventType.died, _todayDate);
      expect(e, isNull);
      expect(repo.wroteAnything, isFalse);
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

    testWidgets('shows the derived life and the entries, with no actions', (
      tester,
    ) async {
      final repo = FakeCatRepository();
      await pumpCard(
        tester,
        withEvents('Ninja', [
          ev(
            LifeEventType.missing,
            const PartialDate.day(2026, 11, 3),
            note: 'near the market',
          ),
          ev(LifeEventType.born, const PartialDate.year(2019, around: true)),
        ]).copyWith(
          encounters: [
            Encounter(
              id: 'e1',
              photoId: 'e1',
              time: DateTime(2026, 11, 12),
              details: const EncounterDetails(
                conditions: [Condition.earTipped],
              ),
            ),
          ],
        ),
        const Locale('en'),
      );

      expect(find.text('Missing since Nov 3, 2026'), findsWidgets);
      expect(find.text('Born around 2019'), findsOneWidget);
      expect(find.text('near the market'), findsOneWidget);
      expect(find.text('Add to story'), findsNothing);
      expect(find.byIcon(Icons.edit_note), findsNothing);
      // No nudge, no ear-tip offer: they ask something.
      expect(find.textContaining('Found?'), findsNothing);
      expect(find.textContaining('Ear-tipped'), findsNothing);
      // Tapping an entry does nothing.
      await tester.ensureVisible(find.text('Born around 2019'));
      await tester.tap(find.text('Born around 2019'));
      await tester.pumpAndSettle();
      expect(find.text('Edit this entry'), findsNothing);
      expect(repo.wroteAnything, isFalse);
    });

    testWidgets('shows a conflict, read only, in Spanish', (tester) async {
      await pumpCard(
        tester,
        withEvents('Ninja', [
          ev(LifeEventType.died, const PartialDate.year(2024)),
          ev(LifeEventType.died, const PartialDate.year(2025)),
        ]),
        const Locale('es'),
      );
      expect(find.text('Puede que no coincidan — revísalos'), findsOneWidget);
      expect(find.text('Añadir a su historia'), findsNothing);
    });

    testWidgets('a cat with no story shows no story area at all', (
      tester,
    ) async {
      await pumpCard(tester, cat('1', 'Ninja', [1000]), const Locale('es'));
      expect(find.text('Añadir a su historia'), findsNothing);
      expect(find.textContaining('Falleció'), findsNothing);
    });
  });
}
