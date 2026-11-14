import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase_providers.dart';

part 'profile_repository.g.dart';

/// The person's own profile, `users/{uid}`: `createdAt` (server time, written
/// once). Nothing else: no email, no device. (Old profiles may still hold a
/// `nickname`; the app no longer reads or writes it.)
abstract class ProfileRepository {
  /// Creates the profile if there is none. Never overwrites `createdAt`.
  Future<void> ensureProfile(String uid);
}

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  @override
  Future<void> ensureProfile(String uid) async {
    final doc = _doc(uid);
    if ((await doc.get()).exists) return;
    await doc.set({'createdAt': FieldValue.serverTimestamp()});
  }
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    FirestoreProfileRepository(ref.watch(firestoreProvider));

/// Makes sure the profile exists. Called at startup; a failure (offline, the
/// first time) is logged and tried again at the next start.
Future<void> ensureProfileQuietly(ProfileRepository repo, String uid) async {
  try {
    await repo.ensureProfile(uid);
  } catch (e) {
    developer.log('Could not create the profile: $e', name: 'straycats');
  }
}
