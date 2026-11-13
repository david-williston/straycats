import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/data/firebase_providers.dart';
import 'package:straycats/src/features/admin/data/is_admin.dart';
import 'package:straycats/src/features/admin/data/other_photo_cache.dart';
import 'package:straycats/src/features/auth/application/account_providers.dart';
import 'package:straycats/src/features/auth/application/sign_out_service.dart';
import 'package:straycats/src/features/auth/data/auth_repository.dart';
import 'package:straycats/src/features/auth/data/fake_auth_repository.dart';
import 'package:straycats/src/features/auth/domain/account.dart';
import 'package:straycats/src/features/cats/application/photo_uploader.dart';
import 'package:straycats/src/features/cats/data/cats_folder.dart';
import 'package:straycats/src/features/cats/data/fake_photo_storage.dart';
import 'package:straycats/src/features/cats/data/photo_outbox.dart';
import 'package:straycats/src/features/cats/data/photo_storage.dart';
import 'package:straycats/src/features/cats/presentation/cats_controller.dart';
import 'package:straycats/src/features/startup/application/app_startup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docs;
  late FakeAuthRepository auth;
  late FakeFirebaseFirestore db;
  late FakePhotoStorage storage;
  late ProviderContainer c;

  setUp(() {
    docs = Directory.systemTemp.createTempSync('docs');
    auth = FakeAuthRepository(uid: 'google-uid', email: 'dave@example.com');
    db = FakeFirebaseFirestore();
    storage = FakePhotoStorage();
    c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        firestoreProvider.overrideWithValue(db),
        photoStorageProvider.overrideWithValue(storage),
        documentsDirProvider.overrideWithValue(() async => docs),
        otherPhotoCacheProvider.overrideWithValue(
          OtherPhotoCache(() async => Directory('${docs.path}/other'), storage),
        ),
      ],
    );
    addTearDown(c.dispose);
    addTearDown(() => docs.deleteSync(recursive: true));
  });

  Future<PhotoOutbox> outboxOf(String uid) async =>
      PhotoOutbox(CatsFolder.forUser(() async => docs, uid));

  Future<void> queuePhoto(String uid, String id) async {
    final folder = CatsFolder.forUser(() async => docs, uid);
    File('${(await folder.open()).path}/$id.jpg').writeAsBytesSync([7]);
    await (await outboxOf(uid)).enqueue(id);
  }

  test('each uid has its own photo and outbox folders', () async {
    await c.read(appStartupProvider.future);
    final mine = (await c.read(catsFolderProvider).open()).path;
    final other = (await CatsFolder.forUser(
      () async => docs,
      'u2',
    ).open()).path;

    expect(mine, '${docs.path}/users/google-uid/photos');
    expect(other, '${docs.path}/users/u2/photos');
    expect(
      (await c.read(catsFolderProvider).openOutbox()).path,
      '${docs.path}/users/google-uid/outbox',
    );
  });

  test('a uid cannot reach outside its folder', () {
    expect(
      () => CatsFolder.forUser(() async => docs, '../x'),
      throwsArgumentError,
    );
    expect(() => CatsFolder.forUser(() async => docs, ''), throwsArgumentError);
  });

  test('signing out resets everything that belongs to the account', () async {
    await c.read(appStartupProvider.future);
    await db.doc('users/google-uid/cats/1').set({'name': 'Ninja'});
    c.listen(catsControllerProvider, (_, _) {});
    c.listen(accountProvider, (_, _) {}); // like the open account sheet
    expect((await c.read(catsControllerProvider.future)).map((x) => x.id), [
      '1',
    ]);
    expect((await c.read(accountProvider.future))!.email, 'dave@example.com');
    await c.read(isAdminProvider.future);
    expect(auth.adminChecks, hasLength(1));
    await queuePhoto('google-uid', '100');
    // Another person's photo sitting in the admin cache.
    File('${docs.path}/other/x/1.jpg')
      ..createSync(recursive: true)
      ..writeAsBytesSync([1]);
    final service = c.read(signOutServiceProvider);
    expect(await service.pendingUploads(), 1);

    await service.signOut();

    expect(auth.signOuts, 1);
    expect(await c.read(appStartupProvider.future), 'anon-uid');
    expect(c.read(uidProvider), 'anon-uid');
    expect(Directory('${docs.path}/other').existsSync(), isFalse);
    expect(await c.read(catsControllerProvider.future), isEmpty);
    await c.read(isAdminProvider.future);
    expect(auth.adminChecks, hasLength(2));
    final account = await c.read(accountProvider.future);
    expect(account!.uid, 'anon-uid');
    expect(account.isAnonymous, isTrue);
    // The new anonymous user has nothing waiting, and never uploads the
    // other account's photo.
    expect(await service.pendingUploads(), 0);
    await c.read(photoUploaderProvider).drain();
    expect(storage.uploaded, isEmpty);
    expect(await (await outboxOf('google-uid')).pending(), ['100']);
  });

  test('signing in again restores the uid, its cats and its uploads', () async {
    await c.read(appStartupProvider.future);
    await db.doc('users/google-uid/cats/1').set({'name': 'Ninja'});
    await queuePhoto('google-uid', '100');
    await c.read(signOutServiceProvider).signOut();
    await c.read(appStartupProvider.future);
    c.listen(catsControllerProvider, (_, _) {});
    expect(await c.read(catsControllerProvider.future), isEmpty);

    auth.googleResult = GoogleSignInResult.switchedAccount;
    expect(
      await c.read(authRepositoryProvider).signInWithGoogle(),
      GoogleSignInResult.switchedAccount,
    );
    c.invalidate(appStartupProvider); // what the account sheet does

    expect(await c.read(appStartupProvider.future), 'google-uid');
    expect(c.read(uidProvider), 'google-uid');
    expect((await c.read(catsControllerProvider.future)).map((x) => x.id), [
      '1',
    ]);
    expect(await c.read(signOutServiceProvider).pendingUploads(), 1);
    await c.read(photoUploaderProvider).drain();
    expect(storage.uploadedBy, ['google-uid/100']);
  });

  test('uploadPending reports what is left', () async {
    await c.read(appStartupProvider.future);
    await queuePhoto('google-uid', '100');
    storage.failWith = const SocketException('offline');
    final service = c.read(signOutServiceProvider);

    expect(await service.uploadPending(), 1);
    storage.failWith = null;
    expect(await service.uploadPending(), 0);
  });
}
