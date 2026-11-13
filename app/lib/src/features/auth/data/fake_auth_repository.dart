import '../domain/account.dart';
import 'auth_repository.dart';

/// A signed-out or signed-in user in memory, for tests. [signInError] makes
/// [signInAnonymously] fail, as it does without a connection.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.uid, this.admin = false});

  @override
  String? uid;

  Object? signInError;
  int signIns = 0;

  /// What [signInWithGoogle] does.
  GoogleSignInResult googleResult = GoogleSignInResult.linked;
  Object? googleError;
  int googleSignIns = 0;

  bool admin;
  final adminChecks = <bool>[];

  @override
  Stream<String?> uidChanges() => Stream.value(uid);

  @override
  Stream<Account?> accountChanges() =>
      Stream.value(uid == null ? null : Account(uid: uid!));

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
    return googleResult;
  }

  @override
  Future<bool> isAdmin({bool forceRefresh = false}) async {
    adminChecks.add(forceRefresh);
    return admin;
  }
}
