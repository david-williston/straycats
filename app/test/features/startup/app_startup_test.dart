import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/app.dart';
import 'package:straycats/src/data/firebase_providers.dart';
import 'package:straycats/src/features/auth/data/auth_repository.dart';
import 'package:straycats/src/features/auth/data/fake_auth_repository.dart';
import 'package:straycats/src/features/cats/application/cat_importer.dart';
import 'package:straycats/src/features/cats/application/fake_photo_uploader.dart';
import 'package:straycats/src/features/cats/application/photo_uploader.dart';
import 'package:straycats/src/features/cats/data/cats_folder.dart';
import 'package:straycats/src/features/cats/data/cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_local_photo_cache.dart';
import 'package:straycats/src/features/cats/data/legacy_cats_reader.dart';
import 'package:straycats/src/features/cats/data/local_photo_cache.dart';
import 'package:straycats/src/features/cats/data/photo_outbox.dart';
import 'package:straycats/src/features/cats/presentation/cats_page.dart';
import 'package:straycats/src/features/startup/application/app_startup.dart';

/// An importer whose result is chosen by the test; no disk work.
class _StubImporter extends CatImporter {
  _StubImporter(this.onRun)
    : super(
        CatsFolder(),
        LegacyCatsReader(CatsFolder()),
        PhotoOutbox(CatsFolder()),
      );

  Future<void> Function() onRun;
  int runs = 0;

  @override
  Future<void> run(CatRepository target) {
    runs++;
    return onRun();
  }
}

void main() {
  group('appStartup (real importer, temp folder)', () {
    late Directory dir;
    late FakeFirebaseFirestore db;
    late FakePhotoUploader uploader;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('cats');
      db = FakeFirebaseFirestore();
      uploader = FakePhotoUploader();
    });
    tearDown(() => dir.deleteSync(recursive: true));

    ProviderContainer container(FakeAuthRepository auth) {
      final c = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          firestoreProvider.overrideWithValue(db),
          catsFolderProvider.overrideWithValue(
            CatsFolder(dir: () async => dir),
          ),
          photoUploaderProvider.overrideWithValue(uploader),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('signs in once, imports into the new uid, starts uploading', () async {
      File('${dir.path}/cats.json').writeAsStringSync(
        '{"cats":[{"id":"1","name":"Ninja","encounters":'
        '[{"id":"1","photo":"1.jpg","time":1}]}]}',
      );
      File('${dir.path}/1.jpg').writeAsBytesSync([1]);
      final auth = FakeAuthRepository();
      final c = container(auth);

      final uid = await c.read(appStartupProvider.future);

      expect(uid, 'anon-uid');
      expect(auth.signIns, 1);
      expect((await db.doc('users/anon-uid/cats/1').get()).exists, isTrue);
      expect(File('${dir.path}/cats.json.imported').existsSync(), isTrue);
      expect(uploader.started, isTrue);
      expect(c.read(uidProvider), 'anon-uid');
      await Future<void>.delayed(Duration.zero); // the profile is not awaited
      final profile = await db.doc('users/anon-uid').get();
      expect(profile.data()!.keys, ['createdAt']);
    });

    test('a signed-in user is not signed in again', () async {
      final auth = FakeAuthRepository(uid: 'me');
      final c = container(auth);

      expect(await c.read(appStartupProvider.future), 'me');
      expect(auth.signIns, 0);
    });

    test('offline sign-in fails as SignInFailed and imports nothing', () async {
      File('${dir.path}/cats.json').writeAsStringSync('{"cats": []}');
      final auth = FakeAuthRepository()..signInError = StateError('offline');
      final c = container(auth);

      await expectLater(
        c.read(appStartupProvider.future),
        throwsA(isA<SignInFailed>()),
      );
      expect(File('${dir.path}/cats.json').existsSync(), isTrue);
      expect(uploader.started, isFalse);
    });
  });

  group('the startup screen', () {
    late FakeAuthRepository auth;
    late _StubImporter importer;
    late FakePhotoUploader uploader;

    List<Override> overrides() => [
      authRepositoryProvider.overrideWithValue(auth),
      firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
      catImporterProvider.overrideWithValue(importer),
      photoUploaderProvider.overrideWithValue(uploader),
      localPhotoCacheProvider.overrideWithValue(FakeLocalPhotoCache()),
    ];

    Future<void> pump(WidgetTester tester, {Locale? locale}) async {
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: overrides(),
          child: StrayCatsApp(locale: locale ?? const Locale('en')),
        ),
      );
    }

    setUp(() {
      auth = FakeAuthRepository(uid: 'me');
      importer = _StubImporter(() async {});
      uploader = FakePhotoUploader();
    });

    testWidgets('shows a loading state, then the cats', (tester) async {
      await pump(tester);
      expect(find.text('Getting your cats ready…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CatsPage), findsNothing);

      await tester.pump();
      await tester.pump();

      expect(find.byType(CatsPage), findsOneWidget);
      expect(find.text('Getting your cats ready…'), findsNothing);
    });

    testWidgets('first launch without internet: message, Retry works', (
      tester,
    ) async {
      auth = FakeAuthRepository()..signInError = StateError('offline');
      await pump(tester);
      await tester.pump();
      await tester.pump();

      expect(
        find.text(
          'Connect to the internet to set up the app. This is needed only once.',
        ),
        findsOneWidget,
      );
      expect(find.byType(CatsPage), findsNothing);

      auth.signInError = null;
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(CatsPage), findsOneWidget);
      expect(auth.signIns, 2);
    });

    testWidgets(
      'the import needing internet says so, and Retry runs it again',
      (tester) async {
        importer.onRun = () async => throw const ImportOffline();
        await pump(tester);
        await tester.pump();
        await tester.pump();

        expect(
          find.text('Connect to the internet to bring your cats over.'),
          findsOneWidget,
        );

        importer.onRun = () async {};
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump();

        expect(importer.runs, 2);
        expect(find.byType(CatsPage), findsOneWidget);
      },
    );

    testWidgets('a corrupt cats file says nothing was moved', (tester) async {
      importer.onRun = () async => throw const LegacyCatsCorrupt('bad');
      await pump(tester);
      await tester.pump();
      await tester.pump();

      expect(
        find.text(
          'Your saved cats could not be read, so nothing was moved. '
          'Your photos are untouched.',
        ),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('any other failure shows a general message', (tester) async {
      importer.onRun = () async => throw StateError('boom');
      await pump(tester);
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Something went wrong starting the app.'),
        findsOneWidget,
      );
    });

    testWidgets('speaks Spanish too', (tester) async {
      auth = FakeAuthRepository()..signInError = StateError('offline');
      await pump(tester, locale: const Locale('es'));
      expect(find.text('Preparando tus gatos…'), findsOneWidget);
      await tester.pump();
      await tester.pump();

      expect(find.text('Reintentar'), findsOneWidget);
      expect(
        find.text(
          'Conéctate a internet para configurar la app. Solo hace falta una vez.',
        ),
        findsOneWidget,
      );
    });
  });
}
