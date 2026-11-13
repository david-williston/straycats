import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_photo_repository.dart';
import 'package:straycats/src/features/cats/domain/encounter_type.dart';
import 'package:straycats/src/features/cats/domain/sighting.dart';
import 'package:straycats/src/features/cats/presentation/cats_controller.dart';
import 'package:straycats/src/features/cats/presentation/meet_cat_controller.dart';

import '../../../helpers.dart';

void main() {
  group('CatsController', () {
    test('loads the cats from the repository', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ciccio', [1000]),
      ]);
      final container = makeContainer(cats: repo);

      final cats = await container.read(catsControllerProvider.future);

      expect(cats.single.name, 'Ciccio');
    });

    test('a failed load is an error, and nothing is saved', () async {
      final repo = FakeCatRepository()..loadError = StateError('no folder');
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
      expect(repo.saved, isNull);
    });

    test('rename changes the name and saves', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ciccio', [1000]),
        cat('2', '', [2000]),
      ]);
      final container = makeContainer(cats: repo);
      await container.read(catsControllerProvider.future);

      await container
          .read(catsControllerProvider.notifier)
          .rename('2', 'Ninja');

      expect(container.read(catsControllerProvider).value!.map((c) => c.name), [
        'Ciccio',
        'Ninja',
      ]);
      expect(repo.saved!.map((c) => c.name), ['Ciccio', 'Ninja']);
    });

    test('rename to the same name saves nothing', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ciccio', [1000]),
      ]);
      final container = makeContainer(cats: repo);
      await container.read(catsControllerProvider.future);

      await container
          .read(catsControllerProvider.notifier)
          .rename('1', 'Ciccio');

      expect(repo.saved, isNull);
    });

    test('a sighting of an existing cat adds an encounter', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ciccio', [1000]),
        cat('2', 'Saibo', [2000]),
      ]);
      final container = makeContainer(cats: repo);
      await container.read(catsControllerProvider.future);

      await container
          .read(catsControllerProvider.notifier)
          .recordSighting(
            File('/cats/9000.jpg'),
            const Sighting(catId: '1', type: EncounterType.fed),
          );

      final ciccio = repo.saved!.firstWhere((c) => c.id == '1');
      expect(ciccio.encounters, hasLength(2));
      expect(ciccio.latest!.photo, '9000.jpg');
      expect(ciccio.latest!.type, EncounterType.fed);
      expect(ciccio.latest!.time, DateTime.fromMillisecondsSinceEpoch(9000));
      expect(
        repo.saved!.firstWhere((c) => c.id == '2').encounters,
        hasLength(1),
      );
      expect(container.read(catsControllerProvider).value, repo.saved);
    });

    test('a sighting without a cat creates one with its name', () async {
      final repo = FakeCatRepository([
        cat('1', 'Ciccio', [1000]),
      ]);
      final container = makeContainer(cats: repo);
      await container.read(catsControllerProvider.future);

      await container
          .read(catsControllerProvider.notifier)
          .recordSighting(
            File('/cats/9000.jpg'),
            const Sighting(name: 'Ninja'),
          );

      expect(repo.saved, hasLength(2));
      final ninja = repo.saved!.firstWhere((c) => c.name == 'Ninja');
      expect(ninja.id, '9000');
      expect(ninja.encounters.single.photo, '9000.jpg');
      expect(ninja.encounters.single.type, isNull);
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
