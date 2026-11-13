import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/profile/data/profile_repository.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirestoreProfileRepository repo;
  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirestoreProfileRepository(db);
  });

  Future<Map<String, dynamic>?> profile() async =>
      (await db.doc('users/u1').get()).data();

  test('creates users/{uid} with only createdAt', () async {
    await repo.ensureProfile('u1');

    final data = await profile();
    expect(data!.keys, ['createdAt']);
    expect(data['createdAt'], isA<Timestamp>());
  });

  test('is written once: a second start leaves createdAt alone', () async {
    await db.doc('users/u1').set({'createdAt': Timestamp(5, 0)});

    await repo.ensureProfile('u1');
    await repo.ensureProfile('u1');

    expect((await profile())!['createdAt'], Timestamp(5, 0));
  });

  test('sets, trims, changes and removes the nickname', () async {
    await repo.ensureProfile('u1');

    await repo.setNickname('u1', '  Dave ');
    expect((await profile())!['nickname'], 'Dave');
    expect(await repo.nickname('u1'), 'Dave');

    await repo.setNickname('u1', 'Davo');
    expect(await repo.nickname('u1'), 'Davo');

    await repo.setNickname('u1', '   ');
    expect((await profile())!.containsKey('nickname'), isFalse);
    expect(await repo.nickname('u1'), isNull);
    expect((await profile())!.containsKey('createdAt'), isTrue);
  });

  test('a nickname over 40 characters is refused', () async {
    await repo.ensureProfile('u1');

    expect(
      () => repo.setNickname('u1', 'x' * 41),
      throwsA(isA<ArgumentError>()),
    );
    await repo.setNickname('u1', 'x' * 40);
  });

  test('a failure creating the profile does not escape at startup', () async {
    await ensureProfileQuietly(_FailingProfiles(), 'u1');
  });
}

class _FailingProfiles implements ProfileRepository {
  @override
  Future<void> ensureProfile(String uid) => throw StateError('offline');

  @override
  Future<String?> nickname(String uid) => throw UnimplementedError();

  @override
  Future<void> setNickname(String uid, String nickname) =>
      throw UnimplementedError();
}
