import '../../places/data/place_service.dart';

/// A fake phone location, for tests. A null [fix] means permission denied or
/// no signal.
class FakePlaceService implements PlaceService {
  FakePlaceService({this.fix, this.name});

  Fix? fix;
  String? name;
  int locates = 0;

  @override
  Future<Fix?> locate() async {
    locates++;
    return fix;
  }

  @override
  Future<String?> neighbourhoodAt(Fix fix) async => name;
}
