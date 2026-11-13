// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_sharer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cardSharer)
final cardSharerProvider = CardSharerProvider._();

final class CardSharerProvider
    extends $FunctionalProvider<CardSharer, CardSharer, CardSharer>
    with $Provider<CardSharer> {
  CardSharerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardSharerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardSharerHash();

  @$internal
  @override
  $ProviderElement<CardSharer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CardSharer create(Ref ref) {
    return cardSharer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardSharer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardSharer>(value),
    );
  }
}

String _$cardSharerHash() => r'bfca2980399249ba41e22059325a86cbf9c3fcc9';
