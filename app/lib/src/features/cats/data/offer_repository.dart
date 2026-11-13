import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'offer_repository.g.dart';

/// Remembers which cats were already asked "Ear-tipped: add sterilisation to
/// the story?", so the offer is made once per cat. Only a list of cat ids,
/// kept on this phone. Tests override [offerRepository] with an in-memory
/// one.
abstract class OfferRepository {
  /// The ids of the cats the ear-tip offer was already answered for.
  Future<Set<String>> loadEarTipAnswered();

  Future<void> markEarTipAnswered(String catId);
}

class DeviceOfferRepository implements OfferRepository {
  DeviceOfferRepository(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _key = 'earTipOfferAnswered';

  @override
  Future<Set<String>> loadEarTipAnswered() async => {
    ...?await _prefs.getStringList(_key),
  };

  @override
  Future<void> markEarTipAnswered(String catId) async {
    final ids = await loadEarTipAnswered();
    if (ids.add(catId)) await _prefs.setStringList(_key, [...ids]);
  }
}

class FakeOfferRepository implements OfferRepository {
  FakeOfferRepository([Set<String> answered = const {}])
    : answered = {...answered};

  final Set<String> answered;

  @override
  Future<Set<String>> loadEarTipAnswered() async => {...answered};

  @override
  Future<void> markEarTipAnswered(String catId) async => answered.add(catId);
}

@Riverpod(keepAlive: true)
OfferRepository offerRepository(Ref ref) =>
    DeviceOfferRepository(SharedPreferencesAsync());

/// The cats the ear-tip offer is done for. Loads once, then follows answers.
@Riverpod(keepAlive: true)
class EarTipAnswered extends _$EarTipAnswered {
  @override
  Future<Set<String>> build() =>
      ref.watch(offerRepositoryProvider).loadEarTipAnswered();

  /// The offer was answered (added or "Not now") for [catId]: never again.
  Future<void> answer(String catId) async {
    final current = state.value ?? await future;
    state = AsyncData({...current, catId});
    await ref.read(offerRepositoryProvider).markEarTipAnswered(catId);
  }
}
