import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/auth/data/fake_auth_repository.dart';
import 'package:straycats/src/features/cats/application/fake_photo_uploader.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_photo_repository.dart';
import 'package:straycats/src/features/cats/data/fake_place_service.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/places/domain/geohash.dart';
import 'package:straycats/src/features/cats/domain/encounter_details.dart';
import 'package:straycats/src/features/cats/presentation/cat_tile.dart';

import '../../../helpers.dart';

Future<void> tapChip(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pump();
}

void main() {
  _suggestionTests();
  testWidgets('shows the title and empty state', (tester) async {
    await pumpApp(tester, cats: FakeCatRepository());
    await tester.pump();

    expect(find.text('StrayCats'), findsOneWidget);
    expect(
      find.text('No cats yet. Tap the camera to meet one.'),
      findsOneWidget,
    );
  });

  testWidgets('signed out: just the welcome screen, no camera', (tester) async {
    final auth = FakeAuthRepository(uid: 'test-uid');
    await pumpApp(tester, cats: FakeCatRepository(), auth: auth);
    await tester.pump();

    expect(find.byIcon(Icons.photo_camera), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byIcon(Icons.account_circle_outlined), findsNothing);
    expect(find.text('StrayCats'), findsOneWidget);
    expect(find.text("Let's go meet some cats."), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);

    // The button signs in directly, without the account sheet.
    await tester.tap(find.text('Sign in with Google'));
    await tester.pumpAndSettle();
    expect(auth.googleSignIns, 1);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('says so when the cats cannot be loaded', (tester) async {
    final repo = FakeCatRepository()..watchError = StateError('no cats');
    await pumpApp(tester, cats: repo);
    await tester.pump();

    expect(find.text('Could not load your cats.'), findsOneWidget);
    expect(repo.wroteAnything, isFalse);
  });

  testWidgets('shows one tile per cat and saves a new name', (tester) async {
    final repo = FakeCatRepository([
      cat('1', 'Ciccio', [1000, 3000]),
      cat('2', '', [2000]),
    ]);
    await pumpApp(tester, cats: repo);
    await tester.pump();

    expect(find.byType(CatTile), findsNWidgets(2));
    expect(find.text('Ciccio'), findsOneWidget);
    expect(find.text('No name yet'), findsOneWidget);

    await tester.tap(find.text('No name yet'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ninja');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Ninja'), findsOneWidget);
    expect(repo.renamed, [('2', 'Ninja')]);
  });

  testWidgets('a new photo of an existing cat adds an encounter', (
    tester,
  ) async {
    final repo = FakeCatRepository([
      cat('1', 'Ciccio', [1000]),
      cat('2', 'Saibo', [2000]),
    ]);
    final photos = FakePhotoRepository(nextPhoto: File('/cats/9000.jpg'));
    final uploader = FakePhotoUploader();
    await pumpApp(tester, cats: repo, photos: photos, uploader: uploader);
    await tester.pump();

    await tester.tap(find.byTooltip('Meet a cat'));
    await tester.pumpAndSettle();

    expect(find.text('Who is this?'), findsOneWidget);
    expect(find.text('Is it one of these?'), findsOneWidget);
    expect(find.text('Ciccio'), findsOneWidget);
    expect(find.text('Saibo'), findsOneWidget);
    expect(find.text('New cat'), findsOneWidget);

    await tester.tap(find.text('Ciccio'));
    await tester.pumpAndSettle();
    await tapChip(tester, 'Fed it');
    await tapChip(tester, 'Eating');
    await tapChip(tester, 'Thin');
    await tapChip(tester, 'Limping');
    await tapChip(tester, 'Limping'); // chosen, then unchosen
    await tester.enterText(find.byType(TextField), 'Hungry girl');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('StrayCats'), findsOneWidget);
    expect(find.byType(CatTile), findsNWidgets(2));
    expect(repo.added, isEmpty);
    final (catId, encounter) = repo.addedEncounters.single;
    expect(catId, '1');
    final ciccio = repo.cats.firstWhere((c) => c.id == '1');
    expect(ciccio.encounters, hasLength(2));
    expect(ciccio.latest!.photoId, '9000');
    expect(encounter.details.activity, Activity.eating);
    expect(encounter.details.conditions, [Condition.thin]);
    expect(encounter.details.care, [Care.fed]);
    expect(encounter.details.note, 'Hungry girl');
    expect(uploader.enqueued, ['9000']);
    expect(photos.discarded, isEmpty);
  });

  testWidgets('New cat creates a cat with its name', (tester) async {
    final repo = FakeCatRepository([
      cat('1', 'Ciccio', [1000]),
    ]);
    await pumpApp(tester, cats: repo);
    await tester.pump();

    await tester.tap(find.byTooltip('Meet a cat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New cat'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Name (optional)'),
      ' Ninja ',
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.byType(CatTile), findsNWidgets(2));
    expect(find.text('Ninja'), findsOneWidget);
    final ninja = repo.added.single;
    expect(ninja.name, 'Ninja');
    expect(ninja.id, '9000');
    expect(ninja.encounters.single.photoId, '9000');
    expect(ninja.encounters.single.details.isEmpty, isTrue);
  });

  testWidgets('backing out of Who is this? discards the photo', (tester) async {
    final repo = FakeCatRepository([
      cat('1', 'Ciccio', [1000]),
    ]);
    final photos = FakePhotoRepository(nextPhoto: File('/cats/9000.jpg'));
    await pumpApp(tester, cats: repo, photos: photos);
    await tester.pump();

    await tester.tap(find.byTooltip('Meet a cat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ciccio'));
    await tester.pumpAndSettle();
    await tester.pageBack(); // back to the choice of cat
    await tester.pumpAndSettle();
    expect(find.text('Is it one of these?'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(photos.discarded.single.path, '/cats/9000.jpg');
    expect(repo.wroteAnything, isFalse);
  });

  testWidgets('a cancelled camera changes nothing', (tester) async {
    final repo = FakeCatRepository([
      cat('1', 'Ciccio', [1000]),
    ]);
    await pumpApp(tester, cats: repo, photos: FakePhotoRepository());
    await tester.pump();

    await tester.tap(find.byTooltip('Meet a cat'));
    await tester.pumpAndSettle();

    expect(find.text('Who is this?'), findsNothing);
    expect(repo.wroteAnything, isFalse);
  });

  testWidgets('follows the language: Spanish', (tester) async {
    await pumpApp(
      tester,
      cats: FakeCatRepository(),
      locale: const Locale('es'),
    );
    await tester.pump();
    expect(
      find.text('Aún no hay gatos. Toca la cámara para conocer a uno.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Conocer a un gato'));
    await tester.pumpAndSettle();
    expect(find.text('¿Quién es?'), findsOneWidget);
    await tester.tap(find.text('Gato nuevo'));
    await tester.pumpAndSettle();
    expect(find.text('Le di de comer'), findsOneWidget);
  });

  testWidgets('dates follow the language', (tester) async {
    final repo = FakeCatRepository([
      cat('1', 'Ciccio', [DateTime(2026, 11, 7).millisecondsSinceEpoch]),
    ]);
    await pumpApp(tester, cats: repo, locale: const Locale('es'));
    await tester.pump();
    await tester.tap(find.text('Ciccio'));
    await tester.pumpAndSettle();
    expect(find.text('7 nov 2026'), findsOneWidget);
  });
}

// Suggestion flow: the new photo is taken at a fix whose cell matches Ciccio.
const _lat = 37.7749, _lng = -122.4194;

void _suggestionTests() {
  final here = encodeGeohash(_lat, _lng);
  List<Cat> cats() => [
    catAt('1', 'Ciccio', [(1000, here)]),
    catAt('2', 'Saibo', [(2000, 'u4pruy')]),
  ];

  Future<void> meet(WidgetTester tester, {Locale? locale}) async {
    await pumpApp(
      tester,
      cats: FakeCatRepository(cats()),
      places: FakePlaceService(fix: (lat: _lat, lng: _lng)),
      locale: locale,
    );
    await tester.pump();
    await tester.tap(
      find.byTooltip(locale == null ? 'Meet a cat' : 'Conocer a un gato'),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('suggests the cat met here, with the reason', (tester) async {
    await meet(tester);
    expect(find.text('This might be Ciccio. Is it?'), findsOneWidget);
    expect(find.text('Seen in this area before'), findsOneWidget);
    expect(find.text('Is it one of these?'), findsNothing);
    expect(find.text('New cat'), findsOneWidget);
  });

  testWidgets('Yes selects the suggested cat', (tester) async {
    await meet(tester);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.text('Ciccio'), findsOneWidget); // title of the details step
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Name (optional)'), findsNothing);
  });

  testWidgets('No dismisses it and lists the other cats', (tester) async {
    await meet(tester);
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    expect(find.text('This might be Ciccio. Is it?'), findsNothing);
    expect(find.text('Is it one of these?'), findsOneWidget);
    expect(find.text('Saibo'), findsOneWidget);
    expect(find.text('Ciccio'), findsNothing);
    expect(find.text('New cat'), findsOneWidget);
  });

  testWidgets('Not sure shows every cat, none chosen', (tester) async {
    await meet(tester);
    await tester.tap(find.text('Not sure'));
    await tester.pumpAndSettle();
    expect(find.text('Is it one of these?'), findsOneWidget);
    expect(find.text('Ciccio'), findsOneWidget);
    expect(find.text('Saibo'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('no place: no suggestion, just the list', (tester) async {
    await pumpApp(tester, cats: FakeCatRepository(cats()));
    await tester.pump();
    await tester.tap(find.byTooltip('Meet a cat'));
    await tester.pumpAndSettle();
    expect(find.textContaining('This might be'), findsNothing);
    expect(find.text('Is it one of these?'), findsOneWidget);
  });

  testWidgets('the suggestion is in Spanish', (tester) async {
    await meet(tester, locale: const Locale('es'));
    expect(find.text('Podría ser Ciccio. ¿Es este?'), findsOneWidget);
    expect(find.text('Visto antes en esta zona'), findsOneWidget);
    expect(find.text('Sí'), findsOneWidget);
    expect(find.text('No estoy seguro'), findsOneWidget);
  });
}
