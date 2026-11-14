import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:straycats/src/features/cats/data/coarse_guard.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/data/firestore_cat_repository.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/cat_traits.dart';
import 'package:straycats/src/features/cats/domain/life_event.dart';
import 'package:straycats/src/features/cats/domain/partial_date.dart';
import 'package:straycats/src/localization/app_localizations.dart';
import 'package:straycats/src/localization/life_labels.dart';

import '../../helpers.dart';

final _today = DateTime.now();
final _todayDate = PartialDate.day(_today.year, _today.month, _today.day);

LifeEvent _ev(
  LifeEventType type,
  PartialDate on, {
  String id = 'e1',
  HealthKind? kind,
  String note = '',
}) => LifeEvent(
  id: id,
  type: type,
  on: on,
  kind: kind,
  note: note,
  createdAt: DateTime.fromMillisecondsSinceEpoch(1),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('es');
  });

  group('data', () {
    late FakeFirebaseFirestore db;
    late FirestoreCatRepository repo;
    setUp(() {
      db = FakeFirebaseFirestore();
      repo = FirestoreCatRepository(db, 'u1');
    });

    test('looks round trip, and a new cat has none stored', () async {
      await repo.addCat(cat('1', 'Ninja', [1000]));
      expect((await db.doc('users/u1/cats/1').get()).data()!.keys.toSet(), {
        'name',
        'updatedAt',
      });
      await repo.setCatLooks(
        '1',
        sex: CatSex.female,
        hair: CatHair.long,
        colour: CatColour.calicoTortie,
      );
      final stored = (await db.doc('users/u1/cats/1').get()).data()!;
      expect(stored['sex'], 'female');
      expect(stored['hair'], 'long');
      expect(stored['colour'], 'calico_tortie');
      final back = (await repo.watchCats().first).single;
      expect(back.name, 'Ninja');
      expect(back.sex, CatSex.female);
      expect(back.hair, CatHair.long);
      expect(back.colour, CatColour.calicoTortie);
    });

    test('renaming keeps the looks; clearing one removes only it', () async {
      await repo.addCat(cat('1', 'Ninja', [1000]));
      await repo.setCatLooks('1', sex: CatSex.male, colour: CatColour.tabby);
      await repo.renameCat('1', 'Ciccio');
      var c = (await repo.watchCats().first).single;
      expect(c.name, 'Ciccio');
      expect(c.sex, CatSex.male);
      expect(c.colour, CatColour.tabby);

      await repo.setCatLooks('1', colour: CatColour.tabby);
      final stored = (await db.doc('users/u1/cats/1').get()).data()!;
      expect(stored.containsKey('sex'), isFalse);
      expect(stored.containsKey('hair'), isFalse);
      c = (await repo.watchCats().first).single;
      expect(c.sex, isNull);
      expect(c.colour, CatColour.tabby);
    });

    test('unknown stored looks read as not sure', () async {
      await db.doc('users/u1/cats/1').set({
        'name': 'X',
        'sex': 'robot',
        'hair': 'medium',
        'colour': 'purple',
      });
      final c = (await repo.watchCats().first).single;
      expect(c.sex, isNull);
      expect(c.hair, isNull);
      expect(c.colour, isNull);
    });

    test('every colour survives its stored name', () {
      for (final colour in CatColour.values) {
        expect(CatColour.fromStored(colour.stored), colour);
      }
      expect(CatColour.calicoTortie.stored, 'calico_tortie');
    });

    test(
      'a health entry round trips with its kind and can change it',
      () async {
        await repo.addCat(cat('1', 'Ninja', [1000]));
        await repo.addEvent(
          '1',
          _ev(
            LifeEventType.health,
            const PartialDate.month(2025, 3),
            id: '10',
            kind: HealthKind.vaccination,
            note: 'Rabies',
          ),
        );
        final stored = (await db.doc('users/u1/events/10').get()).data()!;
        expect(stored['type'], 'health');
        expect(stored['kind'], 'vaccination');
        var e = (await repo.watchCats().first).single.events.single;
        expect(e.kind, HealthKind.vaccination);
        expect(e.on, const PartialDate.month(2025, 3));
        expect(e.note, 'Rabies');

        await repo.updateEvent('1', e.copyWith(kind: HealthKind.surgery));
        e = (await repo.watchCats().first).single.events.single;
        expect(e.kind, HealthKind.surgery);
        expect(e.type, LifeEventType.health);
        expect(e.createdAt, isNotNull);
        expect(LifeEventType.health.onceOnly, isFalse);
      },
    );

    test('the coarse guard accepts a kind', () {
      expect(
        () => assertCoarseEvent({
          'catId': '1',
          'type': 'health',
          'on': '2025',
          'kind': 'dental',
          'createdAt': 1,
          'updatedAt': 1,
        }),
        returnsNormally,
      );
    });

    test('Cat looks are kept by copyWith and compared', () {
      final c = const Cat(id: '1').withLooks(sex: CatSex.male);
      expect(c.copyWith(name: 'A').sex, CatSex.male);
      expect(c == const Cat(id: '1'), isFalse);
      expect(Cat.fromJson(c.toJson()).sex, CatSex.male);
    });
  });

  group('labels', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final es = lookupAppLocalizations(const Locale('es'));
    final sterilised = _ev(
      LifeEventType.sterilised,
      const PartialDate.year(2021, around: true),
    );

    test('sterilised reads by sex, in English', () {
      String l(CatSex? s) => lifeEventLabel(en, sterilised, 'en', sex: s);
      expect(l(CatSex.male), 'Neutered around 2021');
      expect(l(CatSex.female), 'Spayed around 2021');
      expect(l(null), 'Sterilised around 2021');
      final t = LifeEventType.sterilised;
      expect(lifeTypeName(en, t, sex: CatSex.male), 'Neutered');
      expect(lifeTypeName(en, t, sex: CatSex.female), 'Spayed');
      expect(lifeTypeName(en, t), 'Sterilised');
    });

    test('sterilised reads by sex, in Spanish', () {
      String l(CatSex? s) => lifeEventLabel(es, sterilised, 'es', sex: s);
      expect(l(CatSex.male), 'Castrado alrededor de 2021');
      expect(l(CatSex.female), 'Esterilizada alrededor de 2021');
      expect(l(null), 'Esterilización alrededor de 2021');
      final t = LifeEventType.sterilised;
      expect(lifeTypeName(es, t, sex: CatSex.male), 'Castrado');
      expect(lifeTypeName(es, t, sex: CatSex.female), 'Esterilizada');
      expect(lifeTypeName(es, t), 'Esterilización');
    });

    test('the coat line', () {
      String? l(CatHair? h, CatColour? c) => catCoatLine(en, h, c);
      expect(l(CatHair.short, CatColour.tabby), 'Short hair · tabby');
      expect(
        l(CatHair.long, CatColour.calicoTortie),
        'Long hair · calico / tortie',
      );
      expect(l(CatHair.long, null), 'Long hair');
      expect(l(null, CatColour.black), 'Black');
      expect(l(null, null), isNull);
      expect(
        catCoatLine(es, CatHair.short, CatColour.tabby),
        'Pelo corto · atigrado',
      );
    });

    test('health sentences name the kind, in both languages', () {
      final e = _ev(
        LifeEventType.health,
        const PartialDate.day(2026, 3, 12),
        kind: HealthKind.vaccination,
      );
      expect(lifeEventLabel(en, e, 'en'), 'Vaccination on Mar 12, 2026');
      expect(lifeEventLabel(es, e, 'es'), 'Vacunación el 12 mar 2026');
      final other = _ev(
        LifeEventType.health,
        const PartialDate.year(2025, around: true),
        kind: HealthKind.other,
      );
      expect(lifeEventLabel(en, other, 'en'), 'Health around 2025');
      expect(lifeEventLabel(es, other, 'es'), 'Salud alrededor de 2025');
    });
  });

  group('sex on the card', () {
    testWidgets('the menu and the entry say Neutered for a male', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        cat('1', 'Ciccio', [1000])
            .withLooks(sex: CatSex.male)
            .copyWith(
              events: [
                _ev(LifeEventType.sterilised, const PartialDate.year(2021)),
              ],
            ),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await tester.tap(find.text('Ciccio'));
      await tester.pumpAndSettle();
      expect(find.text('Neutered in 2021'), findsOneWidget);
      await tester.tap(find.text('Add to story'));
      await tester.pumpAndSettle();
      expect(find.text('Neutered'), findsOneWidget);
      expect(find.text('Sterilised'), findsNothing);
    });

    testWidgets('the menu says Esterilizada for a female, in Spanish', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        cat('1', 'Luna', [1000]).withLooks(sex: CatSex.female),
      ]);
      await pumpApp(tester, cats: repo, locale: const Locale('es'));
      await tester.pump();
      await tester.tap(find.text('Luna'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Añadir a su historia'));
      await tester.pumpAndSettle();
      expect(find.text('Esterilizada'), findsOneWidget);
      expect(find.text('Salud'), findsOneWidget);
    });

    testWidgets('choosing Female in the sheet saves it', (tester) async {
      final repo = FakeCatRepository([
        cat('1', 'Luna', [1000]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await tester.tap(find.text('Luna'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('About this cat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();
      expect(repo.cats.single.sex, CatSex.female);
      await tester.tap(find.text('Not sure').first);
      await tester.pumpAndSettle();
      expect(repo.cats.single.sex, isNull);
    });
  });

  group('coat on the card', () {
    testWidgets('chips save hair and colour and the card shows the line', (
      tester,
    ) async {
      final repo = FakeCatRepository([
        cat('1', 'Luna', [1000]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await tester.tap(find.text('Luna'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('About this cat'));
      await tester.pumpAndSettle();
      // Every row starts on Not sure.
      expect(find.text('Not sure'), findsNWidgets(3));
      await tester.tap(find.text('Short'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tabby'));
      await tester.pumpAndSettle();
      expect(repo.cats.single.hair, CatHair.short);
      expect(repo.cats.single.colour, CatColour.tabby);
      expect(repo.cats.single.sex, isNull);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Short hair · tabby'), findsOneWidget);
    });

    testWidgets('the line reads in Spanish', (tester) async {
      final repo = FakeCatRepository([
        cat('1', 'Luna', [
          1000,
        ]).withLooks(hair: CatHair.long, colour: CatColour.orange),
      ]);
      await pumpApp(tester, cats: repo, locale: const Locale('es'));
      await tester.pump();
      await tester.tap(find.text('Luna'));
      await tester.pumpAndSettle();
      expect(find.text('Pelo largo · naranja'), findsOneWidget);
    });

    testWidgets('renaming a cat keeps its looks', (tester) async {
      final repo = FakeCatRepository([
        cat('1', '', [
          1000,
        ]).withLooks(sex: CatSex.male, colour: CatColour.grey),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await tester.tap(find.text('No name yet'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Ninja');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(repo.cats.single.name, 'Ninja');
      expect(repo.cats.single.sex, CatSex.male);
      expect(repo.cats.single.colour, CatColour.grey);
    });
  });

  group('health in the story', () {
    Future<void> openCard(WidgetTester tester, String name) async {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }

    testWidgets('add: choose a kind, a note, save', (tester) async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');
      await tester.tap(find.text('Add to story'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Health'));
      await tester.pumpAndSettle();

      // A kind is needed first.
      final save = find.widgetWithText(FilledButton, 'Save');
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      await tester.tap(find.text('Vaccination'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, ' Rabies shot ');
      await tester.tap(save);
      await tester.pumpAndSettle();

      final (id, event) = repo.addedEvents.single;
      expect(id, '1');
      expect(event.type, LifeEventType.health);
      expect(event.kind, HealthKind.vaccination);
      expect(event.on, _todayDate);
      expect(event.note, 'Rabies shot');
      expect(find.textContaining('Vaccination on'), findsOneWidget);
      expect(find.text('Rabies shot'), findsOneWidget);
    });

    testWidgets('health can be added again and again', (tester) async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]).copyWith(
          events: [
            _ev(
              LifeEventType.health,
              const PartialDate.day(2026, 1, 5),
              kind: HealthKind.checkup,
            ),
          ],
        ),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');
      await tester.tap(find.text('Add to story'));
      await tester.pumpAndSettle();
      // No "already in the story" for a repeatable type.
      expect(find.textContaining('Already in the story'), findsNothing);
      await tester.tap(find.text('Health'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dental'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repo.cats.single.events, hasLength(2));
      expect(find.textContaining('Possible conflict'), findsNothing);
    });

    testWidgets('edit the kind and note; delete', (tester) async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]).copyWith(
          events: [
            _ev(
              LifeEventType.health,
              const PartialDate.day(2026, 1, 5),
              kind: HealthKind.checkup,
              note: 'All fine',
            ),
          ],
        ),
      ]);
      await pumpApp(tester, cats: repo);
      await tester.pump();
      await openCard(tester, 'Ninja');

      await tester.ensureVisible(find.text('Check-up on Jan 5, 2026'));
      await tester.tap(find.text('Check-up on Jan 5, 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit this entry'));
      await tester.pumpAndSettle();
      // The existing kind is selected, so Save is already on.
      await tester.tap(find.text('Surgery'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Spayed');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final (_, changed) = repo.updatedEvents.single;
      expect(changed.kind, HealthKind.surgery);
      expect(changed.note, 'Spayed');
      expect(changed.type, LifeEventType.health);
      expect(find.text('Surgery on Jan 5, 2026'), findsOneWidget);

      await tester.tap(find.text('Surgery on Jan 5, 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(repo.deletedEvents, ['e1']);
      expect(repo.cats.single.events, isEmpty);
    });

    testWidgets('the dialog reads in Spanish', (tester) async {
      final repo = FakeCatRepository([
        cat('1', 'Ninja', [1000]),
      ]);
      await pumpApp(tester, cats: repo, locale: const Locale('es'));
      await tester.pump();
      await openCard(tester, 'Ninja');
      await tester.tap(find.text('Añadir a su historia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salud'));
      await tester.pumpAndSettle();
      for (final t in [
        'Vacunación',
        'Dental',
        'Revisión',
        'Análisis',
        'Cirugía',
        'Otro',
      ]) {
        expect(find.text(t), findsOneWidget);
      }
    });
  });
}
