import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/admin/presentation/people_page.dart';
import 'package:straycats/src/features/auth/data/fake_auth_repository.dart';
import 'package:straycats/src/features/auth/presentation/account_sheet.dart';
import 'package:straycats/src/features/auth/domain/account.dart';
import 'package:straycats/src/features/cats/application/fake_photo_uploader.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';

import '../../../helpers.dart';

Future<void> openSheet(WidgetTester tester) async {
  // Signed out there is no account button, so open the sheet directly.
  unawaited(showAccountSheet(tester.element(find.byType(Scaffold).first)));
  await tester.pumpAndSettle();
}

/// Text inside the sheet (the welcome screen behind it has the same button).
Finder inSheet(String text) =>
    find.descendant(of: find.byType(AccountSheet), matching: find.text(text));

void main() {
  testWidgets('not signed in: says so and offers Google', (tester) async {
    final auth = FakeAuthRepository(uid: 'test-uid');
    await pumpApp(tester, cats: FakeCatRepository(), auth: auth);
    await openSheet(tester);

    expect(
      find.text("Not signed in. Your cats are only on this phone's account."),
      findsOneWidget,
    );
    await tester.tap(inSheet('Sign in with Google'));
    await tester.pumpAndSettle();

    expect(auth.googleSignIns, 1);
    expect(
      find.text('Done. Your cats are now kept in your Google account.'),
      findsOneWidget,
    );
  });

  testWidgets('not linked to Google: no sign out, and why', (tester) async {
    await pumpApp(
      tester,
      cats: FakeCatRepository(),
      auth: FakeAuthRepository(uid: 'test-uid'),
    );
    await openSheet(tester);

    expect(find.text('Sign out'), findsNothing);
    expect(find.textContaining('keep your cats safe'), findsOneWidget);
  });

  testWidgets('linked to Google: shows who, and asks before signing out', (
    tester,
  ) async {
    final auth = FakeAuthRepository(uid: 'test-uid', email: 'dave@example.com');
    final uploader = FakePhotoUploader();
    await pumpApp(
      tester,
      cats: FakeCatRepository(),
      auth: auth,
      uploader: uploader,
    );
    await openSheet(tester);

    expect(find.text('Signed in as dave@example.com'), findsOneWidget);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign out?'), findsOneWidget);
    expect(find.textContaining("haven't finished"), findsNothing);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(auth.signOuts, 0);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await tester.pumpAndSettle();

    expect(auth.signOuts, 1);
    expect(find.text('Account'), findsNothing); // the sheet closed
  });

  testWidgets(
    'photos still uploading: Wait uploads, Sign out anyway signs out',
    (tester) async {
      final auth = FakeAuthRepository(
        uid: 'test-uid',
        email: 'dave@example.com',
      );
      final uploader = FakePhotoUploader()..pending = 2;
      await pumpApp(
        tester,
        cats: FakeCatRepository(),
        auth: auth,
        uploader: uploader,
      );
      await openSheet(tester);

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining("2 photos haven't finished uploading"),
        findsOneWidget,
      );

      await tester.tap(find.text('Wait'));
      await tester.pumpAndSettle();
      expect(uploader.drains, 1);
      expect(auth.signOuts, 0);
      expect(
        find.text('All your photos are uploaded. You can sign out now.'),
        findsOneWidget,
      );

      uploader.pending = 1;
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 photo hasn'), findsOneWidget);
      await tester.tap(find.text('Sign out anyway'));
      await tester.pumpAndSettle();

      expect(auth.signOuts, 1);
    },
  );

  testWidgets('a failed sign-out says so and keeps the sheet', (tester) async {
    final auth = FakeAuthRepository(uid: 'test-uid', email: 'dave@example.com')
      ..signOutError = StateError('boom');
    await pumpApp(tester, cats: FakeCatRepository(), auth: auth);
    await openSheet(tester);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Could not sign out. Try again.'), findsOneWidget);
  });

  testWidgets('a failed sign-in says so', (tester) async {
    final auth = FakeAuthRepository(uid: 'test-uid')
      ..googleError = StateError('offline');
    await pumpApp(tester, cats: FakeCatRepository(), auth: auth);
    await openSheet(tester);

    await tester.tap(inSheet('Sign in with Google'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not sign in. Check your connection and try again.'),
      findsOneWidget,
    );
  });

  testWidgets('switching to another account says the old cats were not added', (
    tester,
  ) async {
    final auth = FakeAuthRepository(uid: 'test-uid')
      ..googleResult = GoogleSignInResult.switchedAccount;
    await pumpApp(
      tester,
      cats: FakeCatRepository([
        cat('1', 'Ciccio', [1000]),
      ]),
      auth: auth,
    );
    await openSheet(tester);

    await tester.tap(inSheet('Sign in with Google'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(auth.uid, 'google-uid');
    expect(
      find.text(
        "Signed in to your Google account. The cats on this phone's earlier "
        'account were not added to it.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('has no nickname field', (tester) async {
    await pumpApp(tester, cats: FakeCatRepository());
    await openSheet(tester);

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('People is only for an admin', (tester) async {
    await pumpApp(tester, cats: FakeCatRepository());
    await openSheet(tester);
    expect(find.text('People'), findsNothing);
  });

  testWidgets('an admin sees People, which opens the list', (tester) async {
    await pumpApp(
      tester,
      cats: FakeCatRepository(),
      auth: FakeAuthRepository(uid: 'test-uid', admin: true),
    );
    await openSheet(tester);

    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();

    expect(find.byType(PeoplePage), findsOneWidget);
  });

  testWidgets('speaks Spanish', (tester) async {
    await pumpApp(
      tester,
      cats: FakeCatRepository(),
      auth: FakeAuthRepository(uid: 'test-uid'),
      locale: const Locale('es'),
    );
    expect(find.text('Vamos a conocer gatos.'), findsOneWidget);
    await openSheet(tester);

    expect(
      find.text(
        'Sin iniciar sesión. Tus gatos solo están en la cuenta de este '
        'teléfono.',
      ),
      findsOneWidget,
    );
    expect(inSheet('Iniciar sesión con Google'), findsOneWidget);
  });
}
