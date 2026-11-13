import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// `<documents>/cats/`: where `cats.json` and the photos live.
class CatsFolder {
  CatsFolder({Future<Directory> Function()? dir})
    : _dir = dir ?? _documentsCats;

  final Future<Directory> Function() _dir;
  String _path = '';

  static Future<Directory> _documentsCats() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/cats');
  }

  /// The folder, created if needed. Throws if it cannot be made.
  Future<Directory> open() async {
    final dir = await (await _dir()).create(recursive: true);
    _path = dir.path;
    return dir;
  }

  /// A file in the folder. The folder is opened before any photo is shown.
  File file(String name) => File('$_path/$name');
}
