import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/admin/presentation/people_page.dart';
import 'package:straycats/src/features/auth/data/fake_auth_repository.dart';
import 'package:straycats/src/features/auth/domain/account.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';

import '../../../helpers.dart';

Future<void> openSheet(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.account_circle_outlined));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('not signed in: says so and offers Google', (tester) async {
    final auth = FakeAuthRepository(uid: 'test-uid');
    await pumpApp(tester, cats: FakeCatRepository(), auth: auth);
    await openSheet(tester);

    expect(
      find.text("Not signed in. Your cats are only on this phone's account."),
      findsOneWidget,
    );
    await tester.tap(find.text('Sign in with Google'));
    await tester.pumpAndSettle();

    expect(auth.googleSignIns, 1);
    expect(
      find.text('Done. Your cats are now kept in your Google account.'),
      findsOneWidget,
    );
  });

  testWidgets('a failed sign-in says so', (tester) async {
    final auth = FakeAuthRepository(uid: 'test-uid')
      ..googleError = StateError('offline');
    await pumpApp(tester, cats: FakeCatRepository(), auth: auth);
    await openSheet(tester);

    await tester.tap(find.text('Sign in with Google'));
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

    await tester.tap(find.text('Sign in with Google'));
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

  testWidgets('saves the nickname on the profile', (tester) async {
    final db = FakeFirebaseFirestore();
    await db.doc('users/test-uid').set({'createdAt': Timestamp(1, 0)});
    await pumpApp(tester, cats: FakeCatRepository(), db: db);
    await openSheet(tester);

    await tester.enterText(find.byType(TextField), '  Dave ');
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    expect((await db.doc('users/test-uid').get()).data()?['nickname'], 'Dave');
    expect(find.text('Nickname saved'), findsOneWidget);
  });

  testWidgets('shows the saved nickname', (tester) async {
    final db = FakeFirebaseFirestore();
    await db.doc('users/test-uid').set({
      'createdAt': Timestamp(1, 0),
      'nickname': 'Dave',
    });
    await pumpApp(tester, cats: FakeCatRepository(), db: db);
    await openSheet(tester);

    expect(find.widgetWithText(TextField, 'Dave'), findsOneWidget);
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
      locale: const Locale('es'),
    );
    await openSheet(tester);

    expect(
      find.text(
        'Sin iniciar sesión. Tus gatos solo están en la cuenta de este '
        'teléfono.',
      ),
      findsOneWidget,
    );
    expect(find.text('Iniciar sesión con Google'), findsOneWidget);
    expect(find.text('Apodo (opcional)'), findsOneWidget);
  });
}
