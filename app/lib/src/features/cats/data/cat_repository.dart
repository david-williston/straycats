import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/cat.dart';
import 'cats_folder.dart';
import 'device_cat_repository.dart';

part 'cat_repository.g.dart';

/// Where the cats live. The app uses [DeviceCatRepository]; tests override
/// [catRepository] with an in-memory one.
abstract class CatRepository {
  /// All cats. Throws if they cannot be read; the app then saves nothing, so
  /// a failed load can never overwrite what is stored.
  Future<List<Cat>> loadCats();

  Future<void> saveCats(List<Cat> cats);
}

@Riverpod(keepAlive: true)
CatsFolder catsFolder(Ref ref) => CatsFolder();

@Riverpod(keepAlive: true)
CatRepository catRepository(Ref ref) =>
    DeviceCatRepository(ref.watch(catsFolderProvider));
