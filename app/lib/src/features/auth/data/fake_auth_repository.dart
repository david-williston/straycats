import 'auth_repository.dart';

/// A signed-out or signed-in user in memory, for tests. [signInError] makes
/// [signInAnonymously] fail, as it does without a connection.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.uid});

  @override
  String? uid;

  Object? signInError;
  int signIns = 0;

  @override
  Stream<String?> uidChanges() => Stream.value(uid);

  @override
  Future<String> signInAnonymously() async {
    signIns++;
    final error = signInError;
    if (error != null) throw error;
    return uid = 'anon-uid';
  }
}
