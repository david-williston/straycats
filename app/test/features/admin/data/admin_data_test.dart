import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/domain/life.dart';
import 'package:straycats/src/features/admin/data/is_admin.dart';
import 'package:straycats/src/features/admin/data/other_photo_cache.dart';
import 'package:straycats/src/features/admin/data/people_repository.dart';
import 'package:straycats/src/features/auth/data/auth_repository.dart';
import 'package:straycats/src/features/auth/data/fake_auth_repository.dart';
import 'package:straycats/src/features/cats/data/fake_photo_storage.dart';
import 'package:straycats/src/features/startup/application/app_startup.dart';

void main() {
  test('isAdminProvider follows the claim, fetched fresh', () async {
    Future<bool> read(FakeAuthRepository auth) async {
      final c = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          appStartupProvider.overrideWith((ref) async => 'u'),
        ],
      );
      addTearDown(c.dispose);
      return c.read(isAdminProvider.future);
    }

    final yes = FakeAuthRepository(uid: 'a', admin: true);
    expect(await read(yes), isTrue);
    expect(yes.adminChecks, [true]);
    expect(await read(FakeAuthRepository(uid: 'b')), isFalse);
  });

  group('FirestorePeopleRepository', () {
    test("lists profiles and reads one person's cats once", () async {
      final db = FakeFirebaseFirestore();
      await db.doc('users/u1').set({'createdAt': Timestamp(100, 0)});
      await db.doc('users/u2').set({'createdAt': Timestamp(200, 0)});
      await db.doc('users/u1/cats/1').set({'name': 'Ninja'});
      await db.doc('users/u1/encounters/1').set({
        'catId': '1',
        'photoId': '1',
        'takenAt': Timestamp(50, 0),
      });
      await db.doc('users/u1/events/7').set({
        'catId': '1',
        'type': 'died',
        'on': '2025-02',
        'createdAt': Timestamp(60, 0),
      });
      final repo = FirestorePeopleRepository(db);

      final people = await repo.listPeople();
      expect(people.map((p) => (p.uid, p.createdAt)), [
        ('u1', DateTime.fromMillisecondsSinceEpoch(100000)),
        ('u2', DateTime.fromMillisecondsSinceEpoch(200000)),
      ]);
      expect(
        people.first.createdAt,
        DateTime.fromMillisecondsSinceEpoch(100000),
      );

      final cats = await repo.catsOf('u1');
      expect(cats.single.name, 'Ninja');
      expect(cats.single.encounters.single.photoId, '1');
      expect(cats.single.life.state, LifeState.remembered);
      expect(cats.single.events.single.on.stored, '2025-02');
      expect(await repo.catsOf('u2'), isEmpty);
    });
  });

  group('OtherPhotoCache', () {
    late Directory dir;
    late FakePhotoStorage storage;
    late OtherPhotoCache cache;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('admin');
      storage = FakePhotoStorage();
      cache = OtherPhotoCache(() async => dir, storage);
    });
    tearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });

    test("downloads with the owner uid, into the owner's folder", () async {
      storage.remoteOwned['u1/7'] = [7];
      storage.remote['7'] = [9]; // the user's own photo with the same id

      final file = await cache.fileFor('u1', '7');

      expect(storage.downloadedOwned, ['u1/7']);
      expect(file!.path, '${dir.path}/u1/7.jpg');
      expect(file.readAsBytesSync(), [7]);
    });

    test("two people's photos with the same id do not collide", () async {
      storage.remoteOwned['u1/7'] = [1];
      storage.remoteOwned['u2/7'] = [2];

      expect((await cache.fileFor('u1', '7'))!.readAsBytesSync(), [1]);
      expect((await cache.fileFor('u2', '7'))!.readAsBytesSync(), [2]);
    });

    test(
      'a cached photo is not fetched again; clear empties the cache',
      () async {
        storage.remoteOwned['u1/7'] = [1];
        await cache.fileFor('u1', '7');
        await cache.fileFor('u1', '7');
        expect(storage.downloadedOwned, hasLength(1));

        await cache.clear();

        expect(dir.existsSync(), isFalse);
      },
    );

    test('a missing or failing photo gives null', () async {
      expect(await cache.fileFor('u1', '8'), isNull);
      storage.failWith = StateError('denied');
      expect(await cache.fileFor('u1', '9'), isNull);
    });
  });
}
