import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'cat.dart';

/// Where the cats and their photos live. The app uses [DeviceCatStore];
/// tests pass an in-memory one.
abstract class CatStore {
  /// All cats. Called before any other method.
  Future<List<Cat>> load();

  Future<void> save(List<Cat> cats);

  /// Takes a photo with the camera and keeps it as `<millis>.jpg`. Null if
  /// the camera was cancelled.
  Future<File?> takePhoto();

  /// Deletes a photo taken by [takePhoto] that was not kept.
  Future<void> discard(File photo);

  /// The file for an encounter's photo name.
  File photoFile(String name);
}

/// Stores everything in `<documents>/cats/`: the photos, and `cats.json`
/// holding every cat and encounter.
class DeviceCatStore implements CatStore {
  DeviceCatStore({Future<Directory> Function()? dir})
    : _dir = dir ?? _documentsCats;

  final Future<Directory> Function() _dir;
  String _path = '';

  static Future<Directory> _documentsCats() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/cats');
  }

  Future<Directory> _catsDir() async {
    final dir = await (await _dir()).create(recursive: true);
    _path = dir.path;
    return dir;
  }

  /// Reads `cats.json`. If there is none yet, builds it from the photos and
  /// `names.json` of the app's first version (which is left in place). A
  /// corrupt `cats.json` is set aside as `cats.json.bad-<millis>` and rebuilt
  /// the same way, so no photo is ever lost.
  ///
  /// Throws if the folder cannot be read; the app then saves nothing, so a
  /// failed load can never overwrite `cats.json`.
  @override
  Future<List<Cat>> load() async {
    final dir = await _catsDir();
    final file = File('${dir.path}/cats.json');
    if (file.existsSync()) {
      final text = await file.readAsString();
      try {
        final json = jsonDecode(text) as Map<String, dynamic>;
        return [
          for (final c in json['cats'] as List<dynamic>)
            Cat.fromJson(c as Map<String, dynamic>),
        ];
      } catch (_) {
        await file.rename(
          '${file.path}.bad-${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    }
    final photos = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.jpg'))
        .toList();
    final cats = migrate(photos, await _loadNames(dir));
    await save(cats);
    return cats;
  }

  @override
  Future<void> save(List<Cat> cats) async {
    final dir = await _catsDir();
    final tmp = File('${dir.path}/cats.json.tmp');
    await tmp.writeAsString(
      jsonEncode({
        'version': 1,
        'cats': [for (final c in cats) c.toJson()],
      }),
      flush: true,
    );
    await tmp.rename('${dir.path}/cats.json');
  }

  @override
  Future<File?> takePhoto() async {
    final shot = await ImagePicker().pickImage(source: ImageSource.camera);
    if (shot == null) return null;
    final dir = await _catsDir();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return File(shot.path).copy('${dir.path}/$stamp.jpg');
  }

  @override
  Future<void> discard(File photo) async {
    if (photo.existsSync()) await photo.delete();
  }

  @override
  File photoFile(String name) => File('$_path/$name');

  /// `names.json` from the first version: photo file name -> cat name.
  static Future<Map<String, String>> _loadNames(Directory dir) async {
    try {
      final file = File('${dir.path}/names.json');
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return json.map((key, value) => MapEntry(key, value as String));
    } catch (_) {
      return {};
    }
  }
}
