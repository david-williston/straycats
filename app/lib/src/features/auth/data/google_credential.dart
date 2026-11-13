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
