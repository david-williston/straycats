import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase_providers.dart';
import '../../startup/application/app_startup.dart';

part 'profile_repository.g.dart';

/// The longest nickname the rules accept.
const maxNicknameLength = 40;

/// The person's own profile, `users/{uid}`: `createdAt` (server time, written
/// once) and an optional `nickname`. Nothing else: no email, no device.
abstract class ProfileRepository {
  /// Creates the profile if there is none. Never overwrites `createdAt`.
  Future<void> ensureProfile(String uid);

  /// The saved nickname, or null.
  Future<String?> nickname(String uid);

  /// Saves the trimmed [nickname] (at most [maxNicknameLength] characters);
  /// empty removes it.
  Future<void> setNickname(String uid, String nickname);
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

  @override
  Future<String?> nickname(String uid) async {
    final value = (await _doc(uid).get()).data()?['nickname'];
    return value is String && value.isNotEmpty ? value : null;
  }

  @override
  Future<void> setNickname(String uid, String nickname) {
    final name = nickname.trim();
    if (name.length > maxNicknameLength) {
      throw ArgumentError('Nickname longer than $maxNicknameLength');
    }
    return _doc(uid)
        .update({'nickname': name.isEmpty ? FieldValue.delete() : name});
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

/// The signed-in person's nickname, read when the account sheet opens.
@riverpod
Future<String?> myNickname(Ref ref) =>
    ref.watch(profileRepositoryProvider).nickname(ref.watch(uidProvider));
