import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/app.dart';
import 'package:straycats/src/data/firebase_providers.dart';
import 'package:straycats/src/features/auth/data/auth_repository.dart';
import 'package:straycats/src/features/auth/data/fake_auth_repository.dart';
import 'package:straycats/src/features/cats/application/fake_photo_uploader.dart';
import 'package:straycats/src/features/cats/application/photo_uploader.dart';
import 'package:straycats/src/features/cats/data/fake_local_photo_cache.dart';
import 'package:straycats/src/features/cats/data/local_photo_cache.dart';
import 'package:straycats/src/features/cats/presentation/cats_page.dart';
import 'package:straycats/src/features/startup/application/app_startup.dart';

void main() {
  group('appStartup', () {
    late FakeFirebaseFirestore db;
    setUp(() => db = FakeFirebaseFirestore());

    ProviderContainer container(FakeAuthRepository auth) {
      final c = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          firestoreProvider.overrideWithValue(db),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('signs in once and creates the profile', () async {
      final auth = FakeAuthRepository();
      final c = container(auth);

      final uid = await c.read(appStartupProvider.future);

      expect(uid, 'anon-uid');
      expect(auth.signIns, 1);
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

    test('offline sign-in fails as SignInFailed', () async {
      final auth = FakeAuthRepository()..signInError = StateError('offline');
      final c = container(auth);

      await expectLater(
        c.read(appStartupProvider.future),
        throwsA(isA<SignInFailed>()),
      );
    });
  });

  group('the startup screen', () {
    late FakeAuthRepository auth;
    late FakePhotoUploader uploader;

    List<Override> overrides() => [
      authRepositoryProvider.overrideWithValue(auth),
      firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
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
      uploader = FakePhotoUploader();
    });

    testWidgets('shows a loading state, then the cats, and starts uploading', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('Getting your cats ready…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CatsPage), findsNothing);
      expect(uploader.started, isFalse);

      await tester.pump();
      await tester.pump();

      expect(find.byType(CatsPage), findsOneWidget);
      expect(find.text('Getting your cats ready…'), findsNothing);
      expect(uploader.started, isTrue);
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
