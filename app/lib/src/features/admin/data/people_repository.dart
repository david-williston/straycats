import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase_providers.dart';
import '../../cats/data/firestore_cat_repository.dart';
import '../../cats/domain/cat.dart';
import '../domain/person.dart';

part 'people_repository.g.dart';

/// Read-only access to other people's records, for the admin. Everything is
/// fetched once (no listeners), so other people's data does not pile up on the
/// phone. The rules decide who may read; this app only reads.
abstract class PeopleRepository {
  /// Every `users/{uid}` profile.
  Future<List<Person>> listPeople();

  /// The cats and encounters of [uid], once.
  Future<List<Cat>> catsOf(String uid);
}

class FirestorePeopleRepository implements PeopleRepository {
  FirestorePeopleRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Future<List<Person>> listPeople() async {
    final snapshot = await _db.collection('users').get();
    return [
      for (final doc in snapshot.docs)
        Person(
          uid: doc.id,
          createdAt: (doc.data()['createdAt'] as Timestamp?)?.toDate(),
        ),
    ];
  }

  @override
  Future<List<Cat>> catsOf(String uid) =>
      FirestoreCatRepository(_db, uid).fetchCats();
}

@Riverpod(keepAlive: true)
PeopleRepository peopleRepository(Ref ref) =>
    FirestorePeopleRepository(ref.watch(firestoreProvider));

@riverpod
Future<List<Person>> people(Ref ref) =>
    ref.watch(peopleRepositoryProvider).listPeople();

@riverpod
Future<List<Cat>> personCats(Ref ref, String uid) =>
    ref.watch(peopleRepositoryProvider).catsOf(uid);
