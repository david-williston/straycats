import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase_providers.dart';

part 'auth_repository.g.dart';

/// Who is using the app. Anonymous for now; linking a sign-in later keeps
/// the same uid, so no data moves.
abstract class AuthRepository {
  /// The signed-in user's id, or null if nobody is signed in yet.
  String? get uid;

  Stream<String?> uidChanges();

  /// Signs in without an account and returns the new uid. Needs a connection.
  Future<String> signInAnonymously();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  String? get uid => _auth.currentUser?.uid;

  @override
  Stream<String?> uidChanges() => _auth.authStateChanges().map((u) => u?.uid);

  @override
  Future<String> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    return credential.user!.uid;
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    FirebaseAuthRepository(ref.watch(firebaseAuthProvider));
