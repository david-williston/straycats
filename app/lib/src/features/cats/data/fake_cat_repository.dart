import '../domain/cat.dart';
import 'cat_repository.dart';

/// Keeps cats in memory, for tests. [saved] is what was last saved.
class FakeCatRepository implements CatRepository {
  FakeCatRepository([List<Cat> cats = const []]) : cats = [...cats];

  List<Cat> cats;
  List<Cat>? saved;

  /// When set, [loadCats] throws it.
  Object? loadError;

  @override
  Future<List<Cat>> loadCats() async {
    final error = loadError;
    if (error != null) throw error;
    return cats;
  }

  @override
  Future<void> saveCats(List<Cat> cats) async => saved = [...cats];
}
