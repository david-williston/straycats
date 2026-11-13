import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../cats/application/cat_importer.dart';
import '../../cats/application/photo_uploader.dart';
import '../../cats/data/firestore_cat_repository.dart';

part 'app_startup.g.dart';

/// Signing in failed, usually because the phone is offline on the very first
/// launch (after that, the sign-in is remembered).
class SignInFailed implements Exception {
  const SignInFailed(this.cause);

  final Object cause;

  @override
  String toString() => 'SignInFailed: $cause';
}

/// What must happen before the app shows the cats: sign in anonymously (once),
/// bring over the cats kept before Firebase (once), and start the photo
/// uploader. Completes with the user's uid; errors show on the startup screen
/// with Retry.
@Riverpod(keepAlive: true)
Future<String> appStartup(Ref ref) async {
  final auth = ref.watch(authRepositoryProvider);
  String uid;
  try {
    uid = auth.uid ?? await auth.signInAnonymously();
  } catch (e) {
    throw SignInFailed(e);
  }
  // Built here, not through the cat repository provider, which needs the uid
  // that this provider produces.
  await ref
      .watch(catImporterProvider)
      .run(FirestoreCatRepository(ref.watch(firestoreProvider), uid));
  ref.watch(photoUploaderProvider).start();
  return uid;
}

/// The signed-in user's id. Only valid once [appStartup] has completed, which
/// the startup screen guarantees before anything else is built.
@Riverpod(keepAlive: true)
String uid(Ref ref) => ref.watch(appStartupProvider).requireValue;
