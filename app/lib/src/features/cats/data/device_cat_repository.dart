import 'dart:convert';
import 'dart:io';

import '../domain/cat.dart';
import '../domain/encounter.dart';
import 'cat_repository.dart';
import 'cats_folder.dart';
import 'photo_files.dart';

/// Stores every cat and encounter in `cats.json` in the cats folder, next to
/// the photos.
class DeviceCatRepository implements CatRepository {
  DeviceCatRepository(this._folder);

  final CatsFolder _folder;

  /// Reads `cats.json`. A corrupt one is set aside as
  /// `cats.json.bad-<millis>`, and cats are rebuilt from the photos (each
  /// photo its own cat with one encounter), so no photo is ever lost. The
  /// same rebuild happens when there is no `cats.json` yet.
  @override
  Future<List<Cat>> loadCats() async {
    final dir = await _folder.open();
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
    final cats = catsFromPhotos(photos);
    await saveCats(cats);
    return cats;
  }

  @override
  Future<void> saveCats(List<Cat> cats) async {
    final dir = await _folder.open();
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
}

/// One cat per photo, each with one encounter.
List<Cat> catsFromPhotos(List<File> photos) => [
  for (final photo in photos)
    Cat(
      id: photoName(photo).split('.').first,
      encounters: [
        Encounter(
          id: photoName(photo).split('.').first,
          photo: photoName(photo),
          time: photoTime(photo),
        ),
      ],
    ),
];
