import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Asks the person to pick a Google account and returns the Firebase
/// credential for it, or null if they closed the dialog.
typedef GoogleCredentialSource = Future<AuthCredential?> Function();

var _initialized = false;

Future<AuthCredential?> googleCredential() async {
  final signIn = GoogleSignIn.instance;
  if (!_initialized) {
    // On Android the client id comes from google-services.json.
    await signIn.initialize();
    _initialized = true;
  }
  try {
    final account = await signIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google gave no ID token');
    }
    return GoogleAuthProvider.credential(idToken: idToken);
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled ||
        e.code == GoogleSignInExceptionCode.interrupted) {
      return null;
    }
    rethrow;
  }
}

/// Signs out of the Google account on this phone, and disconnects it, so the
/// next sign-in asks which account to use.
typedef GoogleSignOut = Future<void> Function();

Future<void> signOutOfGoogle() async {
  final signIn = GoogleSignIn.instance;
  if (!_initialized) {
    await signIn.initialize();
    _initialized = true;
  }
  try {
    await signIn.disconnect();
  } catch (e) {
    developer.log('Could not disconnect Google: $e', name: 'straycats');
  }
  await signIn.signOut();
}
