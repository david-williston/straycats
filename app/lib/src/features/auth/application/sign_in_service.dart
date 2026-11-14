import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../localization/app_localizations.dart';
import '../../admin/data/is_admin.dart';
import '../../cats/presentation/cats_controller.dart';
import '../../startup/application/app_startup.dart';
import '../data/auth_repository.dart';
import '../domain/account.dart';

part 'sign_in_service.g.dart';

/// Signing in with Google from the account sheet or the welcome screen.
class SignInService {
  SignInService(this._ref);

  final Ref _ref;

  /// Signs in and tells the person how it went (a snackbar). Returns the
  /// result, or null when it failed. When the account switched, [onSwitched]
  /// runs (the sheet closes itself) before the app starts again as the new
  /// account. [mounted] says whether the caller is still on screen.
  Future<GoogleSignInResult?> signInWithGoogle({
    required AppLocalizations l10n,
    required ScaffoldMessengerState messenger,
    required bool Function() mounted,
    VoidCallback? onSwitched,
  }) async {
    final hadCats =
        (_ref.read(catsControllerProvider).value ?? const []).isNotEmpty;
    try {
      final result = await _ref.read(authRepositoryProvider).signInWithGoogle();
      if (!mounted()) return result;
      switch (result) {
        case GoogleSignInResult.cancelled:
          break;
        case GoogleSignInResult.linked:
          _ref.invalidate(isAdminProvider);
          messenger.showSnackBar(SnackBar(content: Text(l10n.googleLinked)));
        case GoogleSignInResult.switchedAccount:
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                hadCats ? l10n.googleSwitchedKeptOld : l10n.googleSwitched,
              ),
            ),
          );
          onSwitched?.call();
          // A new uid: start again so every screen reads the new account.
          _ref.invalidate(appStartupProvider);
      }
      return result;
    } catch (_) {
      if (!mounted()) return null;
      messenger.showSnackBar(SnackBar(content: Text(l10n.signInFailed)));
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
SignInService signInService(Ref ref) => SignInService(ref);
