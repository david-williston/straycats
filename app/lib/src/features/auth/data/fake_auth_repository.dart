import '../domain/account.dart';
import 'auth_repository.dart';

/// A signed-out or signed-in user in memory, for tests. [signInError] makes
/// [signInAnonymously] fail, as it does without a connection. Give [email] to
/// make the account one that is linked to Google.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.uid, this.admin = false, this.email});

  @override
  String? uid;

  /// Set when the account is linked to Google.
  String? email;

  Object? signInError;
  int signIns = 0;
  int signOuts = 0;
  Object? signOutError;

  /// What [signInWithGoogle] does.
  GoogleSignInResult googleResult = GoogleSignInResult.linked;
  Object? googleError;
  int googleSignIns = 0;

  bool admin;
  final adminChecks = <bool>[];

  @override
  Stream<String?> uidChanges() => Stream.value(uid);

  @override
  Stream<Account?> accountChanges() => Stream.value(
    uid == null
        ? null
        : Account(uid: uid!, isAnonymous: email == null, email: email),
  );

  @override
  Future<String> signInAnonymously() async {
    signIns++;
    final error = signInError;
    if (error != null) throw error;
    return uid = 'anon-uid';
  }

  @override
  Future<GoogleSignInResult> signInWithGoogle() async {
    googleSignIns++;
    final error = googleError;
    if (error != null) throw error;
    if (googleResult == GoogleSignInResult.switchedAccount) uid = 'google-uid';
    if (googleResult != GoogleSignInResult.cancelled) {
      email = 'dave@example.com';
    }
    return googleResult;
  }

  @override
  Future<void> signOut() async {
    final error = signOutError;
    if (error != null) throw error;
    signOuts++;
    uid = null;
    email = null;
  }

  @override
  Future<bool> isAdmin({bool forceRefresh = false}) async {
    adminChecks.add(forceRefresh);
    return admin;
  }
}
