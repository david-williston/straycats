import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';

part 'app_startup.g.dart';

/// Signing in failed, usually because the phone is offline on the very first
/// launch (after that, the sign-in is remembered).
class SignInFailed implements Exception {
  const SignInFailed(this.cause);

  final Object cause;

  @override
  String toString() => 'SignInFailed: $cause';
}

/// What must happen before the app shows the cats: sign in anonymously if
/// nobody is signed in (the first launch, or after signing out). It also
/// starts creating the profile `users/{uid}`, without waiting (offline, the
/// write waits for a connection). Completes with the user's uid; errors show
/// on the startup screen with Retry. The photo uploader is started by the
/// startup screen once this is done, since it needs the uid.
@Riverpod(keepAlive: true)
Future<String> appStartup(Ref ref) async {
  final auth = ref.watch(authRepositoryProvider);
  String uid;
  try {
    uid = auth.uid ?? await auth.signInAnonymously();
  } catch (e) {
    throw SignInFailed(e);
  }
  unawaited(ensureProfileQuietly(ref.watch(profileRepositoryProvider), uid));
  return uid;
}

/// The signed-in user's id. Only valid once [appStartup] has completed, which
/// the startup screen guarantees before anything else is built.
@Riverpod(keepAlive: true)
String uid(Ref ref) => ref.watch(appStartupProvider).requireValue;
