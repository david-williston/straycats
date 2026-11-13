import 'dart:io';

import 'cats_folder.dart';
import 'image_picker_service.dart';
import 'photo_repository.dart';

/// Keeps photos as `<millis>.jpg` in the cats folder.
class DevicePhotoRepository implements PhotoRepository {
  DevicePhotoRepository(this._folder, this._picker);

  final CatsFolder _folder;
  final ImagePickerService _picker;

  @override
  Future<File?> takePhoto() async {
    final path = await _picker.takePhoto();
    if (path == null) return null;
    final dir = await _folder.open();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return File(path).copy('${dir.path}/$stamp.jpg');
  }

  @override
  Future<void> discard(File photo) async {
    if (photo.existsSync()) await photo.delete();
  }
}
