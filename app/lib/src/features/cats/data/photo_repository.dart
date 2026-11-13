import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'cat_repository.dart';
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

  /// The file for an encounter's photo name.
  File photoFile(String name);
}

@Riverpod(keepAlive: true)
PhotoRepository photoRepository(Ref ref) => DevicePhotoRepository(
  ref.watch(catsFolderProvider),
  ref.watch(imagePickerServiceProvider),
);
