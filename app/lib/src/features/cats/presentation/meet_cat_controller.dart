import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../places/data/place_service.dart';
import '../data/photo_repository.dart';

part 'meet_cat_controller.g.dart';

/// The camera side of meeting a cat: take a photo, and throw it away if it
/// is not kept. (Keeping it is [CatsController.recordSighting].)
@Riverpod(keepAlive: true)
class MeetCatController extends _$MeetCatController {
  @override
  void build() {}

  /// A new photo kept as `<millis>.jpg`, or null if the camera was cancelled.
  ///
  /// Once there is a photo, its place starts being worked out (asking for
  /// location permission the first time), without waiting for it.
  Future<File?> takePhoto() async {
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
