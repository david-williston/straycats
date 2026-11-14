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

  test('a failure creating the profile does not escape at startup', () async {
    await ensureProfileQuietly(_FailingProfiles(), 'u1');
  });
}

class _FailingProfiles implements ProfileRepository {
  @override
  Future<void> ensureProfile(String uid) => throw StateError('offline');
}
