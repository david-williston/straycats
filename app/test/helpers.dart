import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/app.dart';
import 'package:straycats/src/features/cats/application/fake_photo_uploader.dart';
import 'package:straycats/src/features/cats/application/photo_uploader.dart';
import 'package:straycats/src/features/cats/data/cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_local_photo_cache.dart';
import 'package:straycats/src/features/cats/data/fake_photo_repository.dart';
import 'package:straycats/src/features/cats/data/local_photo_cache.dart';
import 'package:straycats/src/features/cats/data/photo_repository.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/encounter.dart';
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
  FakeCatRepository? cats,
  FakePhotoRepository? photos,
  FakeLanguageRepository? language,
  FakePhotoUploader? uploader,
}) => [
  appStartupProvider.overrideWith((ref) async => 'test-uid'),
  uidProvider.overrideWithValue('test-uid'),
  catRepositoryProvider.overrideWithValue(cats ?? FakeCatRepository()),
  photoRepositoryProvider.overrideWithValue(
    photos ?? FakePhotoRepository(nextPhoto: File('/cats/9000.jpg')),
  ),
  photoUploaderProvider.overrideWithValue(uploader ?? FakePhotoUploader()),
  localPhotoCacheProvider.overrideWithValue(FakeLocalPhotoCache()),
  languageRepositoryProvider.overrideWithValue(
    language ?? FakeLanguageRepository(),
  ),
];

/// A container with the fakes, for testing controllers without widgets.
ProviderContainer makeContainer({
  FakeCatRepository? cats,
  FakePhotoRepository? photos,
  FakeLanguageRepository? language,
  FakePhotoUploader? uploader,
}) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: fakeOverrides(
      cats: cats,
      photos: photos,
      language: language,
      uploader: uploader,
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
      ),
      child: StrayCatsApp(locale: locale),
    ),
  );
  await tester.pump(); // startup completes
  await tester.pump(); // the cats arrive
}
