import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/auth/application/account_providers.dart';
import 'package:straycats/src/features/auth/data/fake_auth_repository.dart';
import 'package:straycats/src/features/cats/application/fake_photo_uploader.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_photo_repository.dart';
import 'package:straycats/src/features/cats/domain/encounter_details.dart';
import 'package:straycats/src/features/cats/domain/sighting.dart';
import 'package:straycats/src/features/cats/presentation/cats_controller.dart';
import 'package:straycats/src/features/cats/presentation/meet_cat_controller.dart';

import '../../../helpers.dart';

void main() {
  group('CatsController', () {
    test('follows the cats from the repository', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ciccio', [1000]),
      ]);
      final container = makeContainer(cats: repo);
      final sub = container.listen(catsControllerProvider, (_, _) {});

      final cats = await container.read(catsControllerProvider.future);
      expect(cats.single.name, 'Ciccio');

      await repo.addCat(cat('2', 'Saibo', [2000]));
      await pumpEventQueue();
      expect(sub.read().value!.map((c) => c.name), ['Ciccio', 'Saibo']);
    });

    test('a failed stream is an error, and nothing is written', () async {
      final repo = FakeCatRepository()..watchError = StateError('no cats');
      final container = makeContainer(cats: repo);
      final sub = container.listen(catsControllerProvider, (_, _) {});

      await expectLater(
        container.read(catsControllerProvider.future),
        throwsStateError,
      );
      await container
          .read(catsControllerProvider.notifier)
          .rename('1', 'Ninja');

      expect(sub.read().hasError, isTrue);
      expect(repo.wroteAnything, isFalse);
    });

    test('rename changes the name through the repository', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ciccio', [1000]),
        cat('2', '', [2000]),
      ]);
      final container = makeContainer(cats: repo);
      final sub = container.listen(catsControllerProvider, (_, _) {});
      await container.read(catsControllerProvider.future);

      await container
          .read(catsControllerProvider.notifier)
          .rename('2', 'Ninja');
      await pumpEventQueue();

      expect(repo.renamed, [('2', 'Ninja')]);
      expect(sub.read().value!.map((c) => c.name), ['Ciccio', 'Ninja']);
    });

    test('rename to the same name writes nothing', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ciccio', [1000]),
      ]);
      final container = makeContainer(cats: repo);
      container.listen(catsControllerProvider, (_, _) {});
      await container.read(catsControllerProvider.future);

      await container
          .read(catsControllerProvider.notifier)
          .rename('1', 'Ciccio');

      expect(repo.wroteAnything, isFalse);
    });

    test('a sighting of an existing cat adds an encounter', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ciccio', [1000]),
        cat('2', 'Saibo', [2000]),
      ]);
      final uploader = FakePhotoUploader();
      final container = makeContainer(cats: repo, uploader: uploader);
      container.listen(catsControllerProvider, (_, _) {});
      await container.read(catsControllerProvider.future);

      await container
          .read(catsControllerProvider.notifier)
          .recordSighting(
            File('/cats/9000.jpg'),
            const Sighting(
              catId: '1',
              details: EncounterDetails(
                activity: Activity.eating,
                care: [Care.fed],
                note: 'Hungry',
              ),
            ),
          );

      final (catId, encounter) = repo.addedEncounters.single;
      expect(catId, '1');
      expect(encounter.id, '9000');
      expect(encounter.photoId, '9000');
      expect(encounter.details.activity, Activity.eating);
      expect(encounter.details.care, [Care.fed]);
      expect(encounter.details.note, 'Hungry');
      expect(encounter.time, DateTime.fromMillisecondsSinceEpoch(9000));
      expect(repo.added, isEmpty);
      expect(uploader.enqueued, ['9000']);
    });

    test('a sighting without a cat creates one with its name', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ciccio', [1000]),
      ]);
      final uploader = FakePhotoUploader();
      final container = makeContainer(cats: repo, uploader: uploader);
      container.listen(catsControllerProvider, (_, _) {});
      await container.read(catsControllerProvider.future);

      await container
          .read(catsControllerProvider.notifier)
          .recordSighting(
            File('/cats/9000.jpg'),
            const Sighting(name: 'Ninja'),
          );

      final ninja = repo.added.single;
      expect(ninja.name, 'Ninja');
      expect(ninja.id, '9000');
      expect(ninja.encounters.single.photoId, '9000');
      expect(ninja.encounters.single.details.isEmpty, isTrue);
      expect(uploader.enqueued, ['9000']);
    });
  });

  group('editing encounters', () {
    test('updateEncounter saves new details', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ciccio', [1000, 2000]),
      ]);
      final container = makeContainer(cats: repo);
      container.listen(catsControllerProvider, (_, _) {});
      final cats = await container.read(catsControllerProvider.future);

      final e = cats.single.encounters.first;
      await container
          .read(catsControllerProvider.notifier)
          .updateEncounter(
            '1',
            e.withDetails(const EncounterDetails(care: [Care.gaveWater])),
          );
      await pumpEventQueue();

      expect(repo.updated.single.$1, '1');
      final now = container.read(catsControllerProvider).value!.single;
      expect(now.encounters.first.details.care, [Care.gaveWater]);
      expect(now.encounters.last.details.isEmpty, isTrue);
    });

    test('deleting the last encounter keeps the cat', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ciccio', [1000]),
      ]);
      final container = makeContainer(cats: repo);
      container.listen(catsControllerProvider, (_, _) {});
      await container.read(catsControllerProvider.future);

      await container
          .read(catsControllerProvider.notifier)
          .deleteEncounter('1000');
      await pumpEventQueue();

      expect(repo.deleted, ['1000']);
      final cats = container.read(catsControllerProvider).value!;
      expect(cats.single.name, 'Ciccio');
      expect(cats.single.encounters, isEmpty);
    });
  });

  group('MeetCatController', () {
    test('takes a photo from the camera', () async {
      final photos = FakePhotoRepository(nextPhoto: File('/cats/9000.jpg'));
      final container = makeContainer(photos: photos);
      container.listen(signedInProvider, (_, _) {});
      await container.read(accountProvider.future);

      final photo = await container
          .read(meetCatControllerProvider.notifier)
          .takePhoto();

      expect(photo!.path, '/cats/9000.jpg');
    });

    test(
      'signed out, there is no photo and the camera is not opened',
      () async {
        final photos = FakePhotoRepository(nextPhoto: File('/cats/9000.jpg'));
        final container = makeContainer(
          photos: photos,
          auth: FakeAuthRepository(uid: 'test-uid'),
        );
        container.listen(signedInProvider, (_, _) {});
        await container.read(accountProvider.future);

        final photo = await container
            .read(meetCatControllerProvider.notifier)
            .takePhoto();

        expect(photo, isNull);
      },
    );

    test('a cancelled camera gives null', () async {
      final container = makeContainer(photos: FakePhotoRepository());
      container.listen(signedInProvider, (_, _) {});
      await container.read(accountProvider.future);

      expect(
        await container.read(meetCatControllerProvider.notifier).takePhoto(),
        isNull,
      );
    });

    test('discard throws the photo away', () async {
      final photos = FakePhotoRepository();
      final container = makeContainer(photos: photos);

      await container
          .read(meetCatControllerProvider.notifier)
          .discard(File('/cats/9000.jpg'));

      expect(photos.discarded.single.path, '/cats/9000.jpg');
    });
  });
}
