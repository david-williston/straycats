import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../admin/data/is_admin.dart';
import '../../admin/data/other_photo_cache.dart';
import '../../cats/application/photo_uploader.dart';
import '../../cats/data/cat_repository.dart';
import '../../cats/presentation/cats_controller.dart';
import '../../profile/data/profile_repository.dart';
import '../../startup/application/app_startup.dart';
import '../data/auth_repository.dart';
import 'account_providers.dart';

part 'sign_out_service.g.dart';

/// Signing out and starting over as a new anonymous user.
///
/// The signed-out account's photos that have not uploaded yet stay queued in
/// that account's own folder, and upload next time it signs in.
class SignOutService {
  SignOutService(this._ref);

  final Ref _ref;

  /// How many photos of the signed-in account have not finished uploading.
  Future<int> pendingUploads() =>
      _ref.read(photoUploaderProvider).pendingCount();

  /// Tries to upload the waiting photos now; returns how many are still
  /// waiting (some, if the phone is offline).
  Future<int> uploadPending() async {
    final uploader = _ref.read(photoUploaderProvider);
    await uploader.drain();
    return uploader.pendingCount();
  }

  /// Signs out of Google and Firebase, forgets everything that belonged to
  /// the account, and runs startup again, which signs in a new anonymous user.
  Future<void> signOut() async {
    _ref.read(photoUploaderProvider).stop();
    await _ref.read(authRepositoryProvider).signOut();
    try {
      await _ref.read(otherPhotoCacheProvider).clear();
    } catch (e) {
      developer.log('Could not clear other photos: $e', name: 'straycats');
    }
    // Everything that depends on who is signed in starts over.
    _ref
      ..invalidate(isAdminProvider)
      ..invalidate(accountProvider)
      ..invalidate(myNicknameProvider)
      ..invalidate(catsControllerProvider)
      ..invalidate(catRepositoryProvider)
      ..invalidate(appStartupProvider);
  }
}

@Riverpod(keepAlive: true)
SignOutService signOutService(Ref ref) => SignOutService(ref);
