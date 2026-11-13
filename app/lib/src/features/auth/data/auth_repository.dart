import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase_providers.dart';
import '../domain/account.dart';
import 'google_credential.dart';

part 'auth_repository.g.dart';

/// Who is using the app: anonymous at first, then linked to a Google sign-in,
/// which keeps the same uid, so no data moves.
abstract class AuthRepository {
  /// The signed-in user's id, or null if nobody is signed in yet.
  String? get uid;

  Stream<String?> uidChanges();

  /// The signed-in account, again after each change (linking, switching).
  Stream<Account?> accountChanges();

  /// Signs in without an account and returns the new uid. Needs a connection.
  Future<String> signInAnonymously();

  /// Links the anonymous account to a Google account (same uid). If that
  /// Google account is already linked to another uid, signs in to it instead.
  Future<GoogleSignInResult> signInWithGoogle();

  /// Whether the ID token carries the custom claim `admin == true`. With
  /// [forceRefresh] the token is fetched again so a new claim shows at once;
  /// offline, the token the phone already has is used.
  Future<bool> isAdmin({bool forceRefresh = false});

  /// Signs out of Google (so the next sign-in shows the account picker) and of
  /// Firebase. Nobody is signed in afterwards; startup signs in a new
  /// anonymous user.
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(
    this._auth, [
    GoogleCredentialSource? google,
    GoogleSignOut? googleSignOut,
  ]) : _google = google ?? googleCredential,
       _googleSignOut = googleSignOut ?? signOutOfGoogle;

  final FirebaseAuth _auth;
  final GoogleCredentialSource _google;
  final GoogleSignOut _googleSignOut;

  @override
  String? get uid => _auth.currentUser?.uid;

  @override
  Stream<String?> uidChanges() => _auth.authStateChanges().map((u) => u?.uid);

  @override
  Stream<Account?> accountChanges() => _auth.userChanges().map(_account);

  static Account? _account(User? user) => user == null
      ? null
      : Account(
          uid: user.uid,
          isAnonymous: user.isAnonymous,
          displayName: user.displayName,
          email: user.email,
        );

  @override
  Future<String> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    return credential.user!.uid;
  }

  @override
  Future<GoogleSignInResult> signInWithGoogle() async {
    final credential = await _google();
    if (credential == null) return GoogleSignInResult.cancelled;
    final user = _auth.currentUser;
    if (user == null) {
      await _auth.signInWithCredential(credential);
      return GoogleSignInResult.switchedAccount;
    }
    try {
      await user.linkWithCredential(credential);
      return GoogleSignInResult.linked;
    } on FirebaseAuthException catch (e) {
      if (e.code != 'credential-already-in-use' &&
          e.code != 'email-already-in-use') {
        rethrow;
      }
      // The error may carry a fresher credential than the one we made.
      await _auth.signInWithCredential(e.credential ?? credential);
      return GoogleSignInResult.switchedAccount;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignOut();
    } catch (e) {
      // Not fatal: the Firebase sign-out below is what ends the session.
      developer.log('Could not sign out of Google: $e', name: 'straycats');
    }
    await _auth.signOut();
  }

  @override
  Future<bool> isAdmin({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      final token = await user.getIdTokenResult(forceRefresh);
      return token.claims?['admin'] == true;
    } catch (e) {
      if (!forceRefresh) return false;
      developer.log('Could not refresh the token: $e', name: 'straycats');
      return isAdmin();
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    FirebaseAuthRepository(ref.watch(firebaseAuthProvider));
