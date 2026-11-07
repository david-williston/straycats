import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Lists the saved cat photos, newest first. Returns an empty list if the
/// folder (or the platform plugin) is unavailable.
Future<List<File>> loadCats() async {
  try {
    final dir = await _catsDir();
    final files =
        dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.toLowerCase().endsWith('.jpg'))
            .toList()
          ..sort((a, b) => b.path.compareTo(a.path));
    return files;
  } catch (_) {
    return [];
  }
}

Future<void> meetCat() async {
  final shot = await ImagePicker().pickImage(source: ImageSource.camera);
  if (shot == null) return;
  final dir = await _catsDir();
  final stamp = DateTime.now().millisecondsSinceEpoch;
  await File(shot.path).copy('${dir.path}/$stamp.jpg');
}

/// The key a photo's name is stored under: its file name, e.g. `1730.jpg`.
String photoKey(File photo) => photo.uri.pathSegments.last;

/// Reads `cats/names.json` (photo file name -> cat name). A missing or
/// corrupt file means no names yet.
Future<Map<String, String>> loadNames() async {
  try {
    final file = await _namesFile();
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return json.map((key, value) => MapEntry(key, value as String));
  } catch (_) {
    return {};
  }
}

Future<void> saveNames(Map<String, String> names) async {
  final file = await _namesFile();
  await file.writeAsString(jsonEncode(names));
}

Future<Directory> _catsDir() async {
  final docs = await getApplicationDocumentsDirectory();
  return Directory('${docs.path}/cats').create(recursive: true);
}

Future<File> _namesFile() async =>
    File('${(await _catsDir()).path}/names.json');
