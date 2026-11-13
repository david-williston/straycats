import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/data/firestore_cat_repository.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/encounter.dart';
import 'package:straycats/src/features/cats/domain/encounter_details.dart';
import 'package:straycats/src/features/cats/data/coarse_guard.dart';
import 'package:straycats/src/features/cats/domain/life_event.dart';
import 'package:straycats/src/features/cats/domain/partial_date.dart';
import 'package:straycats/src/features/places/domain/coarse_area.dart';
import 'package:straycats/src/features/places/domain/place.dart';

import '../../../helpers.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirestoreCatRepository repo;
  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirestoreCatRepository(db, 'u1');
  });

  Future<QuerySnapshot<Map<String, dynamic>>> docs(String collection) =>
      db.collection('users/u1/$collection').get();

  test(
    'a new cat and its encounter are written in the flat collections',
    () async {
      await repo.addCat(
        Cat(
          id: '1000',
          name: 'Ninja',
          encounters: [
            Encounter(
              id: '1000',
              photoId: '1000',
              time: DateTime.fromMillisecondsSinceEpoch(1000),
              details: EncounterDetails(
                activity: Activity.sleeping,
                conditions: [Condition.earTipped],
                care: [Care.fed],
                note: 'Sleeps on the car',
              ),
            ),
          ],
        ),
      );

      final cat = (await db.doc('users/u1/cats/1000').get()).data()!;
      expect(cat.keys.toSet(), {'name', 'updatedAt'});
      expect(cat['name'], 'Ninja');
      final encounter = (await db.doc('users/u1/encounters/1000').get())
          .data()!;
      expect(encounter['catId'], '1000');
      expect(encounter['photoId'], '1000');
      expect(encounter['activity'], 'sleeping');
      expect(encounter['conditions'], ['ear_tipped']);
      expect(encounter['care'], ['fed']);
      expect(encounter['note'], 'Sleeps on the car');
      expect(encounter.containsKey('type'), isFalse);
      expect(encounter['takenAt'], Timestamp.fromMillisecondsSinceEpoch(1000));
      expect(encounter.containsKey('updatedAt'), isTrue);
    },
  );

  test('an encounter with no details has only the basic fields', () async {
    await repo.addCat(cat('1', '', [1000]));
    final e = (await db.doc('users/u1/encounters/1000').get()).data()!;
    expect(e.keys.toSet(), {'catId', 'photoId', 'takenAt', 'updatedAt'});
  });

  test('an old document with a type reads as the new fields', () async {
    await db.doc('users/u1/cats/1').set({'name': 'Old'});
    await db.doc('users/u1/encounters/1000').set({
      'catId': '1',
      'photoId': '1000',
      'takenAt': Timestamp.fromMillisecondsSinceEpoch(1000),
      'type': 'unwell',
    });
    final cats = await repo.watchCats().first;
    expect(cats.single.latest!.details.conditions, [Condition.unwellOrInjured]);
  });

  test('updating replaces the details and drops an old type', () async {
    await db.doc('users/u1/cats/1').set({'name': 'Old'});
    await db.doc('users/u1/encounters/1000').set({
      'catId': '1',
      'photoId': '1000',
      'takenAt': Timestamp.fromMillisecondsSinceEpoch(1000),
      'type': 'fed',
    });
    await repo.updateEncounter(
      '1',
      Encounter(
        id: '1000',
        photoId: '1000',
        time: DateTime.fromMillisecondsSinceEpoch(1000),
        details: const EncounterDetails(
          activity: Activity.playing,
          note: 'Chased a leaf',
        ),
      ),
    );
    final e = (await db.doc('users/u1/encounters/1000').get()).data()!;
    expect(e.containsKey('type'), isFalse);
    expect(e['activity'], 'playing');
    expect(e['note'], 'Chased a leaf');
    expect(e.containsKey('conditions'), isFalse);
    expect((await docs('encounters')).docs, hasLength(1));
  });

  test('deleting an encounter keeps its cat', () async {
    await repo.addCat(cat('1', 'Ciccio', [1000]));
    await repo.deleteEncounter('1000');
    expect((await docs('encounters')).docs, isEmpty);
    final cats = await repo.watchCats().first;
    expect(cats.single.name, 'Ciccio');
    expect(cats.single.encounters, isEmpty);
  });

  test('watchCats combines the cats with their encounters', () async {
    await repo.addCat(cat('1', 'Ciccio', [1000]));
    await repo.addEncounter(
      '1',
      Encounter(
        id: '3000',
        photoId: '3000',
        time: DateTime.fromMillisecondsSinceEpoch(3000),
        details: const EncounterDetails(care: [Care.fed]),
      ),
    );
    await repo.addCat(cat('2', '', [2000]));

    final cats = await repo.watchCats().first;

    expect(cats, hasLength(2));
    final ciccio = cats.firstWhere((c) => c.id == '1');
    expect(ciccio.name, 'Ciccio');
    expect(ciccio.history.map((e) => e.photoId), ['3000', '1000']);
    expect(ciccio.latest!.details.care, [Care.fed]);
    expect(cats.firstWhere((c) => c.id == '2').name, '');
  });

  test('encounters of a missing cat are ignored', () async {
    await repo.addCat(cat('1', 'Ciccio', [1000]));
    await repo.addEncounter(
      'nobody',
      Encounter(
        id: '5',
        photoId: '5',
        time: DateTime.fromMillisecondsSinceEpoch(5),
      ),
    );

    final cats = await repo.watchCats().first;

    expect(cats.single.id, '1');
    expect(cats.single.encounters, hasLength(1));
  });

  test('watchCats emits again after a change', () async {
    await repo.addCat(cat('1', 'Ciccio', [1000]));
    final names = <String>[];
    final sub = repo.watchCats().listen((c) => names.add(c.single.name));

    await pumpEventQueue();
    await repo.renameCat('1', 'Ninja');
    await pumpEventQueue();
    await sub.cancel();

    expect(names.first, 'Ciccio');
    expect(names.last, 'Ninja');
  });

  test('rename writes the name and keeps the encounters', () async {
    await repo.addCat(cat('1', 'Ciccio', [1000]));
    await repo.renameCat('1', 'Ninja');

    expect((await db.doc('users/u1/cats/1').get())['name'], 'Ninja');
    expect((await docs('encounters')).docs, hasLength(1));
  });

  test('another user does not see these cats', () async {
    await repo.addCat(cat('1', 'Ciccio', [1000]));
    final other = FirestoreCatRepository(db, 'u2');
    expect(await other.watchCats().first, isEmpty);
  });

  group('life events', () {
    LifeEvent event(
      String id,
      LifeEventType type,
      PartialDate on, {
      String note = '',
      Place? place,
    }) => LifeEvent(id: id, type: type, on: on, note: note, place: place);

    test(
      'an event round trips with its date, around, note and place',
      () async {
        await repo.addCat(cat('1', 'Ninja', [1000]));
        await repo.addEvent(
          '1',
          event(
            '10',
            LifeEventType.born,
            const PartialDate.year(2019, around: true),
            note: 'Under the porch',
          ),
        );
        await repo.addEvent(
          '1',
          event(
            '11',
            LifeEventType.missing,
            const PartialDate.day(2026, 11, 3),
            place: Place(
              area: CoarseArea.fromGeohash('9g3q4k'),
              neighbourhood: 'Rinconada',
            ),
          ),
        );

        final born = (await db.doc('users/u1/events/10').get()).data()!;
        expect(born['catId'], '1');
        expect(born['type'], 'born');
        expect(born['on'], '2019');
        expect(born['around'], isTrue);
        expect(born['note'], 'Under the porch');
        expect(born.containsKey('area'), isFalse);
        expect(born.keys, containsAll(['createdAt', 'updatedAt']));
        final missing = (await db.doc('users/u1/events/11').get()).data()!;
        expect(missing['on'], '2026-11-03');
        expect(missing.containsKey('around'), isFalse);
        expect(missing['area'], '9g3q4k');
        expect(missing['neighbourhood'], 'Rinconada');

        final c = (await repo.watchCats().first).single;
        expect(c.events, hasLength(2));
        final back = c.events.firstWhere((e) => e.id == '10');
        expect(back.type, LifeEventType.born);
        expect(back.on, const PartialDate.year(2019, around: true));
        expect(back.note, 'Under the porch');
        expect(back.createdAt, isNotNull);
        final m = c.events.firstWhere((e) => e.id == '11');
        expect(m.place?.area.geohash, '9g3q4k');
        expect(m.place?.neighbourhood, 'Rinconada');
        expect(c.encounters, hasLength(1));
      },
    );

    test('a cat with no events has none', () async {
      await repo.addCat(cat('1', 'Ciccio', [1000]));
      expect((await repo.watchCats().first).single.events, isEmpty);
    });

    test(
      'updating keeps the type and creation time, and clears what is gone',
      () async {
        await repo.addCat(cat('1', 'Ninja', [1000]));
        await repo.addEvent(
          '1',
          event(
            '10',
            LifeEventType.born,
            const PartialDate.year(2019, around: true),
            note: 'x',
          ),
        );
        final before = (await db.doc('users/u1/events/10').get()).data()!;
        await repo.updateEvent(
          '1',
          event('10', LifeEventType.born, const PartialDate.month(2019, 3)),
        );
        final after = (await db.doc('users/u1/events/10').get()).data()!;
        expect(after['on'], '2019-03');
        expect(after.containsKey('around'), isFalse);
        expect(after.containsKey('note'), isFalse);
        expect(after['type'], 'born');
        expect(after['createdAt'], before['createdAt']);
        expect((await docs('events')).docs, hasLength(1));
      },
    );

    test('deleting an event keeps the cat and its encounters', () async {
      await repo.addCat(cat('1', 'Ninja', [1000]));
      await repo.addEvent(
        '1',
        event('10', LifeEventType.died, const PartialDate.year(2025)),
      );
      await repo.deleteEvent('10');
      expect((await docs('events')).docs, isEmpty);
      final c = (await repo.watchCats().first).single;
      expect(c.name, 'Ninja');
      expect(c.encounters, hasLength(1));
      expect(c.events, isEmpty);
    });

    test(
      'events of another cat or a missing cat go where they belong',
      () async {
        await repo.addCat(cat('1', 'A', [1000]));
        await repo.addCat(cat('2', 'B', [2000]));
        await repo.addEvent(
          '2',
          event('10', LifeEventType.found, const PartialDate.day(2026, 1, 2)),
        );
        await repo.addEvent(
          'nobody',
          event('11', LifeEventType.found, const PartialDate.day(2026, 1, 2)),
        );
        final cats = await repo.watchCats().first;
        expect(cats.firstWhere((c) => c.id == '1').events, isEmpty);
        expect(cats.firstWhere((c) => c.id == '2').events.single.id, '10');
      },
    );

    test('an unreadable event document is ignored', () async {
      await repo.addCat(cat('1', 'A', [1000]));
      await db.doc('users/u1/events/bad').set({
        'catId': '1',
        'type': 'died',
        'on': '2021-02-30',
      });
      await db.doc('users/u1/events/odd').set({
        'catId': '1',
        'type': 'shrugged',
        'on': '2021',
      });
      expect((await repo.watchCats().first).single.events, isEmpty);
    });

    test('a cat added with events writes them in the same batch', () async {
      await repo.addCat(
        Cat(
          id: '1',
          name: 'Saibo',
          events: [
            event('10', LifeEventType.died, const PartialDate.year(2025)),
          ],
        ),
      );
      expect((await repo.watchCats().first).single.events, hasLength(1));
    });

    test('another user does not see these events', () async {
      await repo.addCat(cat('1', 'A', [1000]));
      await repo.addEvent(
        '1',
        event('10', LifeEventType.died, const PartialDate.year(2025)),
      );
      expect(await FirestoreCatRepository(db, 'u2').watchCats().first, isEmpty);
    });

    test('the coarse guard checks events: no unknown or exact fields', () {
      final ok = {
        'catId': '1',
        'type': 'missing',
        'on': '2026-11-03',
        'area': '9g3q4k',
        'neighbourhood': 'Rinconada',
        'createdAt': 1,
        'updatedAt': 1,
      };
      expect(() => assertCoarseEvent(ok), returnsNormally);
      expect(
        () => assertCoarseEvent({...ok, 'area': '9g3q4kx'}),
        throwsA(isA<CoarseGuardException>()),
      );
      expect(
        () => assertCoarseEvent({...ok, 'lat': 19.4, 'lng': -99.1}),
        throwsA(isA<CoarseGuardException>()),
      );
      expect(
        () => assertCoarseEvent({...ok, 'location': const GeoPoint(1, 2)}),
        throwsA(isA<CoarseGuardException>()),
      );
      expect(
        () => assertCoarseEvent({...ok, 'neighbourhood': 'x' * 81}),
        throwsA(isA<CoarseGuardException>()),
      );
      expect(
        () => assertCoarse({...ok}),
        throwsA(isA<CoarseGuardException>()),
        reason: 'event fields are not valid on an encounter',
      );
    });
  });
}
