// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(offerRepository)
final offerRepositoryProvider = OfferRepositoryProvider._();

final class OfferRepositoryProvider
    extends
        $FunctionalProvider<OfferRepository, OfferRepository, OfferRepository>
    with $Provider<OfferRepository> {
  OfferRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offerRepositoryHash();

  @$internal
  @override
  $ProviderElement<OfferRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OfferRepository create(Ref ref) {
    return offerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfferRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfferRepository>(value),
    );
  }
}

String _$offerRepositoryHash() => r'99bc5aa8804babd653420f11be73d0648ac5255c';

/// The cats the ear-tip offer is done for. Loads once, then follows answers.

@ProviderFor(EarTipAnswered)
final earTipAnsweredProvider = EarTipAnsweredProvider._();

/// The cats the ear-tip offer is done for. Loads once, then follows answers.
final class EarTipAnsweredProvider
    extends $AsyncNotifierProvider<EarTipAnswered, Set<String>> {
  /// The cats the ear-tip offer is done for. Loads once, then follows answers.
  EarTipAnsweredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'earTipAnsweredProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$earTipAnsweredHash();

  @$internal
  @override
  EarTipAnswered create() => EarTipAnswered();
}

String _$earTipAnsweredHash() => r'cff37f6d82c07b8ddf02b9fdd1acafcd64793ca5';

/// The cats the ear-tip offer is done for. Loads once, then follows answers.

abstract class _$EarTipAnswered extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
