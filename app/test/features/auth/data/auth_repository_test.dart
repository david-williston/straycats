import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/auth/data/auth_repository.dart';
import 'package:straycats/src/features/auth/domain/account.dart';

class _Token implements IdTokenResult {
  _Token(this.claims);

  @override
  final Map<String, dynamic>? claims;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Cred implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _User implements User {
  _User(this.uid, {this.claims = const {}});

  @override
  final String uid;
  @override
  bool isAnonymous = true;
  final Map<String, dynamic> claims;
  FirebaseAuthException? linkError;
  final linked = <AuthCredential>[];
  final tokenRefreshes = <bool>[];
  Object? tokenError;

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    final error = linkError;
    if (error != null) throw error;
    linked.add(credential);
    isAnonymous = false;
    return _Cred();
  }

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    tokenRefreshes.add(forceRefresh);
    if (forceRefresh && tokenError != null) throw tokenError!;
    return _Token(claims);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Auth implements FirebaseAuth {
  _Auth(this.currentUser);

  @override
  User? currentUser;
  final signedInWith = <AuthCredential>[];

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    signedInWith.add(credential);
    return _Cred();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _google = GoogleAuthProvider.credential(idToken: 'id-token');

void main() {
  group('signInWithGoogle', () {
    test('links the anonymous account, keeping its uid', () async {
      final user = _User('anon');
      final auth = _Auth(user);
      final repo = FirebaseAuthRepository(auth, () async => _google);

      expect(await repo.signInWithGoogle(), GoogleSignInResult.linked);

      expect(user.linked, [_google]);
      expect(auth.signedInWith, isEmpty);
      expect(repo.uid, 'anon');
    });

    test('an account already in use is signed in to instead', () async {
      final user = _User('anon')
        ..linkError = FirebaseAuthException(code: 'credential-already-in-use');
      final auth = _Auth(user);
      final repo = FirebaseAuthRepository(auth, () async => _google);

      expect(await repo.signInWithGoogle(), GoogleSignInResult.switchedAccount);

      expect(auth.signedInWith, [_google]);
    });

    test('closing the Google dialog changes nothing', () async {
      final user = _User('anon');
      final auth = _Auth(user);
      final repo = FirebaseAuthRepository(auth, () async => null);

      expect(await repo.signInWithGoogle(), GoogleSignInResult.cancelled);

      expect(user.linked, isEmpty);
      expect(auth.signedInWith, isEmpty);
    });

    test('any other linking error is passed on', () async {
      final user = _User('anon')
        ..linkError = FirebaseAuthException(code: 'network-request-failed');
      final repo = FirebaseAuthRepository(_Auth(user), () async => _google);

      await expectLater(
        repo.signInWithGoogle(),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  group('isAdmin', () {
    test('is true only for the claim admin == true', () async {
      for (final (claims, expected) in [
        (<String, dynamic>{'admin': true}, true),
        (<String, dynamic>{'admin': false}, false),
        (<String, dynamic>{'admin': 'true'}, false),
        (<String, dynamic>{}, false),
      ]) {
        final user = _User('u', claims: claims);
        final repo = FirebaseAuthRepository(_Auth(user));
        expect(await repo.isAdmin(), expected, reason: '$claims');
      }
    });

    test('forceRefresh asks the server for a fresh token', () async {
      final user = _User('u', claims: {'admin': true});
      final repo = FirebaseAuthRepository(_Auth(user));

      expect(await repo.isAdmin(forceRefresh: true), isTrue);
      expect(user.tokenRefreshes, [true]);
    });

    test('offline, the token the phone has is used', () async {
      final user = _User('u', claims: {'admin': true})
        ..tokenError = StateError('offline');
      final repo = FirebaseAuthRepository(_Auth(user));

      expect(await repo.isAdmin(forceRefresh: true), isTrue);
      expect(user.tokenRefreshes, [true, false]);
    });

    test('nobody signed in is not an admin', () async {
      expect(await FirebaseAuthRepository(_Auth(null)).isAdmin(), isFalse);
    });
  });
}
