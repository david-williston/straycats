import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_picker_service.g.dart';

/// The device camera. Tests override [imagePickerService].
abstract class ImagePickerService {
  /// Takes a photo and returns its path, or null if the camera was cancelled.
  Future<String?> takePhoto();
}

class DeviceImagePickerService implements ImagePickerService {
  @override
  Future<String?> takePhoto() async {
    final shot = await ImagePicker().pickImage(source: ImageSource.camera);
    return shot?.path;
  }
}

@Riverpod(keepAlive: true)
ImagePickerService imagePickerService(Ref ref) => DeviceImagePickerService();
