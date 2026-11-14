import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/admin/data/other_photo_cache.dart';
import 'package:straycats/src/features/auth/data/fake_auth_repository.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/data/fake_photo_storage.dart';
import 'package:straycats/src/features/cats/presentation/cat_card.dart';
import 'package:straycats/src/features/cats/presentation/cat_tile.dart';

import '../../../helpers.dart';

/// Records which owner and photo were asked for, and has no file.
class _RecordingCache extends OtherPhotoCache {
  _RecordingCache()
    : super(
        () async => Directory('/nonexistent/other-photos'),
        FakePhotoStorage(),
      );

  final asked = <String>[];

  @override
  Future<File?> fileFor(String ownerUid, String photoId) async {
    asked.add('$ownerUid/$photoId');
    return null;
  }

  @override
  Future<void> clear() async {}
}

void main() {
  late FakeFirebaseFirestore db;
  late FakeCatRepository mine;
  late _RecordingCache otherPhotos;

  setUp(() async {
    db = FakeFirebaseFirestore();
    otherPhotos = _RecordingCache();
    mine = FakeCatRepository();
    await db.doc('users/u1').set({'createdAt': Timestamp(1700000000, 0)});
    await db.doc('users/u2').set({'createdAt': Timestamp(1700000000, 0)});
    await db.doc('users/u1/cats/55').set({'name': 'Güero'});
    await db.doc('users/u1/encounters/55').set({
      'catId': '55',
      'photoId': '55',
      'takenAt': Timestamp(1700000000, 0),
      'note': 'Waiting by the door',
    });
  });

  Future<void> openPeople(WidgetTester tester) async {
    await pumpApp(
      tester,
      cats: mine,
      db: db,
      otherPhotos: otherPhotos,
      auth: FakeAuthRepository(
        uid: 'test-uid',
        email: 'admin@example.com',
        admin: true,
      ),
    );
    await tester.tap(find.byIcon(Icons.account_circle_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists people by uid', (tester) async {
    await openPeople(tester);

    expect(find.text('u1'), findsOneWidget);
    expect(find.text('u2'), findsOneWidget);
    expect(find.textContaining('Joined'), findsNWidgets(2));
  });

  testWidgets("shows a person's cats read only, with their photos", (
    tester,
  ) async {
    await openPeople(tester);
    await tester.tap(find.text('u1'));
    await tester.pumpAndSettle();

    expect(
      find.text("Viewing someone else's cats. Read only."),
      findsOneWidget,
    );
    expect(find.byType(CatTile), findsOneWidget);
    expect(find.text('Güero'), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera), findsNothing);
    expect(otherPhotos.asked.toSet(), {'u1/55'});

    await tester.tap(find.text('Güero'));
    await tester.pumpAndSettle();

    expect(find.byType(CatCard), findsOneWidget);
    final name = tester.widget<TextField>(find.byType(TextField));
    expect(name.readOnly, isTrue);
    expect(otherPhotos.asked.toSet(), {'u1/55'});

    // Tapping an encounter selects it but offers no edit or delete.
    await tester.tap(find.text('Waiting by the door'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsNothing);
    expect(find.text('Delete'), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);

    // Leaving writes nothing: not as me, not as them.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(mine.wroteAnything, isFalse);
    expect((await db.doc('users/u1/cats/55').get()).data()!['name'], 'Güero');
  });

  testWidgets('a person with no cats says so', (tester) async {
    await openPeople(tester);
    await tester.tap(find.text('u2'));
    await tester.pumpAndSettle();

    expect(find.text('This person has no cats yet.'), findsOneWidget);
  });
}
