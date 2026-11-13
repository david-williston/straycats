/// Who is signed in, as the account sheet shows it.
class Account {
  const Account({
    required this.uid,
    this.isAnonymous = true,
    this.displayName,
    this.email,
  });

  final String uid;

  /// True until the account is linked to a Google sign-in.
  final bool isAnonymous;
  final String? displayName;
  final String? email;
}

/// What signing in with Google did.
enum GoogleSignInResult {
  /// The anonymous account was linked: the same uid, so the cats stay.
  linked,

  /// The Google account already had cats (a reinstall or a second phone), so
  /// the app switched to it. The uid changed.
  switchedAccount,

  /// The person closed the Google dialog.
  cancelled,
}
