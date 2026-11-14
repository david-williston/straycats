import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/application/account_providers.dart';
import '../../places/data/place_service.dart';
import '../data/photo_repository.dart';

part 'meet_cat_controller.g.dart';

/// The camera side of meeting a cat: take a photo, and throw it away if it
/// is not kept. Needs a signed-in person (the cats page keeps that provider
/// alive while it is open). (Keeping it is [CatsController.recordSighting].)
@Riverpod(keepAlive: true)
class MeetCatController extends _$MeetCatController {
  @override
  void build() {}

  /// A new photo kept as `<millis>.jpg`, or null if the camera was
  /// cancelled or the person is not signed in.
  ///
  /// Once there is a photo, its place starts being worked out (asking for
  /// location permission the first time), without waiting for it.
  Future<File?> takePhoto() async {
    // Signed-out people cannot take photos, whichever way this is reached.
    if (!ref.read(signedInProvider)) return null;
    final photo = await ref.read(photoRepositoryProvider).takePhoto();
    if (photo != null) ref.read(placeCaptureProvider).start(photo);
    return photo;
  }

  /// Deletes a photo that was not kept.
  Future<void> discard(File photo) {
    ref.read(placeCaptureProvider).drop(photo);
    return ref.read(photoRepositoryProvider).discard(photo);
  }
}
