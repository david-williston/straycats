import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/data/firestore_cat_repository.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/cat_status.dart';
import 'package:straycats/src/features/cats/domain/encounter.dart';
import 'package:straycats/src/features/cats/domain/encounter_details.dart';

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



  group('status', () {
    final since = DateTime(2026, 11, 10);

    test('a cat with no status field is known', () async {
      await repo.addCat(cat('1', 'Ciccio', [1000]));
      final c = (await repo.watchCats().first).single;
      expect(c.status, CatStatus.known);
      expect(c.statusSince, isNull);
      expect(c.statusNote, '');
    });

    test('a status round trips with its date and note', () async {
      await repo.addCat(cat('1', 'Ninja', [1000]));
      await repo.setStatus(
        '1',
        CatStatus.missing,
        since: since,
        note: ' near the market ',
      );

      final data = (await db.doc('users/u1/cats/1').get()).data()!;
      expect(data['status'], 'missing');
      expect(data['statusSince'], Timestamp.fromDate(since));
      expect(data['statusNote'], 'near the market');
      expect(data['name'], 'Ninja');
      final c = (await repo.watchCats().first).single;
      expect(c.status, CatStatus.missing);
      expect(c.statusSince, since);
      expect(c.statusNote, 'near the market');
      expect(c.encounters, hasLength(1));
    });

    test('an empty note is not stored', () async {
      await repo.addCat(cat('1', 'Ninja', [1000]));
      await repo.setStatus('1', CatStatus.found, since: since);
      final data = (await db.doc('users/u1/cats/1').get()).data()!;
      expect(data.containsKey('statusNote'), isFalse);
    });

    test('status moves on and back to normal removes every field', () async {
      await repo.addCat(cat('1', 'Ninja', [1000]));
      await repo.setStatus('1', CatStatus.missing, since: since, note: 'a');
      await repo.setStatus('1', CatStatus.found, since: since);
      expect((await repo.watchCats().first).single.status, CatStatus.found);
      await repo.setStatus('1', CatStatus.known);

      final data = (await db.doc('users/u1/cats/1').get()).data()!;
      expect(data.keys.toSet(), {'name', 'updatedAt'});
    });

    test('renaming keeps the status', () async {
      await repo.addCat(cat('1', 'Ciccio', [1000]));
      await repo.setStatus('1', CatStatus.remembered, since: since, note: 'x');
      await repo.renameCat('1', 'Ninja');

      final c = (await repo.watchCats().first).single;
      expect(c.name, 'Ninja');
      expect(c.status, CatStatus.remembered);
      expect(c.statusNote, 'x');
    });


    test('a cat added with a status writes it', () async {
      await repo.addCat(
        cat('1', 'Saibo', [
          1000,
        ]).withStatus(CatStatus.remembered, since: since, note: 'x'),
      );
      expect(
        (await repo.watchCats().first).single.status,
        CatStatus.remembered,
      );
    });
  });
}
