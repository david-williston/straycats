import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/app.dart';
import 'package:straycats/src/features/admin/data/is_admin.dart';
import 'package:straycats/src/features/admin/data/other_photo_cache.dart';
import 'package:straycats/src/features/admin/data/people_repository.dart';
import 'package:straycats/src/features/auth/data/auth_repository.dart';
import 'package:straycats/src/features/auth/data/fake_auth_repository.dart';
import 'package:straycats/src/features/profile/data/profile_repository.dart';
import 'package:straycats/src/data/firebase_providers.dart';
import 'package:straycats/src/features/cats/application/fake_photo_uploader.dart';
import 'package:straycats/src/features/cats/application/photo_uploader.dart';
import 'package:straycats/src/features/cats/data/cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_local_photo_cache.dart';
import 'package:straycats/src/features/cats/data/fake_photo_repository.dart';
import 'package:straycats/src/features/cats/data/fake_photo_storage.dart';
import 'package:straycats/src/features/cats/data/local_photo_cache.dart';
import 'package:straycats/src/features/cats/data/offer_repository.dart';
import 'package:straycats/src/features/cats/data/photo_repository.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/encounter.dart';
import 'package:straycats/src/features/cats/data/fake_place_service.dart';
import 'package:straycats/src/features/places/data/place_service.dart';
import 'package:straycats/src/features/places/domain/coarse_area.dart';
import 'package:straycats/src/features/places/domain/place.dart';
import 'package:straycats/src/features/settings/data/fake_language_repository.dart';
import 'package:straycats/src/features/settings/data/language_repository.dart';
import 'package:straycats/src/features/startup/application/app_startup.dart';

/// A cat with one encounter per time (milliseconds since the epoch).
Cat cat(String id, String name, List<int> times) => Cat(
  id: id,
  name: name,
  encounters: [
    for (final t in times)
      Encounter(
        id: '$t',
        photoId: '$t',
        time: DateTime.fromMillisecondsSinceEpoch(t),
      ),
  ],
);

/// The overrides that put fakes in place of Firebase, the device's storage
/// and the camera. Startup is already done, as user `test-uid`.
List<Override> fakeOverrides({
  CatRepository? cats,
  PhotoRepository? photos,
  FakeLanguageRepository? language,
  FakePhotoUploader? uploader,
  FakeAuthRepository? auth,
  FakeFirebaseFirestore? db,
  OtherPhotoCache? otherPhotos,
  FakePlaceService? places,
  FakeOfferRepository? offers,
}) {
  final firestore = db ?? FakeFirebaseFirestore();
  // Signed in with Google by default: signed-out people cannot take photos.
  final fakeAuth =
      auth ?? FakeAuthRepository(uid: 'test-uid', email: 'test@example.com');
  return [
    authRepositoryProvider.overrideWithValue(fakeAuth),
    isAdminProvider.overrideWith((ref) async => fakeAuth.admin),
    firestoreProvider.overrideWithValue(firestore),
    profileRepositoryProvider.overrideWithValue(
      FirestoreProfileRepository(firestore),
    ),
    peopleRepositoryProvider.overrideWithValue(
      FirestorePeopleRepository(firestore),
    ),
    otherPhotoCacheProvider.overrideWithValue(
      otherPhotos ??
          OtherPhotoCache(
            // Nothing is there (and nothing is fetched), so clear() is a no-op.
            () async => Directory('/nonexistent/other-photos'),
            FakePhotoStorage(),
          ),
    ),
    appStartupProvider.overrideWith((ref) async => 'test-uid'),
    uidProvider.overrideWithValue('test-uid'),
    catRepositoryProvider.overrideWithValue(cats ?? FakeCatRepository()),
    placeServiceProvider.overrideWithValue(places ?? FakePlaceService()),
    photoRepositoryProvider.overrideWithValue(
      photos ?? FakePhotoRepository(nextPhoto: File('/cats/9000.jpg')),
    ),
    photoUploaderProvider.overrideWithValue(uploader ?? FakePhotoUploader()),
    localPhotoCacheProvider.overrideWithValue(FakeLocalPhotoCache()),
    offerRepositoryProvider.overrideWithValue(offers ?? FakeOfferRepository()),
    languageRepositoryProvider.overrideWithValue(
      language ?? FakeLanguageRepository(),
    ),
  ];
}

/// A container with the fakes, for testing controllers without widgets.
ProviderContainer makeContainer({
  FakeCatRepository? cats,
  FakePhotoRepository? photos,
  FakeLanguageRepository? language,
  FakePhotoUploader? uploader,
  FakeAuthRepository? auth,
  FakeFirebaseFirestore? db,
  OtherPhotoCache? otherPhotos,
  FakePlaceService? places,
  FakeOfferRepository? offers,
}) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: fakeOverrides(
      cats: cats,
      photos: photos,
      language: language,
      uploader: uploader,
      auth: auth,
      db: db,
      otherPhotos: otherPhotos,
      places: places,
      offers: offers,
    ),
  );
  addTearDown(container.dispose);
  return container;
}

/// Shows the app on a phone-sized screen, with the fakes in place of
/// Firebase, the device's storage and the camera, and startup done.
Future<void> pumpApp(
  WidgetTester tester, {
  required FakeCatRepository cats,
  FakePhotoRepository? photos,
  FakeLanguageRepository? language,
  FakePhotoUploader? uploader,
  FakeAuthRepository? auth,
  FakeFirebaseFirestore? db,
  OtherPhotoCache? otherPhotos,
  FakePlaceService? places,
  FakeOfferRepository? offers,
  Locale? locale,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: fakeOverrides(
        cats: cats,
        photos: photos,
        language: language,
        uploader: uploader,
        auth: auth,
        db: db,
        otherPhotos: otherPhotos,
        places: places,
        offers: offers,
      ),
      child: StrayCatsApp(locale: locale),
    ),
  );
  await tester.pump(); // startup completes
  await tester.pump(); // the cats arrive
}

/// A cat whose encounters are at the given (millis, geohash) pairs.
Cat catAt(String id, String name, List<(int, String?)> met) => Cat(
  id: id,
  name: name,
  encounters: [
    for (final (t, g) in met)
      Encounter(
        id: '$t',
        photoId: '$t',
        time: DateTime.fromMillisecondsSinceEpoch(t),
        place: g == null ? null : Place(area: CoarseArea.fromGeohash(g)),
      ),
  ],
);
