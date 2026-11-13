// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cat_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catRepository)
final catRepositoryProvider = CatRepositoryProvider._();

final class CatRepositoryProvider
    extends $FunctionalProvider<CatRepository, CatRepository, CatRepository>
    with $Provider<CatRepository> {
  CatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catRepositoryHash();

  @$internal
  @override
  $ProviderElement<CatRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CatRepository create(Ref ref) {
    return catRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatRepository>(value),
    );
  }
}

String _$catRepositoryHash() => r'e142ea201dd6b676645be333bc3174cb5154b983';
