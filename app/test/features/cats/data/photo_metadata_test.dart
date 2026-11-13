import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:straycats/src/features/cats/data/cats_folder.dart';
import 'package:straycats/src/features/cats/data/device_photo_repository.dart';
import 'package:straycats/src/features/cats/data/image_picker_service.dart';
import 'package:straycats/src/features/cats/data/photo_metadata.dart';

/// A real JPEG carrying GPS (Mexico City), a camera model and an
/// orientation, written the way a phone camera does.
Uint8List jpegWithGps({int orientation = 6}) {
  final image = img.Image(width: 32, height: 24);
  img.fill(image, color: img.ColorRgb8(200, 120, 40));
  image.exif.imageIfd.model = 'Pixel 9';
  image.exif.imageIfd.orientation = orientation;
  image.exif.gpsIfd.gpsLatitude = 19.4326;
  image.exif.gpsIfd.gpsLatitudeRef = 'N';
  image.exif.gpsIfd.gpsLongitude = 99.1332;
  image.exif.gpsIfd.gpsLongitudeRef = 'W';
  return img.encodeJpg(image);
}

class _Picker implements ImagePickerService {
  _Picker(this.path);
  final String path;
  @override
  Future<String?> takePhoto() async => path;
}

void main() {
  test('the fixture really has GPS', () {
    final bytes = jpegWithGps();
    expect(img.decodeJpg(bytes)!.exif.gpsIfd.gpsLatitude, isNotNull);
    expect(jpegHasGps(bytes), isTrue);
  });

  test('a JPEG with GPS EXIF comes out without it', () {
    final clean = stripJpegMetadata(jpegWithGps());

    expect(jpegHasGps(clean), isFalse);
    final decoded = img.decodeJpg(clean)!;
    expect(decoded.exif.gpsIfd.isEmpty, isTrue);
    expect(decoded.exif.gpsIfd.gpsLatitude, isNull);
    expect(decoded.exif.imageIfd.hasModel, isFalse);
    // Same picture, same size.
    final original = img.decodeJpg(jpegWithGps())!;
    expect(decoded.width, original.width);
    expect(decoded.height, original.height);
  });

  test('orientation survives, so the photo is not turned', () {
    // The decoder applies Exif orientation: a 32x24 picture marked "6"
    // decodes as 24x32, with or without the rest of the Exif.
    final upright = img.decodeJpg(stripJpegMetadata(jpegWithGps()))!;
    expect((upright.width, upright.height), (24, 32));
    final plain = img.decodeJpg(
      stripJpegMetadata(jpegWithGps(orientation: 1)),
    )!;
    expect((plain.width, plain.height), (32, 24));
  });

  test('a JPEG with no metadata, and a non-JPEG, are left alone', () {
    final clean = stripJpegMetadata(jpegWithGps());
    expect(stripJpegMetadata(clean), clean);
    final other = Uint8List.fromList([7, 1, 2]);
    expect(stripJpegMetadata(other), other);
    expect(jpegHasGps(other), isFalse);
  });

  group('on disk', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('cats'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('a photo taken with GPS is saved clean in the cats folder', () async {
      final shot = File('${dir.path}/camera.jpg')
        ..writeAsBytesSync(jpegWithGps());
      final repo = DevicePhotoRepository(
        CatsFolder(dir: () async => dir),
        _Picker(shot.path),
      );

      final kept = (await repo.takePhoto())!;

      expect(await photoHasGps(kept), isFalse);
      expect(img.decodeJpg(kept.readAsBytesSync()), isNotNull);
    });
  });
}
