import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'cats_folder.dart';
import 'device_photo_repository.dart';
import 'image_picker_service.dart';

part 'photo_repository.g.dart';

/// The photos of the cats. The app uses [DevicePhotoRepository]; tests
/// override [photoRepository].
abstract class PhotoRepository {
  /// Takes a photo with the camera and keeps it as `<millis>.jpg`. Null if
  /// the camera was cancelled.
  Future<File?> takePhoto();

  /// Deletes a photo taken by [takePhoto] that was not kept.
  Future<void> discard(File photo);
}

@Riverpod(keepAlive: true)
PhotoRepository photoRepository(Ref ref) => DevicePhotoRepository(
  ref.watch(catsFolderProvider),
  ref.watch(imagePickerServiceProvider),
);
