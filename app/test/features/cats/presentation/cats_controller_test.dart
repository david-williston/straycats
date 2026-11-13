import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/application/fake_photo_uploader.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_photo_repository.dart';
import 'package:straycats/src/features/cats/domain/encounter_type.dart';
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
            const Sighting(catId: '1', type: EncounterType.fed),
          );

      final (catId, encounter) = repo.addedEncounters.single;
      expect(catId, '1');
      expect(encounter.id, '9000');
      expect(encounter.photoId, '9000');
      expect(encounter.type, EncounterType.fed);
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
      expect(ninja.encounters.single.type, isNull);
      expect(uploader.enqueued, ['9000']);
    });
  });

  group('MeetCatController', () {
    test('takes a photo from the camera', () async {
      final photos = FakePhotoRepository(nextPhoto: File('/cats/9000.jpg'));
      final container = makeContainer(photos: photos);

      final photo = await container
          .read(meetCatControllerProvider.notifier)
          .takePhoto();

      expect(photo!.path, '/cats/9000.jpg');
    });

    test('a cancelled camera gives null', () async {
      final container = makeContainer(photos: FakePhotoRepository());

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
