import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/app.dart';
import 'package:straycats/src/features/cats/data/cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_photo_repository.dart';
import 'package:straycats/src/features/cats/data/photo_repository.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/encounter.dart';
import 'package:straycats/src/features/settings/data/fake_language_repository.dart';
import 'package:straycats/src/features/settings/data/language_repository.dart';

/// A cat with one encounter per time (milliseconds since the epoch).
Cat cat(String id, String name, List<int> times) => Cat(
  id: id,
  name: name,
  encounters: [
    for (final t in times)
      Encounter(
        id: '$t',
        photo: '$t.jpg',
        time: DateTime.fromMillisecondsSinceEpoch(t),
      ),
  ],
);

/// A container with the fakes, for testing controllers without widgets.
ProviderContainer makeContainer({
  FakeCatRepository? cats,
  FakePhotoRepository? photos,
  FakeLanguageRepository? language,
}) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      catRepositoryProvider.overrideWithValue(cats ?? FakeCatRepository()),
      photoRepositoryProvider.overrideWithValue(
        photos ?? FakePhotoRepository(nextPhoto: File('/cats/9000.jpg')),
      ),
      languageRepositoryProvider.overrideWithValue(
        language ?? FakeLanguageRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Shows the app on a phone-sized screen, with the fakes in place of the
/// device's storage and camera.
Future<void> pumpApp(
  WidgetTester tester, {
  required FakeCatRepository cats,
  FakePhotoRepository? photos,
  FakeLanguageRepository? language,
  Locale? locale,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        catRepositoryProvider.overrideWithValue(cats),
        photoRepositoryProvider.overrideWithValue(
          photos ?? FakePhotoRepository(nextPhoto: File('/cats/9000.jpg')),
        ),
        languageRepositoryProvider.overrideWithValue(
          language ?? FakeLanguageRepository(),
        ),
      ],
      child: StrayCatsApp(locale: locale),
    ),
  );
}
