import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:straycats/src/features/auth/application/account_providers.dart';
import 'package:straycats/src/features/cats/data/cats_folder.dart';
import 'package:straycats/src/features/cats/data/device_photo_repository.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_place_service.dart';
import 'package:straycats/src/features/cats/data/firestore_cat_repository.dart';
import 'package:straycats/src/features/cats/data/coarse_guard.dart';
import 'package:straycats/src/features/cats/data/image_picker_service.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/encounter.dart';
import 'package:straycats/src/features/cats/domain/sighting.dart';
import 'package:straycats/src/features/cats/presentation/cats_controller.dart';
import 'package:straycats/src/features/cats/presentation/meet_cat_controller.dart';
import 'package:straycats/src/features/places/data/place_service.dart';
import 'package:straycats/src/features/places/domain/coarse_area.dart';
import 'package:straycats/src/features/places/domain/geohash.dart';
import 'package:straycats/src/features/places/domain/place.dart';
import 'package:straycats/src/features/places/presentation/place_map.dart';
import 'package:straycats/src/localization/app_localizations.dart';

import '../../helpers.dart';

class _Picker implements ImagePickerService {
  _Picker(this.path);
  final String path;
  @override
  Future<String?> takePhoto() async => path;
}

const _lat = 19.4326, _lng = -99.1332;

void main() {
  group('geohash', () {
    test('encodes known points', () {
      expect(encodeGeohash(57.64911, 10.40744), 'u4pruy');
      expect(encodeGeohash(42.605, -5.603, precision: 5), 'ezs42');
      expect(encodeGeohash(-25.382708, -49.265506, precision: 8), '6gkzwgjz');
    });

    test('the centre of a cell is inside it and is not the input', () {
      final c = decodeGeohashCenter(encodeGeohash(_lat, _lng));
      expect(encodeGeohash(c.lat, c.lng), encodeGeohash(_lat, _lng));
      expect(c.lat == _lat && c.lng == _lng, isFalse);
      // A precision-6 cell is about 0.0055 x 0.011 degrees.
      expect((c.lat - _lat).abs(), lessThan(0.0055));
      expect((c.lng - _lng).abs(), lessThan(0.011));
    });
  });

  group('CoarseArea', () {
    test('accepts 1 to 6 geohash characters', () {
      expect(CoarseArea.fromGeohash('9g3q4k').geohash, '9g3q4k');
      expect(CoarseArea.fromGeohash('9g').geohash, '9g');
      expect(CoarseArea.fromPosition(_lat, _lng).geohash.length, 6);
    });

    test('rejects precision 7 and more, empty, and bad characters', () {
      for (final bad in [
        '9g3q4kx',
        '9g3q4k2m',
        '',
        '9g3q4a',
        '9G3Q4K',
        '9g3q4!',
        'ilo0aa',
      ]) {
        expect(
          () => CoarseArea.fromGeohash(bad),
          throwsFormatException,
          reason: bad,
        );
        expect(CoarseArea.tryParse(bad), isNull, reason: bad);
      }
    });
  });

  group('neighbourhood from a geocoder', () {
    const full = Placemark(
      name: '12 Calle Falsa',
      street: '12 Calle Falsa',
      thoroughfare: 'Calle Falsa',
      subThoroughfare: '12',
      postalCode: '06700',
      subLocality: 'Rinconada',
      locality: 'Ciudad de Mexico',
      administrativeArea: 'CDMX',
      country: 'Mexico',
    );

    test('uses the sub-locality, else the locality, and nothing else', () {
      expect(neighbourhoodFrom([full]), 'Rinconada');
      expect(
        neighbourhoodFrom([
          const Placemark(
            street: '1 Main St',
            locality: 'Oakland',
            postalCode: '94601',
          ),
        ]),
        'Oakland',
      );
      expect(
        neighbourhoodFrom([
          const Placemark(street: '1 Main St', postalCode: '1'),
        ]),
        isNull,
      );
      expect(neighbourhoodFrom(const []), isNull);
    });

    test('never carries street data and is at most 80 characters', () {
      final n = neighbourhoodFrom([full])!;
      for (final s in ['Falsa', '12', '06700']) {
        expect(n.contains(s), isFalse);
      }
      final long = neighbourhoodFrom([Placemark(subLocality: 'x' * 200)])!;
      expect(long.length, 80);
      expect(
        Place(
          area: CoarseArea.fromGeohash('9g3q4k'),
          neighbourhood: ' ${'y' * 90} ',
        ).neighbourhood!.length,
        80,
      );
    });
  });

  group('the coarse guard', () {
    Map<String, dynamic> ok() => {
      'catId': 'c',
      'photoId': 'p',
      'takenAt': DateTime(2025).toString(),
      'area': '9g3q4k',
      'neighbourhood': 'Rinconada',
      'conditions': ['thin'],
    };

    test('lets a clean map through', () {
      assertCoarse(ok());
      assertCoarse(
        {...ok()}
          ..remove('area')
          ..remove('neighbourhood'),
      );
    });

    test(
      'refuses GeoPoints, lat/lng fields, long areas, pairs and strangers',
      () {
        final bad = <Map<String, dynamic>>[
          {...ok(), 'where': const GeoPoint(_lat, _lng)},
          {...ok(), 'area': const GeoPoint(_lat, _lng)},
          {...ok(), 'lat': _lat, 'lng': _lng},
          {...ok(), 'latitude': _lat},
          {...ok(), 'area': '9g3q4kx'},
          {...ok(), 'area': '9g3q4a'},
          {...ok(), 'area': 123456},
          {...ok(), 'neighbourhood': 'x' * 81},
          {...ok(), 'neighbourhood': 5},
          {
            ...ok(),
            'note': {'lat': 1},
          },
          {
            ...ok(),
            'care': [_lat, _lng],
          },
        ];
        for (final m in bad) {
          expect(
            () => assertCoarse(m),
            throwsA(isA<CoarseGuardException>()),
            reason: '$m',
          );
        }
      },
    );

    test('the repository refuses to send such a map', () async {
      final db = FakeFirebaseFirestore();
      final repo = FirestoreCatRepository(db, 'u1');
      for (final extra in <Map<String, dynamic>>[
        {'where': const GeoPoint(_lat, _lng)},
        {'lat': _lat, 'lng': _lng},
        {'area': '9g3q4kx'},
      ]) {
        await expectLater(
          repo.writeEncounterMap('e1', {
            'catId': 'c',
            'photoId': 'e1',
            'takenAt': Timestamp.now(),
            ...extra,
          }),
          throwsA(isA<CoarseGuardException>()),
        );
      }
      expect((await db.collection('users/u1/encounters').get()).docs, isEmpty);
    });

    test(
      'the repository writes only area and neighbourhood for a place',
      () async {
        final db = FakeFirebaseFirestore();
        final repo = FirestoreCatRepository(db, 'u1');
        final e = Encounter(
          id: '1',
          photoId: '1',
          time: DateTime.fromMillisecondsSinceEpoch(1000),
          place: Place(
            area: CoarseArea.fromPosition(_lat, _lng),
            neighbourhood: 'Rinconada',
          ),
        );
        await repo.addCat(Cat(id: '1', name: 'N', encounters: [e]));
        var data = (await db.doc('users/u1/encounters/1').get()).data()!;
        expect(data['area'], encodeGeohash(_lat, _lng));
        expect(data['neighbourhood'], 'Rinconada');
        expect(data.values.whereType<GeoPoint>(), isEmpty);
        expect(data.keys, isNot(containsAll(['lat', 'lng'])));

        // Read back, and clear it.
        final cats = await repo.fetchCats();
        expect(cats.single.encounters.single.place, e.place);
        await repo.updateEncounter('1', e.withPlace(null));
        data = (await db.doc('users/u1/encounters/1').get()).data()!;
        expect(data.containsKey('area'), isFalse);
        expect(data.containsKey('neighbourhood'), isFalse);
      },
    );
  });

  group('capturing a place', () {
    test('location denied: the encounter is saved without place', () async {
      final repo = FakeCatRepository();
      final container = makeContainer(cats: repo, places: FakePlaceService());
      final sub = container.listen(catsControllerProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(catsControllerProvider.future);
      final photo = File('/cats/5000.jpg');
      container.read(placeCaptureProvider).start(photo);

      await container
          .read(catsControllerProvider.notifier)
          .recordSighting(photo, const Sighting(name: 'Ninja'));

      expect(repo.added.single.encounters.single.place, isNull);
    });

    test('permission granted: area and neighbourhood only; coordinates are never persisted', () async {
      final dir = Directory.systemTemp.createTempSync('cats');
      addTearDown(() => dir.deleteSync(recursive: true));
      final shot = File('${dir.path}/camera.jpg')..writeAsBytesSync([7]);
      final db = FakeFirebaseFirestore();
      final places = FakePlaceService(
        fix: (lat: _lat, lng: _lng),
        name: 'Rinconada',
      );
      final photos = DevicePhotoRepository(
        CatsFolder(dir: () async => dir),
        _Picker(shot.path),
      );
      // Real Firestore repository (over the fake) and real photo store.
      final real = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          ...fakeOverrides(
            places: places,
            db: db,
            cats: FirestoreCatRepository(db, 'test-uid'),
            photos: photos,
          ),
        ],
      );
      addTearDown(real.dispose);
      real.listen(catsControllerProvider, (_, _) {});
      real.listen(signedInProvider, (_, _) {});
      await real.read(accountProvider.future);
      await real.read(catsControllerProvider.future);

      final photo = (await real
          .read(meetCatControllerProvider.notifier)
          .takePhoto())!;
      await real
          .read(catsControllerProvider.notifier)
          .recordSighting(photo, const Sighting(name: 'Ninja'));
      await pumpEventQueue();

      final docs =
          (await db.collection('users/test-uid/encounters').get()).docs;
      final data = docs.single.data();
      expect(data['area'], encodeGeohash(_lat, _lng));
      expect(data['neighbourhood'], 'Rinconada');
      // Nothing anywhere holds the position: not the document, not a file.
      final everything = StringBuffer(db.dump());
      for (final f in dir.listSync(recursive: true).whereType<File>()) {
        everything.write(f.path);
        everything.write(String.fromCharCodes(f.readAsBytesSync()));
      }
      final text = everything.toString();
      for (final s in ['19.43', '99.13', '19.4326', '99.1332']) {
        expect(text.contains(s), isFalse, reason: s);
      }
      expect(data.values.whereType<GeoPoint>(), isEmpty);
    });

    test(
      'remove place clears area and neighbourhood, keeps the rest',
      () async {
        final e = Encounter(
          id: '1000',
          photoId: '1000',
          time: DateTime.fromMillisecondsSinceEpoch(1000),
          place: Place(
            area: CoarseArea.fromGeohash('9g3q4k'),
            neighbourhood: 'Rinconada',
          ),
        );
        final repo = FakeCatRepository([
          Cat(id: '1', name: 'Ciccio', encounters: [e]),
        ]);
        final container = makeContainer(cats: repo);
        final sub = container.listen(catsControllerProvider, (_, _) {});
        addTearDown(sub.close);
        await container.read(catsControllerProvider.future);

        await container
            .read(catsControllerProvider.notifier)
            .removePlace('1', e);

        final (_, saved) = repo.updated.single;
        expect(saved.place, isNull);
        expect(saved.id, e.id);
        expect(saved.time, e.time);
      },
    );
  });

  testWidgets(
    'the circle is centred on the geohash cell, not on the input point',
    (tester) async {
      final area = CoarseArea.fromPosition(_lat, _lng);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PlaceMap(areas: [area], tileProvider: _BlankTiles()),
          ),
        ),
      );
      final layer = tester.widget<CircleLayer>(find.byType(CircleLayer));
      final circle = layer.circles.single;
      final cell = decodeGeohashCenter(area.geohash);
      expect(circle.point.latitude, cell.lat);
      expect(circle.point.longitude, cell.lng);
      expect(
        circle.point.latitude == _lat && circle.point.longitude == _lng,
        isFalse,
      );
      expect(circle.radius, 1000);
      expect(circle.useRadiusInMeter, isTrue);
      // No pin.
      expect(find.byType(MarkerLayer), findsNothing);
    },
  );

  testWidgets(
    'the cat card shows the neighbourhood on the encounter and in Seen around',
    (tester) async {
      final e = Encounter(
        id: '1000',
        photoId: '1000',
        time: DateTime.fromMillisecondsSinceEpoch(1000),
        place: Place(
          area: CoarseArea.fromGeohash('9g3q4k'),
          neighbourhood: 'Rinconada',
        ),
      );
      await pumpApp(
        tester,
        cats: FakeCatRepository([
          Cat(id: '1', name: 'Ciccio', encounters: [e]),
        ]),
      );
      await tester.tap(find.text('Ciccio'));
      await tester.pumpAndSettle();

      expect(find.text('Seen around Rinconada'), findsOneWidget);
      expect(find.text('Rinconada'), findsOneWidget);

      await tester.tap(find.text('Rinconada')); // opens the edit sheet
      await tester.pumpAndSettle();
      expect(find.text('Around Rinconada (approx. 1 km)'), findsOneWidget);
      expect(find.text('Remove place'), findsOneWidget);
    },
  );

  testWidgets('Remove place in the edit sheet clears the place', (
    tester,
  ) async {
    final e = Encounter(
      id: '1000',
      photoId: '1000',
      time: DateTime.fromMillisecondsSinceEpoch(1000),
      place: Place(
        area: CoarseArea.fromGeohash('9g3q4k'),
        neighbourhood: 'Rinconada',
      ),
    );
    final repo = FakeCatRepository([
      Cat(id: '1', name: 'Ciccio', encounters: [e]),
    ]);
    await pumpApp(tester, cats: repo);
    await tester.tap(find.text('Ciccio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rinconada'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove place'));
    await tester.pumpAndSettle();

    expect(repo.updated.single.$2.place, isNull);
    expect(find.text('Seen around Rinconada'), findsNothing);
  });
}

/// One transparent pixel for every tile, so tests never touch the network.
class _BlankTiles extends TileProvider {
  static final _png = Uint8List.fromList(const [
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(_png);
}
